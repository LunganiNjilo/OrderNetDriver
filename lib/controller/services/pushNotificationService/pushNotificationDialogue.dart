import 'dart:developer';
import 'package:driver/controller/provider/orderProvider/orderProvider.dart';
import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:driver/controller/services/locationServices/locationService.dart';
import 'package:driver/controller/services/orderServices/orderService.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationDialogue {
  /// 🔥 PREVENT MULTIPLE DIALOGS
  static bool _isDialogOpen = false;

  static Future<void> deliveryRequestDialogue(
    String orderId,
    BuildContext context,
  ) async {
    /// 🚫 STOP DUPLICATE POPUPS
    if (_isDialogOpen) {
      log("Dialog already open, skipping...");
      return;
    }

    _isDialogOpen = true;

    try {
      FoodOrderModel foodOrderData = await Orderservice.fetchOrderDetails(
        orderId,
      );

      /// ⚠️ SAFETY CHECK
      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false, // 🔥 VERY IMPORTANT
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("New Delivery Request"),

            /// 🔥 SHOW REAL INFO (better UX)
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
                  Navigator.pop(dialogContext);
                },
                child: const Text("Decline"),
              ),

              /// ✅ ACCEPT
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  try {
                    Position pos = await LocationService.getCurrentLocation();

                    LatLng restaurant = LatLng(
                      foodOrderData.restaurantDetails.address!.latitude!,
                      foodOrderData.restaurantDetails.address!.longitude!,
                    );

                    LatLng delivery = LatLng(
                      foodOrderData.userAddress!.latitude!,
                      foodOrderData.userAddress!.longitude!,
                    );

                    final rideProvider = context.read<RideProvider>();

                    /// 🔥 SET STATE CLEANLY
                    rideProvider.updateCurrentPosition(pos);
                    rideProvider.restaurantLocation = restaurant;
                    rideProvider.deliveryLocation = delivery;

                    rideProvider.updateOrderData(foodOrderData);
                    rideProvider.updateInDeliveryStatus(false);

                    /// 🔥 LOAD ROUTE
                    await rideProvider.fetchCrrLoationToRestaurantPolyline(
                      context,
                    );

                    /// 🔥 UPDATE ORDER PROVIDER
                    context.read<OrderProvider>().updateFoodOrderData(
                      foodOrderData,
                    );
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
      /// 🔥 RESET FLAG AFTER CLOSE
      _isDialogOpen = false;
    }
  }
}
