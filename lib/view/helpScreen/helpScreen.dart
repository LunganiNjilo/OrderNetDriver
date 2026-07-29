import 'package:driver/view/reportProblemScreen/reportProblemScreen.dart';
import 'package:flutter/material.dart';
import 'package:driver/view/contactSupportScreen/contactSupportScreen.dart';
import 'package:driver/view/aboutScreen/aboutScreen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Contact Support"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text("Report a Problem"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About Zippy Driver"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
