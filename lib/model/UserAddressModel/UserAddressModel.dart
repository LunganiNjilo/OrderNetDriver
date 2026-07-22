import 'dart:convert';

class UserAddressModel {
  String addressId;
  String userId;
  double latitude;
  double longitude;
  String streetAddress;
  String suburb;
  String city;
  String province;
  String postalCode;
  DateTime uploadTime;
  bool isActive;

  UserAddressModel({
    required this.userId,
    required this.addressId,
    required this.latitude,
    required this.longitude,
    required this.streetAddress,
    required this.suburb,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.uploadTime,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'addressId': addressId,
      'latitude': latitude,
      'longitude': longitude,
      'streetAddress': streetAddress,
      'suburb': suburb,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'uploadTime': uploadTime?.toIso8601String(),
      'isActive': isActive,
    };
  }

  static UserAddressModel fromMap(Map<String, dynamic> map) {
    return UserAddressModel(
      userId: map['userId'] != null ? map['userId'] as String : '',
      addressId: map['addressId'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      streetAddress: map['streetAddress'] ?? '',
      suburb: map['suburb'] ?? '',
      city: map['city'] ?? '',
      province: map['province'] ?? '',
      postalCode: map['postalCode'] ?? '',
      uploadTime: map['uploadTime'] is DateTime
          ? map['uploadTime']
          : DateTime.tryParse(map['uploadTime'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAddressModel.fromJson(String source) =>
      UserAddressModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
