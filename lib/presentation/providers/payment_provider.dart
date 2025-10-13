// lib/core/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/services/mercado_pago_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/models/subscription_plan.dart';

class PaymentProvider with ChangeNotifier {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.basic;
  bool _isProcessing = false;
  bool _hasActiveSubscription = false;
  bool _isInTrialPeriod = false;
  int _remainingTrialDays = 0;
  DateTime? _subscriptionStartDate;
  String? _currentSubscriptionId;
  String? _lastPreferenceId;

  // Getters
  SubscriptionPlan get selectedPlan => _selectedPlan;
  bool get isProcessing => _isProcessing;
  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isInTrialPeriod => _isInTrialPeriod;
  int get remainingTrialDays => _remainingTrialDays;
  DateTime? get subscriptionStartDate => _subscriptionStartDate;
  String? get lastPreferenceId => _lastPreferenceId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PaymentProvider() {
    _initializeProvider();
  }

  void _initializeProvider() {
    _selectedPlan = SubscriptionPlan.basic;
    print('✅ PaymentProvider inicializado con compatibilidad dual');
  }

  // Seleccionar plan
  void selectPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    print('📋 Plan seleccionado: ${plan.name}');
    notifyListeners();
  }

  // Procesar suscripción - MÉTODO PRINCIPAL
  Future<Map<String, dynamic>> processSubscription({
    required String userEmail,
    required String userId,
    required BuildContext context,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      print('🔄 Iniciando proceso de suscripción para: $userEmail');

      // Crear preferencia de pago en Mercado Pago
      final preferenceResult = await MercadoPagoService.createSubscriptionPreference(
        planId: _selectedPlan.id,
        planName: _selectedPlan.name,
        price: _selectedPlan.priceARS,
        trialDays: _selectedPlan.trialDays,
        userEmail: userEmail,
        userId: userId,
      );

      if (!preferenceResult['success']) {
        throw Exception(preferenceResult['error']);
      }

      final preferenceId = preferenceResult['preferenceId'];
      final initPoint = preferenceResult['initPoint'];

      // Guardar información de suscripción en Firestore (nueva estructura)
      await _saveSubscriptionInfo(
        userId: userId,
        plan: _selectedPlan,
        preferenceId: preferenceId,
      );

      // También guardar en la estructura antigua para compatibilidad
      await _saveToLegacyStructure(userId, preferenceId);

      _lastPreferenceId = preferenceId;

      // Abrir checkout con Custom Tabs
      await MercadoPagoService.launchCheckout(
        initPoint: initPoint,
        context: context,
      );

      _isProcessing = false;
      notifyListeners();

      print('✅ Proceso de suscripción completado exitosamente');
      return {
        'success': true,
        'preferenceId': preferenceId,
        'initPoint': initPoint,
      };
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      print('❌ Error en processSubscription: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Guardar en estructura legada para compatibilidad
  Future<void> _saveToLegacyStructure(String userId, String preferenceId) async {
    try {
      await _firestore.collection('payment_intents').doc(preferenceId).set({
        'userId': userId,
        'planId': _selectedPlan.id,
        'preferenceId': preferenceId,
        'amount': _selectedPlan.priceARS,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('💾 Guardado en estructura legada: $preferenceId');
    } catch (e) {
      print('⚠️ Error guardando en estructura legada: $e');
    }
  }

  // Guardar información de suscripción en Firestore (nueva estructura)
  Future<void> _saveSubscriptionInfo({
    required String userId,
    required SubscriptionPlan plan,
    required String preferenceId,
  }) async {
    try {
      final subscriptionData = {
        'userId': userId,
        'plan': plan.toMap(),
        'preferenceId': preferenceId,
        'status': 'pending',
        'selectedPlan': plan.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .set(subscriptionData, SetOptions(merge: true));

      print('💾 Información de suscripción guardada en Firestore (nueva estructura)');
    } catch (e) {
      print('❌ Error guardando en Firestore: $e');
      rethrow;
    }
  }

  // Verificar estado de suscripción del usuario - MEJORADO CON COMPATIBILIDAD DUAL
  Future<void> checkUserSubscription(String userId, {String? userEmail}) async {
    try {
      print('🔍 Verificando suscripción para usuario: $userId (compatibilidad dual)');

      // PRIMERO: Verificar con PaymentService (compatible con ambas estructuras)
      final paymentServiceResult = await PaymentService.checkUserSubscription(userId);

      if (paymentServiceResult['success'] && paymentServiceResult['hasActiveSubscription']) {
        _handleSuccessfulSubscriptionCheck(paymentServiceResult, userId);
        return;
      }

      // SEGUNDO: Verificar en nueva estructura (subscriptions)
      final doc = await _firestore.collection('subscriptions').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final status = data['status'] as String? ?? 'inactive';

        if (status == 'active') {
          _handleNewStructureData(data);
          return;
        }
      }

      // TERCERO: Verificar en estructura antigua (users)
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final subscription = userData?['subscription'];

        if (subscription != null && subscription['isActive'] == true) {
          _handleLegacyStructureData(subscription, userId);
          return;
        }
      }

      // CUARTO: Verificar en Mercado Pago directamente
      if (userEmail != null) {
        final hasActiveMPSubscription = await MercadoPagoService.checkActiveSubscription(userId);
        if (hasActiveMPSubscription) {
          _hasActiveSubscription = true;
          await _syncSubscriptionFromMP(userId);
          print('✅ Suscripción activa encontrada en Mercado Pago');
        }
      }

      // Si no hay suscripción activa en ningún lado
      _resetSubscriptionState();

      print('🎯 Estado final - Suscripción activa: $_hasActiveSubscription');
      notifyListeners();
    } catch (e) {
      print('❌ Error verificando suscripción: $e');
    }
  }

  // Manejar resultado exitoso de PaymentService
  void _handleSuccessfulSubscriptionCheck(Map<String, dynamic> result, String userId) {
    final planData = result['plan'] as Map<String, dynamic>;
    final subscriptionData = result['subscriptionData'];
    final source = result['source'] as String;

    _selectedPlan = SubscriptionPlan.fromMap(planData);
    _hasActiveSubscription = true;
    _subscriptionStartDate = (subscriptionData['startDate'] as Timestamp?)?.toDate();
    _currentSubscriptionId = subscriptionData['paymentId'] as String?;

    if (_subscriptionStartDate != null) {
      _isInTrialPeriod = _selectedPlan.isInTrialPeriod(_subscriptionStartDate!);
      _remainingTrialDays = _selectedPlan.getRemainingTrialDays(_subscriptionStartDate!);
    }

    print('📊 Estado desde PaymentService ($source): Activa, Plan: ${_selectedPlan.name}');
    notifyListeners();
  }

  // Manejar datos de nueva estructura
  void _handleNewStructureData(Map<String, dynamic> data) {
    final planData = data['plan'] as Map<String, dynamic>? ?? {};
    try {
      _selectedPlan = SubscriptionPlan.fromMap(planData);
    } catch (e) {
      // Fallback a plan básico si hay error
      final planId = data['selectedPlan'] as String? ?? 'basic';
      _selectedPlan = SubscriptionPlan.allPlans.firstWhere(
            (p) => p.id == planId,
        orElse: () => SubscriptionPlan.basic,
      );
    }

    _hasActiveSubscription = true;
    _subscriptionStartDate = (data['startDate'] as Timestamp?)?.toDate();
    _currentSubscriptionId = data['paymentId'] as String?;

    if (_subscriptionStartDate != null) {
      _isInTrialPeriod = _selectedPlan.isInTrialPeriod(_subscriptionStartDate!);
      _remainingTrialDays = _selectedPlan.getRemainingTrialDays(_subscriptionStartDate!);
    }

    print('📊 Estado desde nueva estructura: Activa, Plan: ${_selectedPlan.name}');
    notifyListeners();
  }

  // Manejar datos de estructura legada
  void _handleLegacyStructureData(Map<String, dynamic> subscription, String userId) {
    final planId = subscription['planType'] as String? ?? 'basic';
    _selectedPlan = SubscriptionPlan.allPlans.firstWhere(
          (p) => p.id == planId,
      orElse: () => SubscriptionPlan.basic,
    );

    _hasActiveSubscription = true;
    _subscriptionStartDate = (subscription['startDate'] as Timestamp?)?.toDate();

    if (_subscriptionStartDate != null) {
      _isInTrialPeriod = _selectedPlan.isInTrialPeriod(_subscriptionStartDate!);
      _remainingTrialDays = _selectedPlan.getRemainingTrialDays(_subscriptionStartDate!);
    }

    print('📊 Estado desde estructura legada: Activa, Plan: ${_selectedPlan.name}');

    // Migrar a nueva estructura
    PaymentService.syncUserSubscription(userId);
    notifyListeners();
  }

  // Resetear estado de suscripción
  void _resetSubscriptionState() {
    _hasActiveSubscription = false;
    _isInTrialPeriod = false;
    _remainingTrialDays = 0;
    _selectedPlan = SubscriptionPlan.basic;
    print('📊 No se encontraron suscripciones activas');
  }

  // Sincronizar desde Mercado Pago
  Future<void> _syncSubscriptionFromMP(String userId) async {
    try {
      final result = await MercadoPagoService.searchPaymentsByReference('subscription_$userId');
      if (result['success']) {
        final payments = result['payments'] as List;
        if (payments.isNotEmpty) {
          final payment = payments.first;
          final planId = payment['metadata']['plan_id'] ?? 'basic';
          final plan = SubscriptionPlan.allPlans.firstWhere(
                (p) => p.id == planId,
            orElse: () => SubscriptionPlan.basic,
          );

          _selectedPlan = plan;
          _subscriptionStartDate = DateTime.parse(payment['date_created']);
          _isInTrialPeriod = plan.isInTrialPeriod(_subscriptionStartDate!);
          _remainingTrialDays = plan.getRemainingTrialDays(_subscriptionStartDate!);

          // Actualizar Firestore usando PaymentService
          await PaymentService.processSuccessfulPayment(
            userId: userId,
            planId: planId,
            paymentId: payment['id'].toString(),
          );
        }
      }
    } catch (e) {
      print('❌ Error sincronizando desde MP: $e');
    }
  }

  // Manejar deep link de retorno desde Mercado Pago
  Future<void> handlePaymentReturn(Uri deepLink) async {
    try {
      print('🔗 Manejando deep link: $deepLink');

      final path = deepLink.path;
      final queryParams = deepLink.queryParameters;

      print('📋 Parámetros de consulta: $queryParams');

      if (path.contains('/success') || path.contains('/pending')) {
        // Pago exitoso o pendiente - verificar estado
        await _verifyAndUpdatePaymentStatus(queryParams);
      } else if (path.contains('/failure')) {
        // Pago fallido
        print('❌ Pago fallido detectado desde deep link');
        _handlePaymentFailure();
      }
    } catch (e) {
      print('💥 Error manejando deep link: $e');
    }
  }

  // Verificar y actualizar estado de pago
  Future<void> _verifyAndUpdatePaymentStatus(Map<String, String> queryParams) async {
    try {
      final preferenceId = queryParams['preference_id'] ?? _lastPreferenceId;
      final paymentId = queryParams['payment_id'];
      final status = queryParams['status'];

      print('🔍 Verificando estado con preferenceId: $preferenceId, paymentId: $paymentId');

      if (preferenceId != null) {
        // Buscar la suscripción en Firestore por preferenceId
        final query = await _firestore
            .collection('subscriptions')
            .where('preferenceId', isEqualTo: preferenceId)
            .get();

        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final userId = doc.id;

          String newStatus = 'pending';
          if (status == 'approved') {
            newStatus = 'active';
          } else if (status == 'rejected') {
            newStatus = 'failed';
          }

          // Actualizar en Firestore
          final updateData = {
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (paymentId != null) {
            updateData['paymentId'] = paymentId;
          }

          if (newStatus == 'active') {
            updateData['startDate'] = FieldValue.serverTimestamp();
            updateData['trialEndDate'] = Timestamp.fromDate(
              DateTime.now().add(Duration(days: _selectedPlan.trialDays)),
            );
          }

          await _firestore
              .collection('subscriptions')
              .doc(userId)
              .set(updateData, SetOptions(merge: true));

          // Actualizar estado local
          if (newStatus == 'active') {
            _hasActiveSubscription = true;
            _subscriptionStartDate = DateTime.now();
            _isInTrialPeriod = true;
            _remainingTrialDays = _selectedPlan.trialDays;
          }

          print('✅ Estado actualizado a: $newStatus para usuario: $userId');
          notifyListeners();
        } else {
          print('⚠️ No se encontró suscripción con preferenceId: $preferenceId');
        }
      }

      // Si tenemos paymentId, verificar estado directamente con Mercado Pago
      if (paymentId != null) {
        final paymentStatus = await MercadoPagoService.getPaymentStatus(paymentId);
        if (paymentStatus['success'] && paymentStatus['status'] == 'approved') {
          print('✅ Pago confirmado por API de Mercado Pago');
        }
      }
    } catch (e) {
      print('💥 Error verificando estado de pago: $e');
    }
  }

  // Manejar fallo de pago
  void _handlePaymentFailure() {
    _hasActiveSubscription = false;
    _isInTrialPeriod = false;
    _remainingTrialDays = 0;
    notifyListeners();
  }

  // Cancelar suscripción
  Future<Map<String, dynamic>> cancelSubscription(String userId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      print('🔄 Cancelando suscripción para: $userId');

      // Si tenemos subscriptionId, cancelar en Mercado Pago
      if (_currentSubscriptionId != null) {
        final result = await MercadoPagoService.cancelSubscription(_currentSubscriptionId!);

        if (!result['success']) {
          print('⚠️ No se pudo cancelar en Mercado Pago, pero se cancelará localmente');
        }
      }

      // Actualizar en Firestore usando PaymentService (que actualiza ambas estructuras)
      final result = await PaymentService.cancelSubscription(userId);

      // Actualizar estado local
      _hasActiveSubscription = false;
      _isInTrialPeriod = false;
      _remainingTrialDays = 0;
      _currentSubscriptionId = null;

      _isProcessing = false;
      notifyListeners();

      print('✅ Suscripción cancelada exitosamente');
      return result;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();

      print('❌ Error cancelando suscripción: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // MÉTODOS DE INTEGRACIÓN CON PAYMENT SERVICE

  // Verificar estado usando PaymentService
  Future<Map<String, dynamic>> checkPaymentStatus(String preferenceId) async {
    return await PaymentService.checkPaymentStatus(preferenceId);
  }

  // Procesar pago exitoso usando PaymentService
  Future<Map<String, dynamic>> processSuccessfulPayment({
    required String userId,
    required String planId,
    required String paymentId,
  }) async {
    return await PaymentService.processSuccessfulPayment(
      userId: userId,
      planId: planId,
      paymentId: paymentId,
    );
  }

  // Sincronizar suscripción entre estructuras
  Future<void> syncUserSubscription(String userId) async {
    await PaymentService.syncUserSubscription(userId);
  }

  // Verificar si puede agregar más niños usando PaymentService
  Future<bool> canUserAddMoreChildren({
    required String userId,
    required int currentChildrenCount,
  }) async {
    return await PaymentService.canAddMoreChildren(
      userId: userId,
      currentChildrenCount: currentChildrenCount,
    );
  }

  // Obtener historial de pagos
  Future<Map<String, dynamic>> getPaymentHistory(String userId) async {
    return await PaymentService.getPaymentHistory(userId);
  }

  // Verificar si un pago específico fue exitoso
  Future<bool> isPaymentSuccessful(String paymentId) async {
    return await PaymentService.isPaymentSuccessful(paymentId);
  }

  // Verificar si puede agregar más niños (método local)
  bool canAddMoreChildren(int currentChildrenCount) {
    if (_hasActiveSubscription) {
      return _selectedPlan.canAddMoreChildren(currentChildrenCount);
    }
    return _isInTrialPeriod && currentChildrenCount < _selectedPlan.maxChildren;
  }

  // Obtener límite de niños
  int getChildrenLimit() {
    if (!_hasActiveSubscription && !_isInTrialPeriod) {
      return 0;
    }
    return _selectedPlan.maxChildren;
  }

  // Forzar verificación de estado (útil después de retorno de pago)
  Future<void> forceSubscriptionCheck(String userId, {String? userEmail}) async {
    print('🔄 Forzando verificación de suscripción...');
    await checkUserSubscription(userId, userEmail: userEmail);
  }

  // Reiniciar estado (para logout)
  void reset() {
    _selectedPlan = SubscriptionPlan.basic;
    _isProcessing = false;
    _hasActiveSubscription = false;
    _isInTrialPeriod = false;
    _remainingTrialDays = 0;
    _subscriptionStartDate = null;
    _currentSubscriptionId = null;
    _lastPreferenceId = null;
    print('🔄 PaymentProvider reiniciado');
    notifyListeners();
  }
}