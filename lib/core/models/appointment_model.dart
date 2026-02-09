import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String testId;
  final String testName;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double totalAmount;
  final String paymentStatus; // 'pending', 'confirmed'
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.testId,
    required this.testName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
  });

  // From Firestore
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      testId: data['testId'] ?? '',
      testName: data['testName'] ?? '',
      appointmentDate:
          (data['appointmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'pending',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'testId': testId,
      'testName': testName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': status,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
