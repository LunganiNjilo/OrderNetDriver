import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:driver/controller/services/orderServices/orderService.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _carIcon;
  double _cameraBearing = 0;
  LatLng? _cameraTarget;
  LatLng? _lastCameraPosition;
  double _lastCameraHeading = 0;

  final DatabaseReference _driverRef = FirebaseDatabase.instance.ref().child(
    'Driver/${auth.currentUser!.uid}',
  );

  @override
  void initState() {
    super.initState();

    BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(96, 96)),
          "assets/icons/car_top.png",
        )
        .then((icon) {
          log("Car icon loaded");
          _carIcon = icon;

          if (mounted) {
            setState(() {});
          }
        })
        .catchError((e) {
          log("Failed to load car icon: $e");
        });

    _driverRef.child('activeDeliveryRequestId').onValue.listen((event) {
      log("ACTIVE DELIVERY REQUEST CHANGED TO: ${event.snapshot.value}");
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().initialize();
    });
  }

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

  bool _isProcessingDelivery = false;

  void _updateCamera(LatLng target, double heading) {
    if (_lastCameraPosition != null) {
      final moved = _distanceMeters(_lastCameraPosition!, target);

      final headingDelta = ((_lastCameraHeading - heading + 540) % 360) - 180;

      if (moved < 1.0 && headingDelta.abs() < 2.0) {
        return;
      }
    }

    _lastCameraPosition = target;
    _lastCameraHeading = heading;

    if (_mapController == null) return;

    _cameraTarget ??= target;
    _cameraTarget = _lerpLatLng(_cameraTarget!, target, 0.55);

    _cameraBearing = _lerpAngle(_cameraBearing, heading, 0.80);

    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _cameraTarget!,
          zoom: 20.5,
          tilt: 72,
          bearing: _cameraBearing,
        ),
      ),
    );
  }

  double _lerpAngle(double from, double to, double t) {
    double delta = ((to - from + 540) % 360) - 180;
    return (from + delta * t + 360) % 360;
  }

  LatLng _lerpLatLng(LatLng from, LatLng to, double t) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const double earthRadius = 6371000.0;

    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;

    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;

    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    return earthRadius * (2 * math.atan2(math.sqrt(h), math.sqrt(1 - h)));
  }

  Widget _buildNavigationHeader() {
    return Consumer<RideProvider>(
      builder: (context, provider, _) {
        if (provider.orderData == null) return const SizedBox();

        final destination = provider.inDelivery
            ? provider.orderData!.userAddress?.streetAddress ?? ""
            : provider.orderData!.restaurantDetails.restaurantName ?? "";

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.navigation, color: Colors.white),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.inDelivery
                              ? "Deliver to customer"
                              : "Navigate to restaurant",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          destination,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnlinePanel() {
    return Consumer<RideProvider>(
      builder: (context, provider, _) {
        if (provider.orderData != null) {
          return const SizedBox();
        }

        return Positioned(
          right: 16,
          bottom: 24,
          child: GestureDetector(
            onTap: () async {
              if (provider.isOnline) {
                await provider.goOffline();
              } else {
                await provider.goOnline();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.power_settings_new,
                    size: 18,
                    color: provider.isOnline ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.isOnline ? "OFFLINE" : "ONLINE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet() {
    return Consumer<RideProvider>(
      builder: (context, provider, _) {
        if (provider.orderData == null) {
          return const SizedBox();
        }

        final pickup = !provider.inDelivery;

        return Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),

            decoration: BoxDecoration(
              color: const Color(0xff161616),
              borderRadius: BorderRadius.circular(20),
            ),

            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup
                              ? provider
                                    .orderData!
                                    .restaurantDetails
                                    .restaurantName!
                              : provider.orderData!.userData!.displayName!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pickup ? "Pickup" : "Delivery",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    width: 140,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pickup ? Colors.orange : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isProcessingDelivery
                          ? null
                          : () async {
                              setState(() {
                                _isProcessingDelivery = true;
                              });

                              try {
                                if (pickup) {
                                  await _handleDeliveryAction(provider);
                                } else {
                                  await _showDeliveryConfirmation(provider);
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isProcessingDelivery = false;
                                  });
                                }
                              }
                            },
                      child: _isProcessingDelivery
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              pickup ? "ARRIVED" : "DELIVER",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDeliveryAction(RideProvider provider) async {
    final bool isAtPickup = !provider.inDelivery;

    String orderId = provider.orderData!.orderId!;

    log("CURRENT DRIVER UID: ${auth.currentUser!.uid}");
    log("COMPLETING ORDER: $orderId");

    final snapshot = await _driverRef.child('activeDeliveryRequestIds').get();

    List<dynamic> activeRequests = [];

    if (snapshot.exists && snapshot.value != null) {
      activeRequests = List<dynamic>.from(snapshot.value as List);
    }

    log("ACTIVE REQUESTS BEFORE CLEANUP: $activeRequests");

    if (isAtPickup) {
      await realTimeDatabaseRef
          .child('Orders/$orderId/orderStatus')
          .set(Orderservice.orderStatus(1));

      await realTimeDatabaseRef.child('Orders/$orderId/isPickedUp').set(true);

      await realTimeDatabaseRef
          .child('Orders/$orderId/driverStatus')
          .set('FOOD_PICKED_UP');

      for (final order in provider.activeOrders ?? []) {
        if (order.restaurantUId == provider.orderData?.restaurantUId) {
          order.isPickedUp = true;
        }
      }

      provider.updateInDeliveryStatus(true);

      await provider.startNavigationToCustomer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✔ Order picked up successfully"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await Orderservice.addOrderDataToHistory(provider.orderData!, context);

      await realTimeDatabaseRef
          .child('Orders/$orderId/orderStatus')
          .set(Orderservice.orderStatus(2));

      await realTimeDatabaseRef
          .child('Orders/$orderId/driverStatus')
          .set('DELIVERED');

      activeRequests.remove(orderId);

      await _driverRef.update({'activeDeliveryRequestIds': activeRequests});

      Orderservice.removeOrder(orderId);

      await provider.moveToNextOrder();

      if (provider.orderData == null) {
        await _driverRef.child('activeDeliveryRequestId').remove();

        await _driverRef.child('activeDeliveryRequestIds').remove();
      } else {
        await _driverRef.update({
          'activeDeliveryRequestId': provider.orderData!.orderId,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✔ Delivery completed successfully"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (_mapController != null && provider.currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                provider.currentPosition!.latitude,
                provider.currentPosition!.longitude,
              ),
              zoom: 15,
              tilt: 0,
              bearing: 0,
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDeliveryConfirmation(RideProvider provider) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Complete Delivery"),
        content: const Text(
          "Confirm that the customer has received the order.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Complete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleDeliveryAction(provider);
    }
  }

  Widget _buildWaitingBanner() {
    return Consumer<RideProvider>(
      builder: (context, provider, _) {
        // Don't show while on a delivery
        if (provider.orderData != null) {
          return const SizedBox();
        }

        // Only show when online
        if (!provider.isOnline) {
          return const SizedBox();
        }

        return Positioned(
          top: 120,
          left: 20,
          right: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delivery_dining, color: Colors.green, size: 36),
                  SizedBox(height: 8),
                  Text(
                    "You're Online",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Waiting for delivery requests...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                Future.microtask(() {
                  _updateCamera(
                    LatLng(pos.latitude, pos.longitude),
                    rideProvider.cameraHeading,
                  );
                });
              }

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-29.8587, 31.0218),
                  zoom: 18,
                ),

                myLocationEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                buildingsEnabled: true,
                trafficEnabled: true,
                indoorViewEnabled: false,

                style: darkMapStyle,

                // FULLSCREEN
                padding: EdgeInsets.zero,

                polylines: _buildPolylines(rideProvider.currentRoute),

                markers: _buildMarkers(rideProvider),

                onMapCreated: (controller) {
                  _mapController = controller;
                },
              );
            },
          ),

          _buildNavigationHeader(),

          _buildWaitingBanner(),

          _buildOnlinePanel(),

          _buildBottomSheet(),
        ],
      ),
    );
  }

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    if (points.isEmpty) return {};

    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: points,
        width: 8,
        color: const Color(0xff2D8CFF),
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Set<Marker> _buildMarkers(RideProvider provider) {
    final Set<Marker> markers = {};

    if (provider.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: LatLng(
            provider.currentPosition!.latitude,
            provider.currentPosition!.longitude,
          ),
          rotation: provider.cameraHeading,
          flat: true,
          anchor: const Offset(0.5, 0.5),

          // We'll replace this with a custom car icon later
          icon: _carIcon ?? BitmapDescriptor.defaultMarker,

          zIndex: 999,
        ),
      );
    }

    // Only destination marker
    final destination = provider.inDelivery
        ? provider.deliveryLocation
        : provider.restaurantLocation;

    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }
}
