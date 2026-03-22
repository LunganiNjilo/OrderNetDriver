import 'dart:convert';

class UserAddressModel {
  String addressId;
  String userId;
  double latitude;
  double longitude;
  String roomNo;
  String apartment;
  String addressTitle;
  DateTime uploadTime;
  bool isActive;

  UserAddressModel({
    required this.userId,
    required this.addressId,
    required this.latitude,
    required this.longitude,
    required this.roomNo,
    required this.apartment,
    required this.addressTitle,
    required this.uploadTime,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'addressId': addressId,
      'latitude': latitude,
      'longitude': longitude,
      'roomNo': roomNo,
      'apartment': apartment,
      'addressTitle': addressTitle,
      'uploadTime': uploadTime?.toIso8601String(),
      'isActive': isActive,
    };
  }

  static UserAddressModel fromMap(Map<String, dynamic> map) {
    return UserAddressModel(
      userId: map['userId'] != null ? map['userId'] as String : '',
      addressId: map['addressId'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      roomNo: map['roomNo'] ?? '',
      apartment: map['apartment'] ?? '',
      addressTitle: map['addressTitle'] ?? '',
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
