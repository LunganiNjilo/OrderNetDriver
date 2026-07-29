import 'package:cloud_firestore/cloud_firestore.dart';

class SupportRequestModel {
  final String app;
  final String driverId;
  final String driverName;
  final String mobileNumber;
  final String category;
  final String message;
  final String status;
  final String appVersion;
  final Timestamp createdAt;

  SupportRequestModel({
    required this.app,
    required this.driverId,
    required this.driverName,
    required this.mobileNumber,
    required this.category,
    required this.message,
    required this.status,
    required this.appVersion,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'app': app,
      'driverId': driverId,
      'driverName': driverName,
      'mobileNumber': mobileNumber,
      'category': category,
      'message': message,
      'status': status,
      'appVersion': appVersion,
      'createdAt': createdAt,
    };
  }
}
