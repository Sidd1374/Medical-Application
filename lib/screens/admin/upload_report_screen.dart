import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/report_model.dart';
import '../../core/providers/data_provider.dart';

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedPatientId;
  String? _selectedAppointmentId;
  String? _selectedTestName;

  @override
  void dispose() {
    _urlController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getPatientsList(DataProvider dataProvider) {
    List<Map<String, String>> patients = [];
    List<String> addedIds = [];

    for (int i = 0; i < dataProvider.appointments.length; i++) {
      String patientId = dataProvider.appointments[i].patientId;
      String patientName = dataProvider.appointments[i].patientName;

      bool alreadyAdded = false;
      for (int j = 0; j < addedIds.length; j++) {
        if (addedIds[j] == patientId) {
          alreadyAdded = true;
          break;
        }
      }

      if (alreadyAdded == false) {
        addedIds.add(patientId);
        patients.add({'id': patientId, 'name': patientName});
      }
    }
    return patients;
  }

  List<Map<String, String>> _getAppointmentsForPatient(
    DataProvider dataProvider,
    String patientId,
  ) {
    List<Map<String, String>> appointments = [];

    for (int i = 0; i < dataProvider.appointments.length; i++) {
      if (dataProvider.appointments[i].patientId == patientId) {
        appointments.add({
          'id': dataProvider.appointments[i].id,
          'testName': dataProvider.appointments[i].testName,
          'status': dataProvider.appointments[i].status,
        });
      }
    }
    return appointments;
  }

  Future<void> _uploadReport() async {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    if (_selectedAppointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient and appointment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    ReportModel report = ReportModel(
      id: '',
      appointmentId: _selectedAppointmentId!,
      patientId: _selectedPatientId!,
      testName: _selectedTestName!,
      reportUrl: _urlController.text.trim(),
      reportType: 'pdf',
      uploadedAt: DateTime.now(),
      remarks: _remarksController.text.trim(),
    );

    try {
      await dataProvider.uploadReport(report);
      await dataProvider.updateAppointmentStatus(
        _selectedAppointmentId!,
        'completed',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedPatientId = null;
        _selectedAppointmentId = null;
        _selectedTestName = null;
        _urlController.clear();
        _remarksController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    List<Map<String, String>> patients = _getPatientsList(dataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Patient:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPatientId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose a patient',
                ),
                items: patients.map((patient) {
                  return DropdownMenuItem<String>(
                    value: patient['id'],
                    child: Text(patient['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPatientId = value;
                    _selectedAppointmentId = null;
                    _selectedTestName = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a patient';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (_selectedPatientId != null) ...[
                const Text(
                  'Select Test/Appointment:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedAppointmentId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose a test',
                  ),
                  items:
                      _getAppointmentsForPatient(
                        dataProvider,
                        _selectedPatientId!,
                      ).map((apt) {
                        return DropdownMenuItem<String>(
                          value: apt['id'],
                          child: Text('${apt['testName']} (${apt['status']})'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAppointmentId = value;
                      List<Map<String, String>> apts =
                          _getAppointmentsForPatient(
                            dataProvider,
                            _selectedPatientId!,
                          );
                      for (int i = 0; i < apts.length; i++) {
                        if (apts[i]['id'] == value) {
                          _selectedTestName = apts[i]['testName'];
                          break;
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a test';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Report URL:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: 'Enter report URL or file link',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter report URL';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Remarks (Optional):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add any notes or comments about the report',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _uploadReport,
                    icon: const Icon(Icons.upload),
                    label: const Text(
                      'Upload Report',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],

              if (_selectedPatientId == null) ...[
                const SizedBox(height: 40),
                const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select a patient first to see their appointments and upload a report.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
