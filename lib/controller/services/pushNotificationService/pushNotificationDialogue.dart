import 'dart:developer';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/provider/orderProvider/orderProvider.dart';
import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:driver/controller/services/orderServices/orderService.dart';
import 'package:driver/controller/services/profileService/profileService.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PushNotificationDialogue {
  static bool _isDialogOpen = false;

  static Future<void> deliveryRequestDialogue(
    String orderId,
    BuildContext context,
  ) async {
    if (_isDialogOpen) {
      log("Dialog already open, skipping...");
      return;
    }

    _isDialogOpen = true;

    try {
      /// 🔥 CHECK DRIVER STATE
      DriverModel driver =
          await ProfileServices.getDeliveryPartnerProfileData();

      if (driver.activeDeliveryRequestId != null &&
          driver.activeDeliveryRequestId!.isNotEmpty) {
        log("Driver already busy");
        return;
      }

      /// 🔊 PLAY ALERT SOUND
      await audioPlayer.setAsset('assets/sounds/alert.mp3');
      audioPlayer.play();

      /// 🔥 FETCH ORDER
      FoodOrderModel foodOrderData = await Orderservice.fetchOrderDetails(
        orderId,
      );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("New Delivery Request"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pickup: ${foodOrderData.restaurantDetails.restaurantName}",
                ),
                const SizedBox(height: 8),
                Text("Drop: ${foodOrderData.userAddress?.apartment ?? ''}"),
              ],
            ),

            actions: [
              /// ❌ DECLINE
              TextButton(
                onPressed: () {
                  audioPlayer.stop();
                  Navigator.pop(dialogContext);
                },
                child: const Text("Decline"),
              ),

              /// ✅ ACCEPT
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  try {
                    final rideProvider = context.read<RideProvider>();

                    /// 🔥 BACKEND UPDATE (IMPORTANT)
                    await Orderservice.updateDiverProfileIntoFoodOrderModelAndAddActiveDeliveryRequest(
                      orderId,
                      context,
                    );

                    /// 🔥 SET ORDER DATA + LOAD ROUTE
                    await rideProvider.updateOrderData(foodOrderData, context);

                    /// 🔥 START IN PICKUP MODE
                    rideProvider.updateInDeliveryStatus(false);

                    /// 🔥 UPDATE ORDER STATE
                    context.read<OrderProvider>().updateFoodOrderData(
                      foodOrderData,
                    );

                    audioPlayer.stop();
                  } catch (e) {
                    log("Accept error: $e");
                  }
                },
                child: const Text("Accept"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      log("Dialog error: $e");
    } finally {
      _isDialogOpen = false;
    }
  }
}
