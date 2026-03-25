import 'dart:async';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:driver/controller/services/geofireServices/geofireService.dart';
import 'package:driver/controller/services/orderServices/orderService.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> googleMapController = Completer();
  GoogleMapController? mapController;

  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(-29.8587, 31.0218),
    zoom: 14,
  );

  static DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child('Driver/${auth.currentUser!.uid}');

  /// 🔥 GOOGLE MAPS NAVIGATION (fallback)
  Future<void> openGoogleMapsNavigation(double lat, double lng) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            /// =========================
            /// MAIN CONTENT
            /// =========================
            Column(
              children: [
                /// ===== DRIVER STATUS =====
                Container(
                  height: 10.h,
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  child: StreamBuilder(
                    stream: databaseReference.onValue,
                    builder: (context, event) {
                      if (!event.hasData ||
                          event.data!.snapshot.value == null) {
                        return Center(
                          child: CircularProgressIndicator(color: black),
                        );
                      }

                      final value = event.data!.snapshot.value;

                      String driverStatus = "OFFLINE";
                      String? activeDeliveryRequestId;

                      if (value is Map) {
                        final map = Map<String, dynamic>.from(value);
                        final driverData = DriverModel.fromMap(map);

                        activeDeliveryRequestId =
                            driverData.activeDeliveryRequestId;
                        driverStatus = driverData.driverStatus ?? "OFFLINE";
                      }

                      if (activeDeliveryRequestId == null ||
                          activeDeliveryRequestId.isEmpty) {
                        return driverStatus == "ONLINE"
                            ? SwipeButton(
                                thumb: Icon(Icons.chevron_left, color: white),
                                inactiveThumbColor: black,
                                inactiveTrackColor: greyShade3,
                                onSwipe: () {
                                  GeofireService.goOffline();
                                },
                                child: Text('Done for Today'),
                              )
                            : SwipeButton(
                                thumb: Icon(Icons.chevron_left, color: white),
                                inactiveThumbColor: black,
                                inactiveTrackColor: greyShade3,
                                onSwipe: () {
                                  GeofireService.goOnline();

                                  /// 🔥 FIXED
                                  GeofireService.updateLocationRealtime();
                                },
                                child: Text('Go Online'),
                              );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                /// ===== MAP =====
                Expanded(
                  child: Consumer<RideProvider>(
                    builder: (context, rideProvider, child) {
                      return GoogleMap(
                        initialCameraPosition: initialCameraPosition,
                        myLocationEnabled: true,
                        compassEnabled: true,
                        myLocationButtonEnabled: false,

                        /// 🔥 THIS MAKES IT FEEL LIKE NAVIGATION
                        padding: const EdgeInsets.only(bottom: 250),

                        /// 🔥 MARKERS
                        markers: rideProvider.deliveryMarker,

                        /// 🔥 POLYLINES
                        polylines: rideProvider.inDelivery
                            ? rideProvider.polylineSetTowardsDelivery
                            : rideProvider.polylineSetTowardsRestaurant,

                        /// 🔥 MAP INIT
                        onMapCreated: (controller) async {
                          if (!googleMapController.isCompleted) {
                            googleMapController.complete(controller);
                          }

                          mapController = controller;

                          rideProvider.setMapController(controller);

                          /// 🔥 START REAL NAVIGATION
                          rideProvider.startLiveTracking(context);

                          /// ❌ REMOVED static camera movement
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            /// =========================
            /// 🔥 NAVIGATION BUTTON
            /// =========================
            Positioned(
              bottom: 20,
              right: 20,
              child: Consumer<RideProvider>(
                builder: (context, rideProvider, _) {
                  final isPickup =
                      rideProvider.orderData?.orderStatus ==
                      Orderservice.orderStatus(0);

                  final target = isPickup
                      ? rideProvider.restaurantLocation
                      : rideProvider.deliveryLocation;

                  if (target == null) return const SizedBox();

                  return FloatingActionButton(
                    backgroundColor: Colors.black,
                    child: const Icon(Icons.navigation, color: Colors.white),
                    onPressed: () {
                      openGoogleMapsNavigation(
                        target.latitude,
                        target.longitude,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
