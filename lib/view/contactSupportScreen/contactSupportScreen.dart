import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Support")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need help?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "If you're experiencing an issue while delivering, our support team is here to help.",
            ),

            const SizedBox(height: 30),

            const Text(
              "Email",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            SelectableText(
              "support@zippy.co.za",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 30),

            const Text(
              "Support Hours",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            const Text("Monday - Friday"),

            const Text("08:00 - 17:00"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text("Copy Email"),
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: "support@zippy.co.za"),
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Email copied to clipboard"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
