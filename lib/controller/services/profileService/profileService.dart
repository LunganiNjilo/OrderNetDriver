import 'dart:convert';
import 'dart:developer';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/services/toastService/toastMessageService.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ProfileServices {
  static registerDriver(DriverModel driverData, BuildContext context) async {
    realTimeDatabaseRef
        .child('Driver/${auth.currentUser!.uid}')
        .set(driverData.toMap())
        .then((value) {
          // Set initial driverStatus to OFFLINE
          realTimeDatabaseRef
              .child('Driver/${auth.currentUser!.uid}/driverStatus')
              .set('OFFLINE');

          ToastService.sendScaffoldAlert(
            msg: 'Registered Successful',
            toastStatus: 'SUCCESS',
            context: context,
          );
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: const SignInLogicScreen(),
              type: PageTransitionType.rightToLeft,
            ),
            (route) => false,
          );
        })
        .catchError((error, stackTrace) {
          ToastService.sendScaffoldAlert(
            msg: 'Opps! Error getting Registered',
            toastStatus: 'ERROR',
            context: context,
          );

          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: const SignInLogicScreen(),
              type: PageTransitionType.rightToLeft,
            ),
            (route) => false,
          );
        });
  }

  static Future<bool> checkForRegistration() async {
    try {
      final snapshot = await realTimeDatabaseRef
          .child('Driver/${auth.currentUser!.uid}')
          .get();
      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static getDeliveryPartnerProfileData() async {
    try {
      final snapshot = await realTimeDatabaseRef
          .child('Driver/${auth.currentUser!.uid}')
          .get();

      if (snapshot.exists) {
        final Map<String, dynamic> data = jsonDecode(
          jsonEncode(snapshot.value),
        );
        DriverModel deliveryPartnerData = DriverModel.fromMap(data);
        return deliveryPartnerData;
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
