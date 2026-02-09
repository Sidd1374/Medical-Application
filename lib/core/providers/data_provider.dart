import 'package:flutter/material.dart';
import '../models/lab_test_model.dart';
import '../models/appointment_model.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<LabTestModel> _tests = [];
  List<AppointmentModel> _appointments = [];
  List<ReportModel> _reports = [];
  bool _isTestMode = false;

  List<LabTestModel> get tests => _tests;
  List<AppointmentModel> get appointments => _appointments;
  List<ReportModel> get reports => _reports;
  bool get isTestMode => _isTestMode;

  void clearData() {
    _tests = [];
    _appointments = [];
    _reports = [];
    _isTestMode = false;
    notifyListeners();
  }

  void enterTestMode() {
    _isTestMode = true;
    _tests = [
      LabTestModel(
        id: 't1',
        testName: 'Complete Blood Count (CBC)',
        category: 'Blood',
        price: 250.0,
        description:
            'Measures red & white blood cells, hemoglobin, hematocrit.',
        preparationInstructions: 'Fasting for 8 hours recommended.',
        reportDeliveryHours: 24,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      LabTestModel(
        id: 't2',
        testName: 'Lipid Profile',
        category: 'Blood',
        price: 400.0,
        description: 'Cholesterol, triglycerides, HDL and LDL levels.',
        preparationInstructions: 'Fasting for 12 hours required.',
        reportDeliveryHours: 24,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      LabTestModel(
        id: 't3',
        testName: 'Urine Analysis',
        category: 'Urine',
        price: 150.0,
        description: 'Physical, chemical and microscopic analysis of urine.',
        preparationInstructions: 'Collect midstream sample.',
        reportDeliveryHours: 12,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
    _appointments = [
      AppointmentModel(
        id: 'a1',
        patientId: 'test-user-id',
        patientName: 'Test Patient',
        testId: 't1',
        testName: 'Complete Blood Count (CBC)',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '10:00 AM',
        status: 'pending',
        totalAmount: 250.0,
        paymentStatus: 'pending',
        createdAt: DateTime.now(),
      ),
    ];
    _reports = [
      ReportModel(
        id: 'r1',
        appointmentId: 'a1',
        patientId: 'test-user-id',
        testName: 'Complete Blood Count (CBC)',
        reportUrl: 'https://example.com/sample-report.pdf',
        reportType: 'pdf',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        remarks: 'All values within normal range',
      ),
    ];
    notifyListeners();
  }

  void exitTestMode() {
    _isTestMode = false;
    _tests = [];
    _appointments = [];
    _reports = [];
    notifyListeners();
  }

  List<LabTestModel> getTestsByCategory(String category) {
    if (category == 'All') {
      return _tests;
    }
    List<LabTestModel> filtered = [];
    for (int i = 0; i < _tests.length; i++) {
      if (_tests[i].category == category) {
        filtered.add(_tests[i]);
      }
    }
    return filtered;
  }

  List<AppointmentModel> getAppointmentsByStatus(String status) {
    if (status == 'All') {
      return _appointments;
    }
    List<AppointmentModel> filtered = [];
    for (int i = 0; i < _appointments.length; i++) {
      if (_appointments[i].status == status) {
        filtered.add(_appointments[i]);
      }
    }
    return filtered;
  }

  void listenToActiveTests() {
    if (_isTestMode) return;
    _firestoreService.getActiveTests().listen((testsList) {
      _tests = testsList;
      notifyListeners();
    });
  }

  void listenToAllTests() {
    if (_isTestMode) return;
    _firestoreService.getAllTests().listen((testsList) {
      _tests = testsList;
      notifyListeners();
    });
  }

  void listenToPatientAppointments(String patientId) {
    if (_isTestMode) return;
    _firestoreService.getPatientAppointments(patientId).listen((aptsList) {
      _appointments = aptsList;
      notifyListeners();
    });
  }

  void listenToAllAppointments() {
    if (_isTestMode) return;
    _firestoreService.getAllAppointments().listen((aptsList) {
      _appointments = aptsList;
      notifyListeners();
    });
  }

  void listenToPatientReports(String patientId) {
    if (_isTestMode) return;
    _firestoreService.getPatientReports(patientId).listen((reportsList) {
      _reports = reportsList;
      notifyListeners();
    });
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    if (_isTestMode) {
      _appointments.add(appointment);
      notifyListeners();
      return;
    }
    await _firestoreService.createAppointment(appointment);
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    if (_isTestMode) {
      for (int i = 0; i < _appointments.length; i++) {
        if (_appointments[i].id == appointmentId) {
          AppointmentModel old = _appointments[i];
          _appointments[i] = AppointmentModel(
            id: old.id,
            patientId: old.patientId,
            patientName: old.patientName,
            testId: old.testId,
            testName: old.testName,
            appointmentDate: old.appointmentDate,
            timeSlot: old.timeSlot,
            status: status,
            totalAmount: old.totalAmount,
            paymentStatus: old.paymentStatus,
            createdAt: old.createdAt,
          );
          notifyListeners();
          break;
        }
      }
      return;
    }
    await _firestoreService.updateAppointmentStatus(appointmentId, status);
  }

  Future<void> addTest(LabTestModel test) async {
    if (_isTestMode) {
      _tests.add(test);
      notifyListeners();
      return;
    }
    await _firestoreService.addTest(test);
  }

  Future<void> updateTest(String testId, LabTestModel test) async {
    if (_isTestMode) {
      for (int i = 0; i < _tests.length; i++) {
        if (_tests[i].id == testId) {
          _tests[i] = test;
          notifyListeners();
          break;
        }
      }
      return;
    }
    await _firestoreService.updateTest(testId, test);
  }

  Future<void> deleteTest(String testId) async {
    if (_isTestMode) {
      List<LabTestModel> newList = [];
      for (int i = 0; i < _tests.length; i++) {
        if (_tests[i].id != testId) {
          newList.add(_tests[i]);
        }
      }
      _tests = newList;
      notifyListeners();
      return;
    }
    await _firestoreService.deleteTest(testId);
  }

  Future<void> uploadReport(ReportModel report) async {
    if (_isTestMode) {
      ReportModel newReport = ReportModel(
        id: 'r${_reports.length + 1}',
        appointmentId: report.appointmentId,
        patientId: report.patientId,
        testName: report.testName,
        reportUrl: report.reportUrl,
        reportType: report.reportType,
        uploadedAt: report.uploadedAt,
        remarks: report.remarks,
      );
      _reports.add(newReport);
      notifyListeners();
      return;
    }
    await _firestoreService.uploadReport(report);
  }
}
