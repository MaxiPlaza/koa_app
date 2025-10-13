import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/subscription_plan.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/kova_mascot.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 0;

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
          if (paymentProvider.hasActiveSubscription ||
              paymentProvider.isInTrialPeriod)
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
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 4,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Desbloquea todo el potencial de KOA con una suscripción',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '15 días de prueba gratuita',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
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
                  'Suscripción Activa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Plan: ${paymentProvider.selectedPlan.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (paymentProvider.isInTrialPeriod) ...[
              const SizedBox(height: 4),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...SubscriptionPlan.allPlans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          final isSelected = index == _selectedPlanIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlanIndex = index;
              });
              paymentProvider.selectPlan(plan);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                    : Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              plan.description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                        if (plan.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.orange.shade700,
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      'por mes • ${plan.formattedPriceUSD} USD',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Características
                    ...plan.features
                        .map(
                          (feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              _processSubscription(paymentProvider, authProvider, context),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  paymentProvider.hasActiveSubscription
                      ? 'Cambiar a ${selectedPlan.name}'
                      : 'Comenzar con ${selectedPlan.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedPlan.formattedPriceARS} / mes • 15 días gratis',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
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
          'Tu suscripción se renueva automáticamente cada mes',
          context,
        ),
        _buildInfoItem(
          Icons.cancel,
          'Cancela cuando quieras',
          'Puedes cancelar tu suscripción en cualquier momento',
          context,
        ),
        _buildInfoItem(
          Icons.security,
          'Pago seguro',
          'Tus datos de pago están protegidos con encriptación',
          context,
        ),
        const SizedBox(height: 16),
        Text(
          'Al suscribirte, aceptas nuestros Términos de Servicio y Política de Privacidad',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Procesando tu suscripción...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor no cierres la aplicación',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
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

    final result = await paymentProvider.processSubscription(
      userEmail: user.email,
      userId: user.uid,
    );

    if (result['success']) {
      // Navegar a Mercado Pago
      final initPoint = result['initPoint'];
      if (await canLaunchUrl(Uri.parse(initPoint))) {
        await launchUrl(Uri.parse(initPoint));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error abriendo Mercado Pago')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
    }
  }
}
