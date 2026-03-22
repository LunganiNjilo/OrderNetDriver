import 'dart:convert';

class DriverModel {
  String? name;
  String? profilePicUrl;
  String? mobileNumber;
  String? driverId;
  String? vehicleRegistrationNumber;
  String? drivingLicenseNumber;
  DateTime? registeredDateTime;
  String? activeDeliveryRequestId;
  String? driverStatus;
  String? cloudMessageingToken;

  DriverModel({
    this.name,
    this.profilePicUrl,
    this.mobileNumber,
    this.driverId,
    this.vehicleRegistrationNumber,
    this.drivingLicenseNumber,
    this.registeredDateTime,
    this.activeDeliveryRequestId,
    this.driverStatus,
    this.cloudMessageingToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePicUrl': profilePicUrl,
      'mobileNumber': mobileNumber,
      'driverId': driverId,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'registeredDateTime': registeredDateTime?.toIso8601String(),
      'activeDeliveryRequestId': activeDeliveryRequestId,
      'driverStatus': driverStatus,
      'cloudMessageingToken': cloudMessageingToken,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      name: map['name'],
      profilePicUrl: map['profilePicUrl'],
      mobileNumber: map['mobileNumber'],
      driverId: map['driverId'],
      vehicleRegistrationNumber: map['vehicleRegistrationNumber'],
      drivingLicenseNumber: map['drivingLicenseNumber'],
      registeredDateTime: map['registeredDateTime'] != null
          ? DateTime.tryParse(map['registeredDateTime'].toString())
          : null,
      activeDeliveryRequestId: map['activeDeliveryRequestId'],
      driverStatus: map['driverStatus'],
      cloudMessageingToken: map['cloudMessageingToken'],
    );
  }

  String toJson() => json.encode(toMap());
  factory DriverModel.fromJson(String source) =>
      DriverModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
