import 'dart:convert';

import 'package:driver/model/FoodModel/FoodModel.dart';
import 'package:driver/model/UserAddressModel/UserAddressModel.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/model/restaurantModel/restaurantModel.dart';
import 'package:driver/model/userModel/userModel.dart';

class FoodOrderModel {
  FoodModel foodDetails;
  RestaurantModel restaurantDetails;
  UserAddressModel? userAddress;
  userModel? userData;
  DriverModel? deliveryPartnerData;
  int deliveryCharges;
  String? orderId;
  String? restaurantUId;
  String? userUId;
  String? deliveryGuyUId;
  String? orderStatus;
  DateTime? addedToCartAt;
  DateTime? orderPlacedAt;
  DateTime? orderDeliveredAt;

  FoodOrderModel({
    required this.foodDetails,
    required this.restaurantDetails,
    required this.userAddress,
    required this.userData,
    this.deliveryPartnerData,
    required this.deliveryCharges,
    required this.orderId,
    required this.restaurantUId,
    required this.userUId,
    required this.deliveryGuyUId,
    required this.orderStatus,
    this.addedToCartAt,
    required this.orderPlacedAt,
    this.orderDeliveredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodDetails': foodDetails.toMap(),
      'restaurantDetails': restaurantDetails.toMap(),
      'userAddress': userAddress?.toMap(),
      'userData': userData?.toMap(),
      'deliveryPartnerData': deliveryPartnerData?.toMap(),
      'deliveryCharges': deliveryCharges,
      'orderId': orderId,
      'restaurantUId': restaurantUId,
      'userUId': userUId,
      'orderStatus': orderStatus,
      'addedToCartAt': addedToCartAt?.toIso8601String(),
      'orderPlacedAt': orderPlacedAt?.toIso8601String(),
      'orderDeliveredAt': orderDeliveredAt?.toIso8601String(),
      'deliveryGuyUId': deliveryGuyUId,
    };
  }

  factory FoodOrderModel.fromMap(Map<String, dynamic> map) {
    // Convert nested maps safely to Map<String, dynamic>
    Map<String, dynamic> convertToStringKeyMap(dynamic value) {
      if (value == null) return {};

      // ✅ If it's already a Map
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }

      // 🔥 If it's a List (THIS IS YOUR BUG)
      if (value is List) {
        if (value.isEmpty) return {};

        final firstItem = value.first;

        if (firstItem is Map) {
          return Map<String, dynamic>.from(firstItem);
        }
      }

      // ❌ Unexpected type
      return {};
    }

    return FoodOrderModel(
      foodDetails: FoodModel.fromMap(convertToStringKeyMap(map['foodDetails'])),
      restaurantDetails: RestaurantModel.fromMap(
        convertToStringKeyMap(map['restaurantDetails']),
      ),
      userAddress: map['userAddress'] != null
          ? UserAddressModel.fromMap(convertToStringKeyMap(map['userAddress']))
          : null,
      userData: map['userData'] != null
          ? userModel.fromMap(convertToStringKeyMap(map['userData']))
          : null,
      deliveryPartnerData: map['deliveryPartnerData'] != null
          ? DriverModel.fromMap(
              convertToStringKeyMap(map['deliveryPartnerData']),
            )
          : null,
      deliveryCharges: map['deliveryCharges']?.toInt() ?? 0,
      orderId: map['orderId'] ?? '',
      restaurantUId: map['restaurantUId'] ?? '',
      userUId: map['userUId'] ?? '',
      orderStatus: map['orderStatus'] ?? '',
      addedToCartAt: map['addedToCartAt'] != null
          ? DateTime.tryParse(map['addedToCartAt'].toString())
          : null,
      orderPlacedAt: map['orderPlacedAt'] != null
          ? DateTime.tryParse(map['orderPlacedAt'].toString())
          : null,
      orderDeliveredAt: map['orderDeliveredAt'] != null
          ? DateTime.tryParse(map['orderDeliveredAt'].toString())
          : null,
      deliveryGuyUId: map['deliveryGuyUId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory FoodOrderModel.fromJson(String source) =>
      FoodOrderModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
