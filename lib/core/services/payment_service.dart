// lib/core/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.mercadopago.com';
  static String _accessToken = 'TU_ACCESS_TOKEN_AQUI';
  static String _publicKey = 'TU_PUBLIC_KEY_AQUI';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Planes de suscripción
  static final Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic': {
      'id': 'basic',
      'name': 'Básico',
      'priceUSD': 1.0,
      'priceARS': 1000.0, // Aprox 1000 ARS por 1 USD
      'maxChildren': 1,
      'trialDays': 15,
      'features': [
        '1 niño incluido',
        'Actividades básicas',
        'Reportes mensuales',
        'Soporte por email',
      ],
    },
    'family': {
      'id': 'family',
      'name': 'Familiar',
      'priceUSD': 3.0,
      'priceARS': 3000.0,
      'maxChildren': 3,
      'trialDays': 15,
      'features': [
        'Hasta 3 niños',
        'Todas las actividades',
        'Reportes semanales',
        'Soporte prioritario',
        'Rutinas personalizadas',
      ],
    },
    'premium': {
      'id': 'premium',
      'name': 'Premium',
      'priceUSD': 5.0,
      'priceARS': 5000.0,
      'maxChildren': 10,
      'trialDays': 15,
      'features': [
        'Hasta 10 niños',
        'Contenido exclusivo',
        'Reportes diarios',
        'Soporte 24/7',
        'AI personalizada',
        'Análisis avanzado',
      ],
    },
  };

  // Inicializar servicio de pagos
  static Future<void> initialize() async {
    // Aquí inicializarías Mercado Pago SDK
    // await MercadoPagoSDK.initialize(publicKey: _publicKey);
    print('✅ Payment Service inicializado');
  }

  // Crear preferencia de pago
  static Future<Map<String, dynamic>> createPaymentPreference({
    required String planId,
    required String userEmail,
    required String userId,
  }) async {
    try {
      final plan = subscriptionPlans[planId];
      if (plan == null) {
        return {'success': false, 'error': 'Plan no válido'};
      }

      // Crear preferencia en Mercado Pago
      final response = await http.post(
        Uri.parse('$_baseUrl/checkout/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'items': [
            {
              'id': plan['id'],
              'title': 'KOVA - ${plan['name']}',
              'description': 'Suscripción ${plan['name']} - App KOVA',
              'quantity': 1,
              'currency_id': 'ARS',
              'unit_price': plan['priceARS'],
            },
          ],
          'payer': {'email': userEmail},
          'back_urls': {
            'success': 'kova://payment/success',
            'failure': 'kova://payment/failure',
            'pending': 'kova://payment/pending',
          },
          'auto_return': 'approved',
          'notification_url': 'https://kovapp.com/webhook/mercadopago',
          'metadata': {
            'user_id': userId,
            'plan_id': planId,
            'plan_name': plan['name'],
            'user_email': userEmail,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Guardar en Firestore
        await _savePaymentIntent(
          userId: userId,
          planId: planId,
          preferenceId: data['id'],
          amount: plan['priceARS'],
        );

        return {
          'success': true,
          'preferenceId': data['id'],
          'initPoint': data['init_point'],
          'plan': plan,
        };
      } else {
        return {
          'success': false,
          'error': 'Error creando preferencia: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Guardar intento de pago en Firestore
  static Future<void> _savePaymentIntent({
    required String userId,
    required String planId,
    required String preferenceId,
    required double amount,
  }) async {
    final paymentData = {
      'userId': userId,
      'planId': planId,
      'preferenceId': preferenceId,
      'amount': amount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('payment_intents')
        .doc(preferenceId)
        .set(paymentData);
  }

  // Verificar estado de pago
  static Future<Map<String, dynamic>> checkPaymentStatus(
    String preferenceId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/search?preference_id=$preferenceId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['results'] as List;

        if (payments.isNotEmpty) {
          final payment = payments.first;
          return {
            'success': true,
            'status': payment['status'],
            'statusDetail': payment['status_detail'],
            'paymentId': payment['id'],
          };
        }
        return {'success': false, 'error': 'No se encontró el pago'};
      } else {
        return {
          'success': false,
          'error': 'Error verificando pago: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Procesar pago exitoso
  static Future<Map<String, dynamic>> processSuccessfulPayment({
    required String userId,
    required String planId,
    required String paymentId,
  }) async {
    try {
      final plan = subscriptionPlans[planId];
      if (plan == null) {
        return {'success': false, 'error': 'Plan no válido'};
      }

      // Actualizar suscripción del usuario
      final subscriptionData = {
        'planType': planId,
        'startDate': FieldValue.serverTimestamp(),
        'endDate': FieldValue.serverTimestamp(),
        'isActive': true,
        'price': plan['priceUSD'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update({
        'subscription': subscriptionData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Registrar pago exitoso
      await _firestore.collection('payments').doc(paymentId).set({
        'userId': userId,
        'planId': planId,
        'amount': plan['priceARS'],
        'status': 'completed',
        'paymentId': paymentId,
        'completedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Suscripción activada exitosamente'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar suscripción activa
  static Future<Map<String, dynamic>> checkUserSubscription(
    String userId,
  ) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final subscription = userData?['subscription'];

        if (subscription != null && subscription['isActive'] == true) {
          final planId = subscription['planType'];
          final plan = subscriptionPlans[planId];

          return {
            'success': true,
            'hasActiveSubscription': true,
            'plan': plan,
            'subscriptionData': subscription,
          };
        }
      }

      return {'success': true, 'hasActiveSubscription': false};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Cancelar suscripción
  static Future<Map<String, dynamic>> cancelSubscription(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'subscription.isActive': false,
        'subscription.cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Suscripción cancelada'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Obtener planes disponibles
  static Map<String, dynamic> getSubscriptionPlans() {
    return {'success': true, 'plans': subscriptionPlans};
  }

  // Validar si puede agregar más niños
  static Future<bool> canAddMoreChildren({
    required String userId,
    required int currentChildrenCount,
  }) async {
    final subscriptionResult = await checkUserSubscription(userId);

    if (subscriptionResult['success'] &&
        subscriptionResult['hasActiveSubscription']) {
      final plan = subscriptionResult['plan'];
      final maxChildren = plan['maxChildren'] ?? 0;
      return currentChildrenCount < maxChildren;
    }

    return false;
  }
}
