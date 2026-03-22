import 'dart:developer';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/provider/authProvider/MobileAuthProvider.dart';
import 'package:driver/controller/services/profileService/profileService.dart';
import 'package:driver/controller/services/pushNotificationService/pushNotificationService.dart';
import 'package:driver/view/authScreens/mobileLoginScreen.dart';
import 'package:driver/view/authScreens/otpScreen.dart';
import 'package:driver/view/bottomNavigationBar/bottomNavigationBar.dart';
import 'package:driver/view/driverRegistration/driverRegistrationScreen.dart';
import 'package:driver/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MobileAuthServices {
  static bool checkAuthentication(BuildContext context) {
    User? user = auth.currentUser;
    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MobileLoginScreen()),
        (route) => false,
      );
      return false;
    }

    checkUserRegistration(context: context);

    return true;
  }

  static receiveOTP({
    required BuildContext context,
    required String mobileNo,
  }) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: mobileNo,
        verificationCompleted: (PhoneAuthCredential credentials) {
          log(
            'Verification completed: ${credentials.toString()}',
            name: 'PhoneAuth',
          );
          ;
        },
        verificationFailed: (FirebaseAuthException exception) {
          log(exception.toString());
        },
        codeSent: (String verification, int? resendToken) {
          context.read<MobileAuthprovider>().updateVerificationId(verification);
          Navigator.push(
            context,
            PageTransition(
              child: const OTPScreen(),
              type: PageTransitionType.rightToLeft,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {},
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static verifyOTP({required BuildContext context, required String otp}) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: context.read<MobileAuthprovider>().verificationId!,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
      Navigator.push(
        context,
        PageTransition(
          child: const SignInLogicScreen(),
          type: PageTransitionType.rightToLeft,
        ),
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static checkUserRegistration({required BuildContext context}) async {
    try {
      bool isUserRegistered = await ProfileServices.checkForRegistration();
      if (isUserRegistered) {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: const BottomNavigationBarEats(),
            type: PageTransitionType.rightToLeft,
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: const DriverRegistrationScreen(),
            type: PageTransitionType.rightToLeft,
          ),
          (route) => false,
        );
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
