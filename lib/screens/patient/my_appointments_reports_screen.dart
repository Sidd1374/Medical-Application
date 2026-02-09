import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import 'report_viewer_screen.dart';

class MyAppointmentsReportsScreen extends StatefulWidget {
  final int initialTab;

  const MyAppointmentsReportsScreen({super.key, this.initialTab = 0});

  @override
  State<MyAppointmentsReportsScreen> createState() =>
      _MyAppointmentsReportsScreenState();
}

class _MyAppointmentsReportsScreenState
    extends State<MyAppointmentsReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _appointmentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    dataProvider.listenToPatientAppointments(authProvider.userId!);
    dataProvider.listenToPatientReports(authProvider.userId!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments & Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Appointments'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Appointments tab
          _buildAppointmentsTab(dataProvider),

          // Reports tab
          _buildReportsTab(dataProvider),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(DataProvider dataProvider) {
    final filteredAppointments = dataProvider.getAppointmentsByStatus(
      _appointmentFilter,
    );

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: ['All', 'pending', 'completed', 'cancelled'].map((
              filter,
            ) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter == 'All' ? filter : _capitalize(filter)),
                  selected: _appointmentFilter == filter,
                  onSelected: (selected) {
                    setState(() => _appointmentFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Appointments list
        Expanded(
          child: filteredAppointments.isEmpty
              ? const Center(child: Text('No appointments found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    appointment.testName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildStatusChip(appointment.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(appointment.appointmentDate),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(appointment.timeSlot),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${appointment.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(DataProvider dataProvider) {
    final reports = dataProvider.reports;

    return reports.isEmpty
        ? const Center(child: Text('No reports available yet'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.description,
                    size: 40,
                    color: Colors.blue,
                  ),
                  title: Text(
                    report.testName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(report.uploadedAt),
                      ),
                      if (report.remarks.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          report.remarks,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReportViewerScreen(report: report),
                        ),
                      );
                    },
                    child: const Text('View'),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        _capitalize(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}
