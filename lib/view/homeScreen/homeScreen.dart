import 'dart:async';
import 'dart:math' as math;
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
  GoogleMapController? _mapController;
  final DatabaseReference _driverRef = FirebaseDatabase.instance.ref().child(
    'Driver/${auth.currentUser!.uid}',
  );

  String darkMapStyle = '''[
  { "elementType": "geometry", "stylers": [{ "color": "#212121" }] },
  { "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#757575" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#212121" }] },
  { "featureType": "administrative", "elementType": "geometry", "stylers": [{ "color": "#757575" }] },
  { "featureType": "poi", "elementType": "geometry", "stylers": [{ "color": "#181818" }] },
  { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": "#2c2c2c" }] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "color": "#3c3c3c" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#000000" }] }
]''';

  void _updateCamera(LatLng pos, double heading) {
    if (_mapController == null || heading.isNaN) return;

    final provider = Provider.of<RideProvider>(context, listen: false);

    // 🔥 FIX: If no active order, don't use 3D tilt/offset. Use a standard 2D view.
    if (provider.orderData == null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: pos, zoom: 15, tilt: 0, bearing: 0),
        ),
      );
      return;
    }

    // Active Navigation View (3D)
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _calculateTarget(pos, heading),
          zoom: 18.5,
          tilt: 65,
          bearing: heading,
        ),
      ),
    );
  }

  LatLng _calculateTarget(LatLng pos, double heading) {
    const double forwardOffset = 0.00075;
    final double bearingRad = heading * (math.pi / 180);
    return LatLng(
      pos.latitude + forwardOffset * math.cos(bearingRad),
      pos.longitude + forwardOffset * math.sin(bearingRad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Consumer<RideProvider>(
            builder: (context, rideProvider, _) {
              final pos = rideProvider.currentPosition;
              if (pos != null) {
                Future.microtask(
                  () => _updateCamera(
                    LatLng(pos.latitude, pos.longitude),
                    pos.heading,
                  ),
                );
              }

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-29.8587, 31.0218),
                  zoom: 14,
                ),
                myLocationEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                style: darkMapStyle,
                padding: EdgeInsets.only(bottom: 30.h, top: 10.h),
                polylines: _buildPolylines(rideProvider.currentRoute),
                markers: _buildMarkers(rideProvider),
                onMapCreated: (controller) {
                  _mapController = controller;
                  rideProvider.startLocationUpdates();
                },
              );
            },
          ),
          _buildTopToggle(),
          _buildDeliveryPanel(),
        ],
      ),
    );
  }

  Widget _buildTopToggle() {
    return Positioned(
      top: 6.h,
      left: 5.w,
      right: 5.w,
      child: StreamBuilder(
        stream: _driverRef.onValue,
        builder: (context, event) {
          if (!event.hasData || event.data!.snapshot.value == null)
            return const SizedBox();
          final dataMap = Map<String, dynamic>.from(
            event.data!.snapshot.value as Map,
          );
          final driver = DriverModel.fromMap(dataMap);

          if (driver.activeDeliveryRequestId?.isNotEmpty ?? false)
            return const SizedBox();

          bool isOnline = driver.driverStatus == "ONLINE";

          return SwipeButton(
            height: 6.h,
            activeThumbColor: isOnline ? Colors.redAccent : Colors.cyanAccent,
            activeTrackColor: Colors.white10,
            thumb: Icon(
              isOnline ? Icons.power_settings_new : Icons.bolt,
              color: Colors.black,
            ),
            child: Text(
              isOnline ? "GO OFFLINE" : "GO ONLINE",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onSwipe: () {
              if (isOnline) {
                GeofireService.goOffline();
                context.read<RideProvider>().stopLocationUpdates();
              } else {
                GeofireService.goOnline();
                GeofireService.updateLocationRealtime();
                context.read<RideProvider>().startLocationUpdates();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDeliveryPanel() {
    return Consumer<RideProvider>(
      builder: (context, provider, _) {
        if (provider.orderData == null) return const SizedBox();
        bool isAtPickup = !provider.inDelivery;

        return Positioned(
          bottom: 2.h,
          left: 4.w,
          right: 4.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () async {
                  final target = isAtPickup
                      ? provider.restaurantLocation
                      : provider.deliveryLocation;
                  if (target != null) {
                    await launchUrl(
                      Uri.parse(
                        "google.navigation:q=${target.latitude},${target.longitude}&mode=d",
                      ),
                    );
                  }
                },
                child: const Icon(Icons.navigation, color: Colors.black),
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    const BoxShadow(color: Colors.black45, blurRadius: 20),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isAtPickup ? "RESTAURANT PICKUP" : "CUSTOMER DELIVERY",
                      style: const TextStyle(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    SwipeButton(
                      thumb: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 18,
                      ),
                      activeThumbColor: isAtPickup
                          ? Colors.orangeAccent
                          : Colors.greenAccent,
                      activeTrackColor: Colors.white.withOpacity(0.05),
                      child: Text(
                        isAtPickup ? "CONFIRM PICKUP" : "FINISH DELIVERY",
                        style: TextStyle(
                          color: isAtPickup
                              ? Colors.orangeAccent
                              : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSwipe: () async {
                        String orderId = provider.orderData!.orderId!;
                        if (isAtPickup) {
                          await realTimeDatabaseRef
                              .child('Orders/$orderId/orderStatus')
                              .set(Orderservice.orderStatus(1));
                          provider.updateInDeliveryStatus(true);
                          await provider.startNavigationToCustomer();
                        } else {
                          // 🔥 DELIVERY FINISHED - START CLEANUP
                          await Orderservice.addOrderDataToHistory(
                            provider.orderData!,
                            context,
                          );
                          await realTimeDatabaseRef
                              .child('Orders/$orderId/orderStatus')
                              .set(Orderservice.orderStatus(2));
                          await _driverRef
                              .child('activeDeliveryRequestId')
                              .set("");

                          Orderservice.removeOrder(orderId);

                          // Reset Provider State
                          provider.orderData = null;
                          provider.currentRoute = []; // Clears polyline
                          provider.updateInDeliveryStatus(false);

                          // Reset Camera to 2D bird's eye
                          if (_mapController != null &&
                              provider.currentPosition != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    provider.currentPosition!.latitude,
                                    provider.currentPosition!.longitude,
                                  ),
                                  zoom: 15.0,
                                  tilt: 0,
                                  bearing: 0,
                                ),
                              ),
                            );
                          }
                          provider.notifyListeners();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    if (points.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: points,
        color: Colors.cyanAccent,
        width: 5,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _buildMarkers(RideProvider provider) {
    Set<Marker> markers = {};
    if (provider.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: LatLng(
            provider.currentPosition!.latitude,
            provider.currentPosition!.longitude,
          ),
          rotation: provider.currentPosition!.heading,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );
    }
    // Only show destination marker if order is active
    if (provider.orderData != null) {
      final dest = !provider.inDelivery
          ? provider.restaurantLocation
          : provider.deliveryLocation;
      if (dest != null) {
        markers.add(
          Marker(
            markerId: const MarkerId("destination"),
            position: dest,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              provider.inDelivery
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    }
    return markers;
  }
}
