import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactService {
  static Future<void> contactCustomer(
    BuildContext context,
    String? phoneNumber,
  ) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer phone number unavailable.")),
      );
      return;
    }

    final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    final whatsappUri = Uri.parse(
      "whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent("Hi, I'm your Zippy driver.")}",
    );

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      await launchUrl(phoneUri);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Unable to contact customer.")),
    );
  }
}
