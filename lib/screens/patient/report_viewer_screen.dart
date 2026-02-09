import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/report_model.dart';

class ReportViewerScreen extends StatelessWidget {
  final ReportModel report;

  const ReportViewerScreen({super.key, required this.report});

  Future<void> _openReport() async {
    final uri = Uri.parse(report.reportUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.testName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _openReport,
            tooltip: 'Open Report',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                report.testName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (report.remarks.isNotEmpty) ...[
                Text(
                  report.remarks,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openReport,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Firebase Storage is not configured.\nReport URL will open in browser.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
