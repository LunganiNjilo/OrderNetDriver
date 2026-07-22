import 'dart:developer';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/services/pushNotificationService/pushNotificationDialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static FirebaseMessaging firebaemessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseMessaging(BuildContext context) async {
    log("========== FCM INITIALIZATION START ==========");

    final settings = await firebaemessaging.requestPermission();

    log("Permission Status: ${settings.authorizationStatus}");

    final token = await firebaemessaging.getToken();
    log("Current Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔥🔥🔥 FCM RECEIVED 🔥🔥🔥");
      log("Message ID: ${message.messageId}");
      log("Notification: ${message.notification}");
      log("Data: ${message.data}");

      if (message.data.isNotEmpty) {
        firebaseMessagingForegroundHandler(message, context);
      }
    });

    log("========== FCM INITIALIZATION COMPLETE ==========");
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {}

  static Future<void> firebaseMessagingForegroundHandler(
    RemoteMessage message,
    BuildContext context,
  ) async {
    print(message.data.toString());

    try {
      print('The message data is');
      print(message.data.toString());
      log("FCM ORDER ID: ${message.data['orderId']}");
      PushNotificationDialogue.deliveryRequestDialogue(
        message.data['orderId'],
        context,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  static Future getDeviceToken() async {
    String? deviceToken = await firebaemessaging.getToken();
    print('FCM token : \n$deviceToken');
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child(
      'Driver/${auth.currentUser!.uid}/cloudMessagingToken',
    );

    databaseReference.set(deviceToken);
  }

  static subscribeToNotification() {
    firebaemessaging.subscribeToTopic('DELIVERY_PARTNER');
  }

  static initializeFCM(BuildContext context) async {
    await initializeFirebaseMessaging(context);
    await getDeviceToken();
  }
}
