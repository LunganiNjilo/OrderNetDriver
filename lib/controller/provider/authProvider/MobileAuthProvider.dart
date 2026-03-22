import 'package:flutter/material.dart';

class MobileAuthprovider extends ChangeNotifier {
  String? mobileNumber;
  String? verificationId;
  updateVerificationId(String verification) {
    verificationId = verification;
    notifyListeners();
  }

  updateMobileNumber(String number) {
    mobileNumber = number;
    notifyListeners();
  }
}
