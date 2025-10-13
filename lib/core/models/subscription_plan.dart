class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price; // En USD
  final double priceARS; // En pesos argentinos
  final int maxChildren;
  final List<String> features;
  final int trialDays;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceARS,
    required this.maxChildren,
    required this.features,
    this.trialDays = 15,
    this.isPopular = false,
  });

  // Planes predefinidos
  static const SubscriptionPlan basic = SubscriptionPlan(
    id: 'basic',
    name: 'Básico',
    description: 'Perfecto para empezar',
    price: 1.0,
    priceARS: 1000.0, // Conversión aproximada
    maxChildren: 1,
    trialDays: 15,
    features: [
      '1 niño incluido',
      'Juegos básicos',
      'Progreso simple',
      'Soporte por email',
      'Acceso a comunidad',
    ],
  );

  static const SubscriptionPlan family = SubscriptionPlan(
    id: 'family',
    name: 'Familiar',
    description: 'Ideal para familias',
    price: 3.0,
    priceARS: 3000.0,
    maxChildren: 3,
    trialDays: 15,
    isPopular: true,
    features: [
      '3 niños incluidos',
      'Todos los juegos',
      'Reportes básicos',
      'IA básica',
      'Soporte prioritario',
      'Acceso a comunidad',
    ],
  );

  static const SubscriptionPlan premium = SubscriptionPlan(
    id: 'premium',
    name: 'Premium',
    description: 'Para profesionales y familias exigentes',
    price: 5.0,
    priceARS: 5000.0,
    maxChildren: 999, // Ilimitado
    trialDays: 15,
    features: [
      'Niños ilimitados',
      'Contenido completo',
      'IA avanzada',
      'Reportes PDF profesionales',
      'Panel profesional',
      'Soporte premium 24/7',
      'Acceso a comunidad VIP',
    ],
  );

  static List<SubscriptionPlan> get allPlans => [basic, family, premium];

  // Obtener plan por ID
  static SubscriptionPlan getById(String id) {
    return allPlans.firstWhere((plan) => plan.id == id);
  }

  // Verificar si un plan permite agregar más niños
  bool canAddMoreChildren(int currentChildrenCount) {
    return currentChildrenCount < maxChildren;
  }

  // Obtener precio formateado
  String get formattedPriceARS => '\$$priceARS';
  String get formattedPriceUSD => '\$$price';

  // Verificar si está en período de prueba
  bool isInTrialPeriod(DateTime subscriptionStart) {
    return DateTime.now().difference(subscriptionStart).inDays <= trialDays;
  }

  // Días restantes de prueba
  int getRemainingTrialDays(DateTime subscriptionStart) {
    final daysUsed = DateTime.now().difference(subscriptionStart).inDays;
    return trialDays - daysUsed;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'priceARS': priceARS,
      'maxChildren': maxChildren,
      'features': features,
      'trialDays': trialDays,
      'isPopular': isPopular,
    };
  }

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      priceARS: (map['priceARS'] ?? 0.0).toDouble(),
      maxChildren: map['maxChildren'] ?? 1,
      features: List<String>.from(map['features'] ?? []),
      trialDays: map['trialDays'] ?? 15,
      isPopular: map['isPopular'] ?? false,
    );
  }
}
