import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/lab_test_model.dart';
import '../../core/providers/data_provider.dart';

class ManageTestsAppointmentsScreen extends StatefulWidget {
  const ManageTestsAppointmentsScreen({super.key});

  @override
  State<ManageTestsAppointmentsScreen> createState() =>
      _ManageTestsAppointmentsScreenState();
}

class _ManageTestsAppointmentsScreenState
    extends State<ManageTestsAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _appointmentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tests & Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tests'),
            Tab(text: 'Appointments'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddTestDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTestsTab(), _buildAppointmentsTab()],
      ),
    );
  }

  Widget _buildTestsTab() {
    final dataProvider = Provider.of<DataProvider>(context);
    final tests = dataProvider.tests;

    return tests.isEmpty
        ? const Center(child: Text('No tests available. Tap + to add'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    test.testName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${test.category} • ₹${test.price.toStringAsFixed(0)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditTestDialog(test),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTest(test.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAppointmentsTab() {
    final dataProvider = Provider.of<DataProvider>(context);
    final filteredAppointments = dataProvider.getAppointmentsByStatus(
      _appointmentFilter,
    );

    return Column(
      children: [
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
                            Text(
                              appointment.patientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(appointment.testName),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(appointment.appointmentDate),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.timeSlot,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusChip(appointment.status),
                                if (appointment.status == 'pending')
                                  ElevatedButton(
                                    onPressed: () =>
                                        _completeAppointment(appointment.id),
                                    child: const Text('Complete'),
                                  ),
                              ],
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

  void _showAddTestDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Test'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Test Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final test = LabTestModel(
                  id: '',
                  testName: nameController.text,
                  category: categoryController.text,
                  price: double.parse(priceController.text),
                  description: descriptionController.text,
                  preparationInstructions: '',
                  reportDeliveryHours: 24,
                  isActive: true,
                  createdAt: DateTime.now(),
                );

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final dataProvider = Provider.of<DataProvider>(
                  context,
                  listen: false,
                );
                await dataProvider.addTest(test);

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Test added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTestDialog(LabTestModel test) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: test.testName);
    final categoryController = TextEditingController(text: test.category);
    final priceController = TextEditingController(text: test.price.toString());
    final descriptionController = TextEditingController(text: test.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Test'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Test Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedTest = LabTestModel(
                  id: test.id,
                  testName: nameController.text,
                  category: categoryController.text,
                  price: double.parse(priceController.text),
                  description: descriptionController.text,
                  preparationInstructions: test.preparationInstructions,
                  reportDeliveryHours: test.reportDeliveryHours,
                  isActive: test.isActive,
                  createdAt: test.createdAt,
                );

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final dataProvider = Provider.of<DataProvider>(
                  context,
                  listen: false,
                );
                await dataProvider.updateTest(test.id, updatedTest);

                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Test updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTest(String testId) async {
    final messenger = ScaffoldMessenger.of(context);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test'),
        content: const Text('Are you sure you want to delete this test?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dataProvider.deleteTest(testId);

      messenger.showSnackBar(
        const SnackBar(content: Text('Test deleted successfully')),
      );
    }
  }

  Future<void> _completeAppointment(String appointmentId) async {
    final messenger = ScaffoldMessenger.of(context);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.updateAppointmentStatus(appointmentId, 'completed');

    messenger.showSnackBar(
      const SnackBar(content: Text('Appointment marked as completed')),
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
    );
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}
