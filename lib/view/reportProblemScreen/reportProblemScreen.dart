import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:driver/controller/services/supportServices/supportService.dart';
import 'package:driver/model/supportRequestModel/supportRequestModel.dart';
import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:provider/provider.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupportService _supportService = SupportService();
  bool _isSubmitting = false;

  final List<String> _categories = [
    "Order Issue",
    "Payment Issue",
    "Navigation Issue",
    "Restaurant Issue",
    "App Bug",
    "Other",
  ];

  String _selectedCategory = "Order Issue";

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final profileProvider = context.read<ProfileProvider>();

    final driver = profileProvider.deliveryGuyProfile;

    if (driver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load your profile.")),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the problem.")),
      );
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    final request = SupportRequestModel(
      app: "driver",
      driverId: driver.driverId ?? "",
      driverName: driver.name ?? "",
      mobileNumber: driver.mobileNumber ?? "",
      category: _selectedCategory,
      message: _messageController.text.trim(),
      status: "OPEN",
      appVersion: packageInfo.version,
      createdAt: Timestamp.now(),
    );

    try {
      await _supportService.submitSupportRequest(request);

      if (!mounted) return;

      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your report has been submitted."),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    if (!mounted) return;

    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Your report has been submitted."),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report a Problem")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Describe the problem",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Tell us what happened...",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Submit Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
