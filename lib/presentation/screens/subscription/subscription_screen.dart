// lib/presentation/screens/subscription/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/subscription_plan.dart';
import 'package:koa_app/presentation/providers/payment_provider.dart';
import 'package:koa_app/presentation/providers/auth_provider.dart';
import '../../widgets/common/kova_mascot.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionData();
  }

  void _initializeSubscriptionData() async {
    // Pequeña delay para asegurar que los providers estén listos
    await Future.delayed(const Duration(milliseconds: 500));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final user = authProvider.currentUser!;
      await paymentProvider.checkUserSubscription(
          user.uid,
          userEmail: user.email
      );

      // Sincronizar el índice seleccionado con el plan actual
      final currentPlan = paymentProvider.selectedPlan;
      final index = SubscriptionPlan.allPlans.indexWhere((p) => p.id == currentPlan.id);
      if (index != -1) {
        setState(() {
          _selectedPlanIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildContent(paymentProvider, authProvider, context),
    );
  }

  Widget _buildContent(
      PaymentProvider paymentProvider,
      AuthProvider authProvider,
      BuildContext context,
      ) {
    if (paymentProvider.isProcessing) {
      return _buildProcessingState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 24),

          // Estado actual de suscripción
          if (paymentProvider.hasActiveSubscription || paymentProvider.isInTrialPeriod)
            _buildCurrentSubscriptionStatus(paymentProvider, context),

          const SizedBox(height: 24),

          // Planes de suscripción
          _buildPlansSection(paymentProvider, context),
          const SizedBox(height: 24),

          // Botón de suscripción
          _buildSubscribeButton(paymentProvider, authProvider, context),
          const SizedBox(height: 16),

          // Información adicional
          _buildAdditionalInfo(context),

          // Botón de verificación manual (útil para debugging)
          if (authProvider.currentUser != null) ...[
            const SizedBox(height: 20),
            _buildVerificationButton(paymentProvider, authProvider, context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const KovaMascot(expression: KovaExpression.excited, size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elige tu Plan KOA',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desbloquea todo el potencial de KOA con una suscripción',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '15 días de prueba gratuita',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionStatus(
      PaymentProvider paymentProvider,
      BuildContext context,
      ) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  paymentProvider.isInTrialPeriod ? 'Período de Prueba' : 'Suscripción Activa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Plan: ${paymentProvider.selectedPlan.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (paymentProvider.isInTrialPeriod) ...[
              const SizedBox(height: 6),
              Text(
                'Días restantes de prueba: ${paymentProvider.remainingTrialDays}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Límite de niños: ${paymentProvider.getChildrenLimit()}',
              style: const TextStyle(fontSize: 14),
            ),
            if (paymentProvider.hasActiveSubscription) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showCancelSubscriptionDialog(paymentProvider, context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar Suscripción'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlansSection(
      PaymentProvider paymentProvider,
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige tu Plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el plan que mejor se adapte a tus necesidades',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        ...SubscriptionPlan.allPlans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          final isSelected = index == _selectedPlanIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPlanIndex = index;
                  });
                  paymentProvider.selectPlan(plan);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header del plan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          if (plan.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Precio
                      Text(
                        plan.formattedPriceARS,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'por mes • ${plan.formattedPriceUSD} USD',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Características
                      ...plan.features.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade500,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSubscribeButton(
      PaymentProvider paymentProvider,
      AuthProvider authProvider,
      BuildContext context,
      ) {
    final selectedPlan = SubscriptionPlan.allPlans[_selectedPlanIndex];
    final isSamePlan = paymentProvider.selectedPlan.id == selectedPlan.id;
    final hasActiveSubscription = paymentProvider.hasActiveSubscription;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _processSubscription(paymentProvider, authProvider, context),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    hasActiveSubscription
                        ? isSamePlan
                        ? 'Plan Actual - ${selectedPlan.name}'
                        : 'Cambiar a ${selectedPlan.name}'
                        : 'Comenzar con ${selectedPlan.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${selectedPlan.formattedPriceARS} / mes • 15 días gratis',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasActiveSubscription && isSamePlan) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ya tienes este plan activo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(
          Icons.autorenew,
          'Renovación automática',
          'Tu suscripción se renueva automáticamente cada mes. Puedes cancelar en cualquier momento.',
          context,
        ),
        _buildInfoItem(
          Icons.security,
          'Pago 100% seguro',
          'Tus datos están protegidos con encriptación bancaria. No almacenamos información de tu tarjeta.',
          context,
        ),
        _buildInfoItem(
          Icons.support_agent,
          'Soporte prioritario',
          'Acceso a nuestro equipo de soporte para resolver todas tus dudas.',
          context,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Al suscribirte, aceptas nuestros Términos de Servicio y Política de Privacidad. La prueba gratuita de 15 días se aplica automáticamente a tu primera suscripción.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      IconData icon,
      String title,
      String subtitle,
      BuildContext context,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationButton(
      PaymentProvider paymentProvider,
      AuthProvider authProvider,
      BuildContext context,
      ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final user = authProvider.currentUser;
          if (user != null) {
            await paymentProvider.forceSubscriptionCheck(
                user.uid,
                userEmail: user.email
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Estado de suscripción verificado')),
            );
          }
        },
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Verificar Estado de Suscripción'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Preparando tu suscripción...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Estamos configurando todo para que puedas acceder a Mercado Pago de forma segura.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Serás redirigido a Mercado Pago para completar el pago de forma segura.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processSubscription(
      PaymentProvider paymentProvider,
      AuthProvider authProvider,
      BuildContext context,
      ) async {
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para suscribirte')),
      );
      return;
    }

    final selectedPlan = SubscriptionPlan.allPlans[_selectedPlanIndex];
    final isSamePlan = paymentProvider.selectedPlan.id == selectedPlan.id;

    if (paymentProvider.hasActiveSubscription && isSamePlan) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya tienes el plan ${selectedPlan.name} activo')),
      );
      return;
    }

    final result = await paymentProvider.processSubscription(
      userEmail: user.email!,
      userId: user.uid,
      context: context,
    );

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result['error']}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      // Éxito - el usuario será redirigido a Mercado Pago automáticamente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redirigiendo a Mercado Pago...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCancelSubscriptionDialog(
      PaymentProvider paymentProvider,
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar tu suscripción? '
              'Perderás acceso a todas las funciones premium al final del período actual.\n\n'
              'Podrás volver a suscribirte en cualquier momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantener Suscripción'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelSubscription(paymentProvider, context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar Suscripción'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription(
      PaymentProvider paymentProvider,
      BuildContext context,
      ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    final result = await paymentProvider.cancelSubscription(user.uid);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suscripción cancelada exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result['error']}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}