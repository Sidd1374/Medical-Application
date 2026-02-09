import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String testName;
  final String reportUrl; // Firebase Storage URL
  final String reportType; // 'pdf' or 'image'
  final DateTime uploadedAt;
  final String remarks;

  ReportModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.testName,
    required this.reportUrl,
    required this.reportType,
    required this.uploadedAt,
    this.remarks = '',
  });

  // From Firestore
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      testName: data['testName'] ?? '',
      reportUrl: data['reportUrl'] ?? '',
      reportType: data['reportType'] ?? 'pdf',
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      remarks: data['remarks'] ?? '',
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'testName': testName,
      'reportUrl': reportUrl,
      'reportType': reportType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'remarks': remarks,
    };
  }
}
