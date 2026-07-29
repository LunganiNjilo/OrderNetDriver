import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:driver/view/aboutScreen/aboutScreen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = "";
  String _buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Zippy Driver")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.delivery_dining, size: 45),
            ),

            const SizedBox(height: 20),

            const Text(
              "Zippy Driver",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Driver application for the Zippy delivery platform.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Version"),
              trailing: Text(_version),
            ),

            ListTile(
              leading: const Icon(Icons.numbers),
              title: const Text("Build"),
              trailing: Text(_buildNumber),
            ),

            const Spacer(),

            const Text("© 2026 Zippy", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
