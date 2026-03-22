import 'dart:convert';
import 'package:driver/model/address/address.dart';

class RestaurantModel {
  String? restaurantName;
  String? restaurantLicenseNumber;
  String? restaurantUId;
  List<String>? bannerImages;
  AddressModel? address;
  String? cloudMessageingToken;

  RestaurantModel({
    this.restaurantName,
    this.restaurantLicenseNumber,
    this.restaurantUId,
    this.bannerImages,
    this.address,
    this.cloudMessageingToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'restaurantName': restaurantName,
      'restaurantLicenseNumber': restaurantLicenseNumber,
      'restaurantUId': restaurantUId,
      'bannerImages': bannerImages,
      'address': address?.toMap(),
      'cloudMessageingToken': cloudMessageingToken,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> convertToStringKeyMap(dynamic value) {
      if (value == null) return {};
      return Map<String, dynamic>.from(value as Map);
    }

    return RestaurantModel(
      restaurantName: map['restaurantName'] as String?,
      restaurantLicenseNumber: map['restaurantLicenseNumber'] as String?,
      restaurantUId: map['restaurantUId'] as String?,
      bannerImages: map['bannerImages'] != null
          ? List<String>.from(map['bannerImages'] as List)
          : null,
      address: map['address'] != null
          ? AddressModel.fromMap(convertToStringKeyMap(map['address']))
          : null,
      cloudMessageingToken: map['cloudMessageingToken'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantModel.fromJson(String source) =>
      RestaurantModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
