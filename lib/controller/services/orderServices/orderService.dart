import 'dart:convert';
import 'dart:developer';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:driver/controller/services/toastService/toastMessageService.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Orderservice {
  static Future<FoodOrderModel> fetchOrderDetails(String orderId) async {
    try {
      var snapshot = await realTimeDatabaseRef.child('Orders/$orderId').get();

      final rawData = snapshot.value;

      log("TYPE: ${rawData.runtimeType}");
      log("DATA: $rawData");

      if (rawData == null) {
        throw Exception("Order not found");
      }

      Map<String, dynamic> mapData;

      // ✅ HANDLE LIST (your current case)
      if (rawData is List) {
        if (rawData.isEmpty) {
          throw Exception("Order list is empty");
        }

        final item = rawData.first;

        if (item is Map) {
          mapData = Map<String, dynamic>.from(item);
        } else {
          throw Exception("List item is not a Map: ${item.runtimeType}");
        }
      }
      // ✅ HANDLE MAP (future-proof)
      else if (rawData is Map) {
        mapData = Map<String, dynamic>.from(rawData);
      }
      // ❌ UNKNOWN STRUCTURE
      else {
        throw Exception("Unexpected type: ${rawData.runtimeType}");
      }

      return FoodOrderModel.fromMap(mapData);
    } catch (e, stack) {
      log("ERROR: $e");
      log("STACK: $stack");
      rethrow; // 👈 IMPORTANT: don't wrap it again, keeps real error
    }
  }

  static updateDiverProfileIntoFoodOrderModelAndAddActiveDeliveryRequest(
    String orderId,
    BuildContext context,
  ) async {
    DriverModel deliveryPartnerData = context
        .read<ProfileProvider>()
        .deliveryGuyProfile!;
    realTimeDatabaseRef
        .child('Orders/$orderId/deliveryPartnerData')
        .set(deliveryPartnerData.toMap());
    realTimeDatabaseRef
        .child('Driver/${auth.currentUser!.uid}/activeDeliveryRequestId')
        .set(orderId);
  }

  static orderStatus(int status) {
    switch (status) {
      case 0:
        return 'FOOD_UNDER_PREPARATION';
      case 1:
        return 'FOOD_PICKED_UP_BY_DELIVERY_PARTNER';
      case 2:
        'FOOD_DELIVERED';
    }
  }

  static addOrderDataToHistory(
    FoodOrderModel foodOrderData,
    BuildContext context,
  ) async {
    FoodOrderModel foodData = FoodOrderModel(
      foodDetails: foodOrderData.foodDetails,
      deliveryCharges: foodOrderData.deliveryCharges,
      restaurantDetails: foodOrderData.restaurantDetails,
      userAddress: foodOrderData.userAddress,
      userData: foodOrderData.userData,
      deliveryPartnerData: foodOrderData.deliveryPartnerData,
      orderId: foodOrderData.orderId,
      restaurantUId: foodOrderData.restaurantUId,
      userUId: foodOrderData.userUId,
      deliveryGuyUId: auth.currentUser!.uid,
      orderStatus: foodOrderData.orderStatus,
      orderPlacedAt: foodOrderData.orderPlacedAt,
      orderDeliveredAt: DateTime.now(),
    );

    String orderHistoryId = uuid.v1();

    await realTimeDatabaseRef
        .child('OrderHistory/$orderHistoryId')
        .set(foodData.toMap())
        .then((value) {
          ToastService.sendScaffoldAlert(
            msg: 'Order Record Added to History',
            toastStatus: 'SUCCESS',
            context: context,
          );
        })
        .catchError((error, stackTrace) {
          ToastService.sendScaffoldAlert(
            msg: 'Opps! Error Adding Order Record',
            toastStatus: 'ERROR',
            context: context,
          );
        });
  }

  static removeOrder(String orderId) {
    realTimeDatabaseRef.child('Orders/$orderId').remove();
  }
}
