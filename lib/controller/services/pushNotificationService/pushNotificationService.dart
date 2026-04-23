import 'dart:developer';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/services/pushNotificationService/pushNotificationDialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static FirebaseMessaging firebaemessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseMessaging(BuildContext context) async {
    await firebaemessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // REMOVE or MODIFY the 'message.notification != null' check
      // We want the dialogue to trigger if there is DATA (the orderId)
      if (message.data.isNotEmpty) {
        log('Received Data Message: ${message.data}');
        firebaseMessagingForegroundHandler(message, context);
      }

      // If you still want to handle standard notifications
      if (message.notification != null) {
        log('Received Notification: ${message.notification!.title}');
      }
    });
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
      print(message.data['orderId']);
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
      'Driver/${auth.currentUser!.uid}/cloudMessageingToken',
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
