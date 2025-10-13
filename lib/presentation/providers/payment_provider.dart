import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/mercado_pago_service.dart';
import '../../core/models/subscription_plan.dart';

class PaymentProvider with ChangeNotifier {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.basic;
  bool _isProcessing = false;
  bool _hasActiveSubscription = false;
  bool _isInTrialPeriod = true;
  int _remainingTrialDays = 15;
  DateTime? _subscriptionStartDate;
  String? _currentSubscriptionId;

  // Getters
  SubscriptionPlan get selectedPlan => _selectedPlan;
  bool get isProcessing => _isProcessing;
  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isInTrialPeriod => _isInTrialPeriod;
  int get remainingTrialDays => _remainingTrialDays;
  DateTime? get subscriptionStartDate => _subscriptionStartDate;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PaymentProvider() {
    _initializePaymentService();
  }

  Future<void> _initializePaymentService() async {
    try {
      await MercadoPagoService.initialize();
      print('✅ Mercado Pago inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Mercado Pago: $e');
    }
  }

  // Seleccionar plan
  void selectPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  // Procesar suscripción
  Future<Map<String, dynamic>> processSubscription({
    required String userEmail,
    required String userId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Crear preferencia de pago en Mercado Pago
      final preferenceResult =
          await MercadoPagoService.createSubscriptionPreference(
            planId: _selectedPlan.id,
            planName: _selectedPlan.name,
            price: _selectedPlan.priceARS,
            trialDays: _selectedPlan.trialDays,
            userEmail: userEmail,
          );

      if (!preferenceResult['success']) {
        throw Exception(preferenceResult['error']);
      }

      // Guardar información de suscripción en Firestore
      await _saveSubscriptionInfo(
        userId: userId,
        plan: _selectedPlan,
        preferenceId: preferenceResult['preferenceId'],
      );

      _isProcessing = false;
      notifyListeners();

      return {
        'success': true,
        'preferenceId': preferenceResult['preferenceId'],
        'initPoint': preferenceResult['initPoint'],
      };
    } catch (e) {
      _isProcessing = false;
      notifyListeners();

      return {'success': false, 'error': e.toString()};
    }
  }

  // Guardar información de suscripción en Firestore
  Future<void> _saveSubscriptionInfo({
    required String userId,
    required SubscriptionPlan plan,
    required String preferenceId,
  }) async {
    final subscriptionData = {
      'userId': userId,
      'plan': plan.toMap(),
      'preferenceId': preferenceId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('subscriptions')
        .doc(userId)
        .set(subscriptionData, SetOptions(merge: true));
  }

  // Verificar estado de suscripción del usuario
  Future<void> checkUserSubscription(String userId, String userEmail) async {
    try {
      // Verificar en Firestore
      final doc = await _firestore
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final planData = data['plan'] as Map<String, dynamic>;
        final plan = SubscriptionPlan.fromMap(planData);
        final status = data['status'] as String? ?? 'inactive';
        final startDate = (data['startDate'] as Timestamp?)?.toDate();

        _selectedPlan = plan;
        _hasActiveSubscription = status == 'active';
        _subscriptionStartDate = startDate;
        _currentSubscriptionId = data['subscriptionId'] as String?;

        if (_subscriptionStartDate != null) {
          _isInTrialPeriod = plan.isInTrialPeriod(_subscriptionStartDate!);
          _remainingTrialDays = plan.getRemainingTrialDays(
            _subscriptionStartDate!,
          );
        }

        // Si no hay suscripción activa en Firestore, verificar en Mercado Pago
        if (!_hasActiveSubscription) {
          _hasActiveSubscription =
              await MercadoPagoService.checkActiveSubscription(userEmail);
        }
      } else {
        // Verificar directamente en Mercado Pago
        _hasActiveSubscription =
            await MercadoPagoService.checkActiveSubscription(userEmail);
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error verificando suscripción: $e');
    }
  }

  // Actualizar estado de suscripción después del pago
  Future<void> updateSubscriptionStatus({
    required String userId,
    required String status,
    required String paymentId,
    required String subscriptionId,
  }) async {
    try {
      final updateData = {
        'status': status,
        'paymentId': paymentId,
        'subscriptionId': subscriptionId,
        'startDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'active') {
        updateData['trialEndDate'] = Timestamp.fromDate(
          DateTime.now().add(Duration(days: _selectedPlan.trialDays)),
        );
      }

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .set(updateData, SetOptions(merge: true));

      // Actualizar estado local
      _hasActiveSubscription = status == 'active';
      _subscriptionStartDate = DateTime.now();
      _isInTrialPeriod = true;
      _remainingTrialDays = _selectedPlan.trialDays;
      _currentSubscriptionId = subscriptionId;

      notifyListeners();
    } catch (e) {
      print('❌ Error actualizando estado de suscripción: $e');
    }
  }

  // Cancelar suscripción
  Future<Map<String, dynamic>> cancelSubscription(String userId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      if (_currentSubscriptionId != null) {
        final result = await MercadoPagoService.cancelSubscription(
          _currentSubscriptionId!,
        );

        if (result['success']) {
          // Actualizar en Firestore
          await _firestore.collection('subscriptions').doc(userId).update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Actualizar estado local
          _hasActiveSubscription = false;
          _isInTrialPeriod = false;
          _remainingTrialDays = 0;
        }

        _isProcessing = false;
        notifyListeners();
        return result;
      } else {
        throw Exception('No hay suscripción activa para cancelar');
      }
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar si puede agregar más niños
  bool canAddMoreChildren(int currentChildrenCount) {
    if (_hasActiveSubscription && _selectedPlan.id != 'premium') {
      return _selectedPlan.canAddMoreChildren(currentChildrenCount);
    }
    return _hasActiveSubscription || _isInTrialPeriod;
  }

  // Obtener límite de niños
  int getChildrenLimit() {
    if (!_hasActiveSubscription && !_isInTrialPeriod) {
      return 0; // No puede tener niños sin suscripción
    }
    return _selectedPlan.maxChildren;
  }

  // Reiniciar estado (para logout)
  void reset() {
    _selectedPlan = SubscriptionPlan.basic;
    _isProcessing = false;
    _hasActiveSubscription = false;
    _isInTrialPeriod = true;
    _remainingTrialDays = 15;
    _subscriptionStartDate = null;
    _currentSubscriptionId = null;
    notifyListeners();
  }
}
