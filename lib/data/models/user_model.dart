import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType; // 'parent', 'professional', 'child'
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionPlan? subscription;
  final List<String> childrenIds;
  final List<String> professionalIds;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    this.subscription,
    this.childrenIds = const [],
    this.professionalIds = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'parent',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      subscription: map['subscription'] != null
          ? SubscriptionPlan.fromMap(map['subscription'])
          : null,
      childrenIds: List<String>.from(map['childrenIds'] ?? []),
      professionalIds: List<String>.from(map['professionalIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'subscription': subscription?.toMap(),
      'childrenIds': childrenIds,
      'professionalIds': professionalIds,
    };
  }
}

class SubscriptionPlan {
  final String planType; // 'basic', 'family', 'premium'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double price;

  SubscriptionPlan({
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.price,
  });

  // Método para verificar si está en periodo de prueba
  bool get isInTrialPeriod {
    return startDate.add(const Duration(days: 15)).isAfter(DateTime.now());
  }

  // Días restantes de prueba
  int get remainingTrialDays {
    final trialEnd = startDate.add(const Duration(days: 15));
    return trialEnd.difference(DateTime.now()).inDays;
  }

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      planType: map['planType'] ?? 'basic',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planType': planType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'price': price,
    };
  }
}
