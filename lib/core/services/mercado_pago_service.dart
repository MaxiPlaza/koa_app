// lib/core/services/mercado_pago_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter/material.dart';

class MercadoPagoService {
  static const String _baseUrl = 'https://api.mercadopago.com';

  // 🔐 REEMPLAZA ESTOS CON TUS CREDENCIALES REALES
  static String _accessToken = 'APP_USR-7255591479184386-101309-dfab2f93f4c50a5b0be7afad89a433d6-1309579932';
  static String _publicKey = 'APP_USR-64000b7d-62ec-4fc2-b131-696a7943bd27';

  // Configurar credenciales (llamar desde main.dart)
  static void configure({required String accessToken, required String publicKey}) {
    _accessToken = accessToken;
    _publicKey = publicKey;
  }

  // Crear preferencia de pago para suscripción
  static Future<Map<String, dynamic>> createSubscriptionPreference({
    required String planId,
    required String planName,
    required double price,
    required int trialDays,
    required String userEmail,
    required String userId,
  }) async {
    try {
      print('🔄 Creando preferencia para plan: $planId, usuario: $userId');

      final response = await http.post(
        Uri.parse('$_baseUrl/checkout/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'items': [
            {
              'id': planId,
              'title': 'KOA - $planName',
              'description': 'Suscripción $planName - App KOA',
              'quantity': 1,
              'currency_id': 'ARS',
              'unit_price': price,
            },
          ],
          'payer': {
            'email': userEmail,
            'name': 'Usuario KOA',
          },
          'back_urls': {
            'success': 'koa://payment/success',
            'failure': 'koa://payment/failure',
            'pending': 'koa://payment/pending',
          },
          'auto_return': 'approved',
          'payment_methods': {
            'excluded_payment_types': [
              {'id': 'atm'},
            ],
            'installments': 1,
            'default_installments': 1,
          },
          'notification_url': 'https://kovapp.com/webhook/mercadopago',
          'statement_descriptor': 'KOA - Neurodesarrollo',
          'external_reference': 'subscription_${DateTime.now().millisecondsSinceEpoch}_$userId',
          'expires': false,
          'metadata': {
            'plan_id': planId,
            'plan_name': planName,
            'trial_days': trialDays,
            'user_email': userEmail,
            'user_id': userId,
            'app_name': 'KOA',
          },
        }),
      );

      print('📡 Respuesta MP: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Preferencia creada: ${data['id']}');

        return {
          'success': true,
          'preferenceId': data['id'],
          'initPoint': data['init_point'],
        };
      } else {
        print('❌ Error MP: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error': 'Error creando preferencia: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e, stackTrace) {
      print('💥 Exception MP: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Abrir checkout con Custom Tabs
  static Future<void> launchCheckout({
    required String initPoint,
    required BuildContext context,
  }) async {
    try {
      print('🌐 Abriendo checkout: $initPoint');

      final theme = Theme.of(context);

      await launchUrl(
        Uri.parse(initPoint),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.primary,
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
          animations: const CustomTabsAnimations(
            startEnter: 'slide_up',
            startExit: 'android:anim/fade_out',
            endEnter: 'android:anim/fade_in',
            endExit: 'slide_down',
          ),
        ),
        safariVCOptions: const SafariViewControllerOptions(
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
          preferredBarTintColor: Colors.white,
          preferredControlTintColor: Colors.blue,
        ),
      );

      print('✅ Checkout abierto exitosamente');
    } catch (e, stackTrace) {
      print('💥 Error lanzando Custom Tab: $e');
      print('Stack trace: $stackTrace');

      // Fallback: intentar con url_launcher
      try {
        print('🔄 Intentando fallback con url_launcher...');
        import 'package:url_launcher/url_launcher.dart';
        if (await canLaunchUrl(Uri.parse(initPoint))) {
          await launchUrl(Uri.parse(initPoint));
        } else {
          throw Exception('No se pudo abrir la URL');
        }
      } catch (fallbackError) {
        print('💥 Fallback también falló: $fallbackError');
        rethrow;
      }
    }
  }

  // Obtener estado de un pago
  static Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      print('🔄 Consultando estado de pago: $paymentId');

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/$paymentId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Estado de pago: ${data['status']}');

        return {
          'success': true,
          'status': data['status'],
          'statusDetail': data['status_detail'],
          'amount': data['transaction_amount'],
          'paymentId': data['id'],
        };
      } else {
        print('❌ Error consultando pago: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error obteniendo estado: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('💥 Error consultando pago: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Buscar pagos por referencia externa
  static Future<Map<String, dynamic>> searchPaymentsByReference(
      String externalReference,
      ) async {
    try {
      print('🔍 Buscando pagos por referencia: $externalReference');

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/search?external_reference=$externalReference'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['results'] as List;
        print('✅ Encontrados ${payments.length} pagos');

        return {
          'success': true,
          'payments': payments,
        };
      } else {
        return {
          'success': false,
          'error': 'Error buscando pagos: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar si el usuario tiene una suscripción activa
  static Future<bool> checkActiveSubscription(String userId) async {
    try {
      print('🔍 Verificando suscripción activa para: $userId');

      final result = await searchPaymentsByReference('subscription_$userId');

      if (result['success']) {
        final payments = result['payments'] as List;

        // Buscar pagos aprobados en los últimos 30 días
        final activePayment = payments.firstWhere(
              (payment) =>
          payment['status'] == 'approved' &&
              DateTime.parse(payment['date_created'])
                  .isAfter(DateTime.now().subtract(const Duration(days: 30))),
          orElse: () => null,
        );

        final hasActiveSubscription = activePayment != null;
        print('📊 Usuario $userId - Suscripción activa: $hasActiveSubscription');

        return hasActiveSubscription;
      }
      return false;
    } catch (e) {
      print('💥 Error verificando suscripción: $e');
      return false;
    }
  }

  // Cancelar suscripción en Mercado Pago
  static Future<Map<String, dynamic>> cancelSubscription(String subscriptionId) async {
    try {
      print('🔄 Cancelando suscripción: $subscriptionId');

      final response = await http.put(
        Uri.parse('$_baseUrl/preauthorized/$subscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({'status': 'cancelled'}),
      );

      if (response.statusCode == 200) {
        print('✅ Suscripción cancelada exitosamente');
        return {'success': true};
      } else {
        print('❌ Error cancelando suscripción: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error cancelando suscripción: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('💥 Error cancelando suscripción: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar credenciales
  static Future<bool> verifyCredentials() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payment_methods'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}