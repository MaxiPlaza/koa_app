// lib/core/models/subscription_plan.dart
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double priceUSD;
  final double priceARS;
  final int maxChildren;
  final int trialDays;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceUSD,
    required this.priceARS,
    required this.maxChildren,
    required this.trialDays,
    required this.features,
    this.isPopular = false,
  });

  // Planes disponibles
  static const SubscriptionPlan basic = SubscriptionPlan(
    id: 'basic',
    name: 'Básico',
    description: 'Perfecto para empezar',
    priceUSD: 1.0,
    priceARS: 1000.0,
    maxChildren: 1,
    trialDays: 15,
    features: [
      '1 niño incluido',
      'Actividades básicas',
      'Reportes mensuales',
      'Soporte por email',
    ],
  );

  static const SubscriptionPlan family = SubscriptionPlan(
    id: 'family',
    name: 'Familiar',
    description: 'Ideal para familias',
    priceUSD: 3.0,
    priceARS: 3000.0,
    maxChildren: 3,
    trialDays: 15,
    features: [
      'Hasta 3 niños',
      'Todas las actividades',
      'Reportes semanales',
      'Soporte prioritario',
      'Rutinas personalizadas',
    ],
    isPopular: true,
  );

  static const SubscriptionPlan premium = SubscriptionPlan(
    id: 'premium',
    name: 'Premium',
    description: 'Máxima experiencia',
    priceUSD: 5.0,
    priceARS: 5000.0,
    maxChildren: 10,
    trialDays: 15,
    features: [
      'Hasta 10 niños',
      'Contenido exclusivo',
      'Reportes diarios',
      'Soporte 24/7',
      'AI personalizada',
      'Análisis avanzado',
    ],
  );

  static const List<SubscriptionPlan> allPlans = [basic, family, premium];

  // Métodos de utilidad
  String get formattedPriceARS => '\$${priceARS.toStringAsFixed(0)} ARS';
  String get formattedPriceUSD => '\$$priceUSD USD';

  bool canAddMoreChildren(int currentChildrenCount) {
    return currentChildrenCount < maxChildren;
  }

  bool isInTrialPeriod(DateTime startDate) {
    final trialEnd = startDate.add(Duration(days: trialDays));
    return DateTime.now().isBefore(trialEnd);
  }

  int getRemainingTrialDays(DateTime startDate) {
    final trialEnd = startDate.add(Duration(days: trialDays));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Conversión a/desde Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priceUSD': priceUSD,
      'priceARS': priceARS,
      'maxChildren': maxChildren,
      'trialDays': trialDays,
      'features': features,
      'isPopular': isPopular,
    };
  }

  static SubscriptionPlan fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      priceUSD: (map['priceUSD'] ?? 0.0).toDouble(),
      priceARS: (map['priceARS'] ?? 0.0).toDouble(),
      maxChildren: map['maxChildren'] ?? 0,
      trialDays: map['trialDays'] ?? 0,
      features: List<String>.from(map['features'] ?? []),
      isPopular: map['isPopular'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SubscriptionPlan &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
