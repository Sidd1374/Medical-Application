import 'package:cloud_firestore/cloud_firestore.dart';

class LabTestModel {
  final String id;
  final String testName;
  final String category;
  final double price;
  final String description;
  final String preparationInstructions;
  final int reportDeliveryHours;
  final bool isActive;
  final DateTime createdAt;

  LabTestModel({
    required this.id,
    required this.testName,
    required this.category,
    required this.price,
    required this.description,
    required this.preparationInstructions,
    required this.reportDeliveryHours,
    required this.isActive,
    required this.createdAt,
  });

  // From Firestore
  factory LabTestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LabTestModel(
      id: doc.id,
      testName: data['testName'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      preparationInstructions: data['preparationInstructions'] ?? '',
      reportDeliveryHours: data['reportDeliveryHours'] ?? 24,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'testName': testName,
      'category': category,
      'price': price,
      'description': description,
      'preparationInstructions': preparationInstructions,
      'reportDeliveryHours': reportDeliveryHours,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
