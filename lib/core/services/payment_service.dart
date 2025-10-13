// lib/core/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koa_app/core/models/subscription_plan.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.mercadopago.com';
  static String _accessToken = 'TU_ACCESS_TOKEN_AQUI';
  static String _publicKey = 'TU_PUBLIC_KEY_AQUI';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configurar credenciales
  static void configure({required String accessToken, required String publicKey}) {
    _accessToken = accessToken;
    _publicKey = publicKey;
  }

  // Planes de suscripción - Actualizado para usar el modelo SubscriptionPlan
  static Map<String, Map<String, dynamic>> get subscriptionPlans {
    return {
      'basic': SubscriptionPlan.basic.toMap(),
      'family': SubscriptionPlan.family.toMap(),
      'premium': SubscriptionPlan.premium.toMap(),
    };
  }

  // Inicializar servicio de pagos
  static Future<void> initialize() async {
    print('✅ Payment Service inicializado');
  }

  // Crear preferencia de pago - MANTENIDO PARA COMPATIBILIDAD
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

  // Guardar intento de pago en Firestore - MEJORADO
  static Future<void> _savePaymentIntent({
    required String userId,
    required String planId,
    required String preferenceId,
    required double amount,
  }) async {
    try {
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

      print('💾 Intento de pago guardado: $preferenceId');
    } catch (e) {
      print('❌ Error guardando intento de pago: $e');
      rethrow;
    }
  }

  // Verificar estado de pago - MEJORADO
  static Future<Map<String, dynamic>> checkPaymentStatus(
      String preferenceId,
      ) async {
    try {
      print('🔍 Verificando estado de pago para: $preferenceId');

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/search?preference_id=$preferenceId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payments = data['results'] as List;

        if (payments.isNotEmpty) {
          final payment = payments.first;
          final status = payment['status'];

          print('📊 Estado del pago: $status');

          // Actualizar Firestore con el estado
          await _updatePaymentIntentStatus(preferenceId, status);

          return {
            'success': true,
            'status': status,
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

  // Actualizar estado del intento de pago en Firestore
  static Future<void> _updatePaymentIntentStatus(
      String preferenceId,
      String status
      ) async {
    try {
      await _firestore
          .collection('payment_intents')
          .doc(preferenceId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('📝 Estado actualizado a: $status para: $preferenceId');
    } catch (e) {
      print('❌ Error actualizando estado: $e');
    }
  }

  // Procesar pago exitoso - MEJORADO
  static Future<Map<String, dynamic>> processSuccessfulPayment({
    required String userId,
    required String planId,
    required String paymentId,
  }) async {
    try {
      print('🎉 Procesando pago exitoso: $paymentId');

      final plan = subscriptionPlans[planId];
      if (plan == null) {
        return {'success': false, 'error': 'Plan no válido'};
      }

      // Actualizar suscripción del usuario en la colección 'users'
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

      // También actualizar en la colección 'subscriptions' (nueva estructura)
      await _firestore.collection('subscriptions').doc(userId).set({
        'userId': userId,
        'plan': plan,
        'status': 'active',
        'startDate': FieldValue.serverTimestamp(),
        'paymentId': paymentId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Registrar pago exitoso
      await _firestore.collection('payments').doc(paymentId).set({
        'userId': userId,
        'planId': planId,
        'amount': plan['priceARS'],
        'status': 'completed',
        'paymentId': paymentId,
        'completedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Pago procesado exitosamente para usuario: $userId');
      return {'success': true, 'message': 'Suscripción activada exitosamente'};
    } catch (e) {
      print('❌ Error procesando pago: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar suscripción activa - MEJORADO (compatible con ambas estructuras)
  static Future<Map<String, dynamic>> checkUserSubscription(
      String userId,
      ) async {
    try {
      print('🔍 Verificando suscripción para: $userId');

      // Primero verificar en la nueva estructura (subscriptions)
      final subscriptionDoc = await _firestore.collection('subscriptions').doc(userId).get();

      if (subscriptionDoc.exists) {
        final data = subscriptionDoc.data()!;
        final status = data['status'] as String? ?? 'inactive';

        if (status == 'active') {
          final planData = data['plan'] as Map<String, dynamic>? ?? {};
          final plan = subscriptionPlans[planData['id']] ?? subscriptionPlans['basic']!;

          return {
            'success': true,
            'hasActiveSubscription': true,
            'plan': plan,
            'subscriptionData': data,
            'source': 'subscriptions',
          };
        }
      }

      // Si no existe en la nueva estructura, verificar en la antigua (users)
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
            'source': 'users',
          };
        }
      }

      return {
        'success': true,
        'hasActiveSubscription': false,
        'source': 'none'
      };
    } catch (e) {
      print('❌ Error verificando suscripción: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Cancelar suscripción - MEJORADO (compatible con ambas estructuras)
  static Future<Map<String, dynamic>> cancelSubscription(String userId) async {
    try {
      print('🔄 Cancelando suscripción para: $userId');

      // Actualizar en la colección 'users' (estructura antigua)
      await _firestore.collection('users').doc(userId).update({
        'subscription.isActive': false,
        'subscription.cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar en la colección 'subscriptions' (nueva estructura)
      await _firestore.collection('subscriptions').doc(userId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Suscripción cancelada para usuario: $userId');
      return {'success': true, 'message': 'Suscripción cancelada'};
    } catch (e) {
      print('❌ Error cancelando suscripción: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Obtener planes disponibles
  static Map<String, dynamic> getSubscriptionPlans() {
    return {'success': true, 'plans': subscriptionPlans};
  }

  // Validar si puede agregar más niños - MEJORADO
  static Future<bool> canAddMoreChildren({
    required String userId,
    required int currentChildrenCount,
  }) async {
    try {
      final subscriptionResult = await checkUserSubscription(userId);

      if (subscriptionResult['success'] && subscriptionResult['hasActiveSubscription']) {
        final plan = subscriptionResult['plan'];
        final maxChildren = plan['maxChildren'] ?? 0;
        final canAdd = currentChildrenCount < maxChildren;

        print('👶 Usuario $userId puede agregar más niños: $canAdd ($currentChildrenCount/$maxChildren)');
        return canAdd;
      }

      return false;
    } catch (e) {
      print('❌ Error validando límite de niños: $e');
      return false;
    }
  }

  // NUEVO: Obtener historial de pagos del usuario
  static Future<Map<String, dynamic>> getPaymentHistory(String userId) async {
    try {
      final paymentsQuery = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      final payments = paymentsQuery.docs.map((doc) => doc.data()).toList();

      return {
        'success': true,
        'payments': payments,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // NUEVO: Verificar si un pago específico fue exitoso
  static Future<bool> isPaymentSuccessful(String paymentId) async {
    try {
      final paymentDoc = await _firestore.collection('payments').doc(paymentId).get();

      if (paymentDoc.exists) {
        final data = paymentDoc.data()!;
        return data['status'] == 'completed';
      }

      return false;
    } catch (e) {
      print('❌ Error verificando pago: $e');
      return false;
    }
  }

  // NUEVO: Sincronizar suscripción entre estructuras
  static Future<void> syncUserSubscription(String userId) async {
    try {
      final subscriptionResult = await checkUserSubscription(userId);

      if (subscriptionResult['success'] && subscriptionResult['hasActiveSubscription']) {
        final plan = subscriptionResult['plan'];
        final source = subscriptionResult['source'];

        // Si la suscripción está en la estructura antigua, migrar a la nueva
        if (source == 'users') {
          await _firestore.collection('subscriptions').doc(userId).set({
            'userId': userId,
            'plan': plan,
            'status': 'active',
            'startDate': FieldValue.serverTimestamp(),
            'migratedFrom': 'users',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          print('🔄 Suscripción migrada a nueva estructura para: $userId');
        }
      }
    } catch (e) {
      print('❌ Error sincronizando suscripción: $e');
    }
  }
}