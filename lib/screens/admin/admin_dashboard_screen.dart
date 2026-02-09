import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import 'manage_tests_appointments_screen.dart';
import 'upload_report_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.listenToAllAppointments();
    dataProvider.listenToAllTests();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    int todayAppointments = 0;
    int pendingAppointments = 0;
    int completedTests = 0;
    int totalAppointments = dataProvider.appointments.length;

    for (int i = 0; i < dataProvider.appointments.length; i++) {
      if (_isToday(dataProvider.appointments[i].appointmentDate)) {
        todayAppointments = todayAppointments + 1;
      }
      if (dataProvider.appointments[i].status == 'pending') {
        pendingAppointments = pendingAppointments + 1;
      }
      if (dataProvider.appointments[i].status == 'completed') {
        completedTests = completedTests + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMetricCard(
                  'Today\'s Appointments',
                  todayAppointments.toString(),
                  Icons.calendar_today,
                  Colors.blue,
                  () {
                    _showAppointmentsDialog('Today\'s Appointments', 'today');
                  },
                ),
                _buildMetricCard(
                  'Pending Appointments',
                  pendingAppointments.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                  () {
                    _showAppointmentsDialog('Pending Appointments', 'pending');
                  },
                ),
                _buildMetricCard(
                  'Completed Tests',
                  completedTests.toString(),
                  Icons.check_circle,
                  Colors.green,
                  () {
                    _showAppointmentsDialog('Completed Tests', 'completed');
                  },
                ),
                _buildMetricCard(
                  'Total Appointments',
                  totalAppointments.toString(),
                  Icons.assignment,
                  Colors.purple,
                  () {
                    _showAppointmentsDialog('All Appointments', 'all');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Manage Tests & Appointments',
              Icons.manage_search,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageTestsAppointmentsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton('Upload Report', Icons.upload_file, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadReportScreen(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAppointmentsDialog(String title, String filter) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    List<dynamic> filteredList = [];

    for (int i = 0; i < dataProvider.appointments.length; i++) {
      var apt = dataProvider.appointments[i];

      if (filter == 'today') {
        if (_isToday(apt.appointmentDate)) {
          filteredList.add(apt);
        }
      } else if (filter == 'pending') {
        if (apt.status == 'pending') {
          filteredList.add(apt);
        }
      } else if (filter == 'completed') {
        if (apt.status == 'completed') {
          filteredList.add(apt);
        }
      } else {
        filteredList.add(apt);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: filteredList.isEmpty
              ? const Center(child: Text('No appointments found'))
              : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    var apt = filteredList[index];
                    return Card(
                      child: ListTile(
                        title: Text(apt.patientName),
                        subtitle: Text('${apt.testName}\n${apt.timeSlot}'),
                        trailing: Chip(
                          label: Text(
                            apt.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: _getStatusColor(apt.status),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') {
      return Colors.orange;
    } else if (status == 'completed') {
      return Colors.green;
    } else if (status == 'cancelled') {
      return Colors.red;
    }
    return Colors.grey;
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return true;
    }
    return false;
  }
}
