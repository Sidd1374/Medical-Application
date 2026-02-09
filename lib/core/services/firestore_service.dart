import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lab_test_model.dart';
import '../models/appointment_model.dart';
import '../models/report_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LabTestModel>> getActiveTests() {
    try {
      return _firestore
          .collection('labTests')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
            List<LabTestModel> tests = [];
            for (int i = 0; i < snapshot.docs.length; i++) {
              tests.add(LabTestModel.fromFirestore(snapshot.docs[i]));
            }
            return tests;
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Stream<List<LabTestModel>> getAllTests() {
    try {
      return _firestore.collection('labTests').snapshots().map((snapshot) {
        List<LabTestModel> tests = [];
        for (int i = 0; i < snapshot.docs.length; i++) {
          tests.add(LabTestModel.fromFirestore(snapshot.docs[i]));
        }
        return tests;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> addTest(LabTestModel test) async {
    try {
      await _firestore.collection('labTests').add(test.toFirestore());
    } catch (e) {
      throw Exception('Failed to add test. Please try again.');
    }
  }

  Future<void> updateTest(String testId, LabTestModel test) async {
    try {
      await _firestore
          .collection('labTests')
          .doc(testId)
          .update(test.toFirestore());
    } catch (e) {
      throw Exception('Failed to update test. Please try again.');
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _firestore.collection('labTests').doc(testId).delete();
    } catch (e) {
      throw Exception('Failed to delete test. Please try again.');
    }
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .add(appointment.toFirestore());
    } catch (e) {
      throw Exception('Failed to create appointment. Please try again.');
    }
  }

  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    try {
      return _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) {
            List<AppointmentModel> appointments = [];
            for (int i = 0; i < snapshot.docs.length; i++) {
              appointments.add(
                AppointmentModel.fromFirestore(snapshot.docs[i]),
              );
            }
            return appointments;
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Stream<List<AppointmentModel>> getAllAppointments() {
    try {
      return _firestore.collection('appointments').snapshots().map((snapshot) {
        List<AppointmentModel> appointments = [];
        for (int i = 0; i < snapshot.docs.length; i++) {
          appointments.add(AppointmentModel.fromFirestore(snapshot.docs[i]));
        }
        return appointments;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update appointment. Please try again.');
    }
  }

  Future<void> uploadReport(ReportModel report) async {
    try {
      await _firestore.collection('testReports').add(report.toFirestore());
    } catch (e) {
      throw Exception('Failed to upload report. Please try again.');
    }
  }

  Stream<List<ReportModel>> getPatientReports(String patientId) {
    try {
      return _firestore
          .collection('testReports')
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .map((snapshot) {
            List<ReportModel> reports = [];
            for (int i = 0; i < snapshot.docs.length; i++) {
              reports.add(ReportModel.fromFirestore(snapshot.docs[i]));
            }
            return reports;
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Stream<List<ReportModel>> getAllReports() {
    try {
      return _firestore.collection('testReports').snapshots().map((snapshot) {
        List<ReportModel> reports = [];
        for (int i = 0; i < snapshot.docs.length; i++) {
          reports.add(ReportModel.fromFirestore(snapshot.docs[i]));
        }
        return reports;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> getAllPatients() {
    try {
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .snapshots()
          .map((snapshot) {
            List<Map<String, dynamic>> patients = [];
            for (int i = 0; i < snapshot.docs.length; i++) {
              Map<String, dynamic> data = snapshot.docs[i].data();
              data['id'] = snapshot.docs[i].id;
              patients.add(data);
            }
            return patients;
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<int> getPatientAppointmentCount(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
