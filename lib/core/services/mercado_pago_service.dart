import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mercado_pago_sdk/mercado_pago_sdk.dart';

class MercadoPagoService {
  static const String _baseUrl = 'https://api.mercadopago.com';
  static String _accessToken =
      'TU_ACCESS_TOKEN_AQUI'; // Reemplazar en producción
  static String _publicKey = 'TU_PUBLIC_KEY_AQUI'; // Reemplazar en producción

  static late MercadoPago _mercadoPago;

  // Inicializar SDK de Mercado Pago
  static Future<void> initialize() async {
    _mercadoPago = MercadoPago(
      publicKey: _publicKey,
      accessToken: _accessToken,
    );

    // Configurar preferencias
    await _mercadoPago.configure(
      environment: MPEnvironment.sandbox, // Cambiar a .production en producción
    );
  }

  // Crear preferencia de pago para suscripción
  static Future<Map<String, dynamic>> createSubscriptionPreference({
    required String planId,
    required String planName,
    required double price,
    required int trialDays,
    required String userEmail,
  }) async {
    try {
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
              'title': planName,
              'description': 'Suscripción $planName - KOA App',
              'quantity': 1,
              'currency_id': 'ARS',
              'unit_price': price,
            },
          ],
          'payer': {'email': userEmail},
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
          },
          'notification_url':
              'https://tu-webhook.com/notifications', // Webhook para notificaciones
          'statement_descriptor': 'KOA - Neurodesarrollo',
          'external_reference':
              'subscription_${DateTime.now().millisecondsSinceEpoch}',
          'expires': false,
          'metadata': {
            'plan_id': planId,
            'plan_name': planName,
            'trial_days': trialDays,
            'user_email': userEmail,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'preferenceId': data['id'],
          'initPoint': data['init_point'],
        };
      } else {
        throw Exception('Error creando preferencia: ${response.statusCode}');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Procesar pago con tarjeta de crédito
  static Future<Map<String, dynamic>> processCreditCardPayment({
    required String token,
    required String issuerId,
    required String paymentMethodId,
    required int installments,
    required double amount,
    required String planId,
    required String userEmail,
  }) async {
    try {
      final paymentData = {
        'transaction_amount': amount,
        'token': token,
        'description': 'Suscripción KOA - $planId',
        'installments': installments,
        'payment_method_id': paymentMethodId,
        'issuer_id': issuerId,
        'payer': {'email': userEmail},
        'metadata': {'plan_id': planId, 'user_email': userEmail},
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'paymentId': data['id'],
          'status': data['status'],
          'statusDetail': data['status_detail'],
        };
      } else {
        throw Exception('Error procesando pago: ${response.statusCode}');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Obtener estado de un pago
  static Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/$paymentId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'statusDetail': data['status_detail'],
          'amount': data['transaction_amount'],
        };
      } else {
        throw Exception('Error obteniendo estado: ${response.statusCode}');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Cancelar suscripción
  static Future<Map<String, dynamic>> cancelSubscription(
    String subscriptionId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/preauthorized/$subscriptionId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
        body: json.encode({'status': 'cancelled'}),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        throw Exception('Error cancelando suscripción: ${response.statusCode}');
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar si el usuario tiene una suscripción activa
  static Future<bool> checkActiveSubscription(String userEmail) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/v1/payments/search?sort=date_created&criteria=desc&external_reference=$userEmail',
        ),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['results'] as List;

        // Buscar pagos aprobados recientes
        final activePayment = payments.firstWhere(
          (payment) =>
              payment['status'] == 'approved' &&
              DateTime.parse(
                payment['date_created'],
              ).isAfter(DateTime.now().subtract(const Duration(days: 30))),
          orElse: () => null,
        );

        return activePayment != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
