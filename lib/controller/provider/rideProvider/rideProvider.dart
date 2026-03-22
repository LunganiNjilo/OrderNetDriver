import 'dart:async';
import 'dart:developer';
import 'package:driver/controller/services/directionServices/directionService.dart';
import 'package:driver/controller/services/orderServices/orderService.dart';
import 'package:driver/model/directionModel/directionModel.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideProvider extends ChangeNotifier {
  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  LatLng? deliveryGuyLocation;
  LatLng? restaurantLocation;
  LatLng? deliveryLocation;

  GoogleMapController? mapController;

  Set<Polyline> polylineSetTowardsRestaurant = {};
  Set<Polyline> polylineSetTowardsDelivery = {};
  Set<Marker> deliveryMarker = {};

  FoodOrderModel? orderData;
  bool inDelivery = false;

  String distanceText = "";
  String durationText = "";

  BitmapDescriptor? vehicleIcon;

  /// 🔥 ROUTE ANIMATION
  List<LatLng> routePoints = [];
  int routeIndex = 0;
  Timer? routeAnimationTimer;

  bool hasArrived = false;
  bool isNavigating = false;

  /// =========================
  /// INIT ICON
  /// =========================
  Future<void> initVehicleIcon() async {
    if (vehicleIcon != null) return;

    vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      'assets/scooter.png',
    );
  }

  /// =========================
  /// LIVE TRACKING (LIGHT USE)
  /// =========================
  void startLiveTracking(BuildContext context) async {
    await initVehicleIcon();

    positionStream?.cancel();

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          currentPosition = position;
        });
  }

  /// =========================
  /// 🔥 ROUTE-BASED MOVEMENT
  /// =========================
  void startRouteAnimation(BuildContext context) {
    routeAnimationTimer?.cancel();

    if (routePoints.isEmpty) return;

    /// 🔥 ENABLE NAVIGATION MODE
    isNavigating = true;

    routeIndex = 0;
    hasArrived = false;

    routeAnimationTimer = Timer.periodic(const Duration(milliseconds: 80), (
      timer,
    ) {
      if (routeIndex >= routePoints.length - 1) {
        timer.cancel();
        _onArrival(context);
        return;
      }

      LatLng current = routePoints[routeIndex];
      LatLng next = routePoints[routeIndex + 1];

      double bearing = Geolocator.bearingBetween(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );

      deliveryGuyLocation = current;

      updateDriverMarker(rotation: bearing);

      mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: current, zoom: 17, tilt: 50, bearing: bearing),
        ),
      );

      routeIndex++;
    });
  }

  /// =========================
  /// ARRIVAL
  /// =========================
  void _onArrival(BuildContext context) {
    if (hasArrived) return;

    hasArrived = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inDelivery ? "Arrived at customer" : "Arrived at restaurant",
        ),
      ),
    );
  }

  /// =========================
  /// MARKERS
  /// =========================
  void updateDriverMarker({double rotation = 0}) {
    if (deliveryGuyLocation == null) return;

    Set<Marker> markers = {};

    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: deliveryGuyLocation!,
        rotation: rotation,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon:
            vehicleIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    LatLng? target = inDelivery ? deliveryLocation : restaurantLocation;

    if (target != null) {
      markers.add(
        Marker(markerId: const MarkerId('destination'), position: target),
      );
    }

    deliveryMarker = markers;
    notifyListeners();
  }

  /// =========================
  /// POLYLINE
  /// =========================
  Polyline decodePolyline(String encodedPolyline) {
    List<PointLatLng> data = PolylinePoints.decodePolyline(encodedPolyline);

    routePoints = data.map((e) => LatLng(e.latitude, e.longitude)).toList();

    return Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 6,
      points: routePoints,
    );
  }

  /// =========================
  /// ROUTES
  /// =========================
  Future<void> fetchCrrLoationToRestaurantPolyline(BuildContext context) async {
    if (currentPosition == null || restaurantLocation == null) return;

    DirectionModel directionDetails =
        await DirectionService.getDirectionDetails(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
          restaurantLocation!,
          context,
        );

    distanceText = directionDetails.distanceInKM;
    durationText = directionDetails.durationInHour;

    polylineSetTowardsRestaurant = {
      decodePolyline(directionDetails.polylinePoints),
    };

    notifyListeners();

    /// 🔥 START REAL MOVEMENT
    startRouteAnimation(context);
  }

  Future<void> fetchResturantToDeliveryPolyline(BuildContext context) async {
    if (restaurantLocation == null || deliveryLocation == null) return;

    DirectionModel directionDetails =
        await DirectionService.getDirectionDetails(
          restaurantLocation!,
          deliveryLocation!,
          context,
        );

    distanceText = directionDetails.distanceInKM;
    durationText = directionDetails.durationInHour;

    polylineSetTowardsDelivery = {
      decodePolyline(directionDetails.polylinePoints),
    };

    notifyListeners();

    /// 🔥 START REAL MOVEMENT
    startRouteAnimation(context);
  }

  /// =========================
  /// BASIC FUNCTIONS
  /// =========================
  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void updateInDeliveryStatus(bool status) {
    inDelivery = status;
    notifyListeners();
  }

  void updateOrderData(FoodOrderModel data) {
    orderData = data;

    restaurantLocation = LatLng(
      data.restaurantDetails.address!.latitude!,
      data.restaurantDetails.address!.longitude!,
    );

    deliveryLocation = LatLng(
      data.userAddress!.latitude!,
      data.userAddress!.longitude!,
    );

    notifyListeners();
  }

  void stopLiveTracking() {
    positionStream?.cancel();
    routeAnimationTimer?.cancel();
  }

  void updateCurrentPosition(Position position) {
    /// 🔥 BLOCK during navigation
    if (isNavigating) return;

    currentPosition = position;

    deliveryGuyLocation = LatLng(position.latitude, position.longitude);

    updateDriverMarker(rotation: position.heading);

    notifyListeners();
  }

  void nullifyRidesDates() {
    stopLiveTracking();

    deliveryMarker.clear();
    polylineSetTowardsRestaurant.clear();
    polylineSetTowardsDelivery.clear();

    routePoints.clear();

    deliveryLocation = null;
    restaurantLocation = null;
    orderData = null;

    notifyListeners();
  }
}
