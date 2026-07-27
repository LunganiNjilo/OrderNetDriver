import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:driver/controller/services/geofireServices/geofireService.dart';
import 'package:driver/controller/services/locationServices/locationService.dart';
import 'package:driver/controller/services/navigationService/mapboxNavigationService.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/services/navigationService/route_snapper.dart';

class RideProvider extends ChangeNotifier {
  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  LatLng? restaurantLocation;
  LatLng? deliveryLocation;
  FoodOrderModel? orderData;
  bool inDelivery = false;
  List<FoodOrderModel>? activeOrders = [];
  FoodOrderModel? focusedOrder;

  bool _isOnline = false;

  bool get isOnline => _isOnline;

  final MapboxNavigationService _navService = MapboxNavigationService();
  List<LatLng> currentRoute = [];
  double _smoothedHeading = 0;
  LatLng? cameraTarget;
  double cameraHeading = 0;
  int _currentSegmentIndex = 0;
  double _vehicleHeading = 0;
  double _cameraHeading = 0;

  Future<void> initialize() async {
    debugPrint("RideProvider.initialize() called");

    final snapshot = await FirebaseDatabase.instance
        .ref("Driver/${auth.currentUser!.uid}/driverStatus")
        .get();

    debugPrint("Firebase status: ${snapshot.value}");

    _isOnline = snapshot.value.toString().toUpperCase() == "ONLINE";

    notifyListeners();
  }

  void startLocationUpdates() {
    positionStream?.cancel();
    WakelockPlus.enable();

    positionStream = LocationService.getLiveLocationStream().listen((
      Position position,
    ) async {
      final rawLatLng = LatLng(position.latitude, position.longitude);
      LatLng finalPosition = rawLatLng;
      double finalHeading = position.heading;

      if (currentRoute.isNotEmpty) {
        final snap = RouteSnapper.snapToRoute(
          rawLatLng,
          currentRoute,
          startIndex: _currentSegmentIndex,
        );

        _currentSegmentIndex = snap.segmentIndex;

        final snapped = snap.point;

        finalPosition = snapped;

        final currentPoint = currentRoute[snap.segmentIndex];

        final nextPoint =
            currentRoute[math.min(
              snap.segmentIndex + 1,
              currentRoute.length - 1,
            )];

        final routeBearing = _calculateBearing(currentPoint, nextPoint);

        // Vehicle follows the route quickly
        _vehicleHeading = _lerpAngle(_vehicleHeading, routeBearing, 0.90);

        // Camera should use the current route bearing directly
        _cameraHeading = routeBearing;

        finalHeading = _vehicleHeading;
        cameraHeading = _cameraHeading;

        final distance = snap.distance * 111139;

        if (distance > 60) {
          inDelivery
              ? await startNavigationToCustomer()
              : await startNavigationToRestaurant();
        }
      }

      currentPosition = Position(
        latitude: finalPosition.latitude,
        longitude: finalPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: finalHeading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        altitudeAccuracy: position.altitudeAccuracy,
        headingAccuracy: position.headingAccuracy,
      );

      notifyListeners();
    });
  }

  double _lerpAngle(double a, double b, double t) {
    double delta = ((b - a + 540) % 360) - 180;
    return (a + delta * t + 360) % 360;
  }

  LatLng _smoothMove(LatLng current, LatLng target, double factor) {
    if (_calculateDistance(current, target) > 100) return target;
    final newLat =
        current.latitude + (target.latitude - current.latitude) * factor;
    final newLng =
        current.longitude + (target.longitude - current.longitude) * factor;
    return LatLng(newLat, newLng);
  }

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = _toRad(start.latitude);
    double lng1 = _toRad(start.longitude);
    double lat2 = _toRad(end.latitude);
    double lng2 = _toRad(end.longitude);
    double dLon = (lng2 - lng1);
    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<void> updateOrderData(
    FoodOrderModel data,
    BuildContext context,
  ) async {
    activeOrders ??= [];

    if (!activeOrders!.any((o) => o.orderId == data.orderId)) {
      activeOrders!.add(data);
    }

    focusedOrder ??= data;
    orderData = focusedOrder;

    restaurantLocation = LatLng(
      focusedOrder!.restaurantDetails.address!.latitude!,
      focusedOrder!.restaurantDetails.address!.longitude!,
    );

    deliveryLocation = LatLng(
      focusedOrder!.userAddress!.latitude!,
      focusedOrder!.userAddress!.longitude!,
    );
    currentPosition ??= await LocationService.getCurrentLocation();

    // GENERATE INITIAL ROUTE
    await startNavigationToRestaurant();
    startLocationUpdates();
    notifyListeners();
  }

  void updateInDeliveryStatus(bool status) {
    inDelivery = status;
    notifyListeners();
  }

  Future<void> startNavigationToRestaurant() async {
    if (currentPosition == null || restaurantLocation == null) return;
    final route = await _navService.getRoute(
      startLat: currentPosition!.latitude,
      startLng: currentPosition!.longitude,
      endLat: restaurantLocation!.latitude,
      endLng: restaurantLocation!.longitude,
    );
    debugPrint("Route points count: ${route.length}");
    if (route.isEmpty) return;
    currentRoute = route.map((e) => LatLng(e[0], e[1])).toList();
    _currentSegmentIndex = 0;
    notifyListeners();
  }

  Future<void> startNavigationToCustomer() async {
    if (currentPosition == null || deliveryLocation == null) return;
    final route = await _navService.getRoute(
      startLat: currentPosition!.latitude,
      startLng: currentPosition!.longitude,
      endLat: deliveryLocation!.latitude,
      endLng: deliveryLocation!.longitude,
    );
    debugPrint("Route points count: ${route.length}");
    if (route.isEmpty) return;
    currentRoute = route.map((e) => LatLng(e[0], e[1])).toList();
    _currentSegmentIndex = 0;
    notifyListeners();
  }

  LatLng _getClosestPointOnRoute(LatLng current) {
    if (currentRoute.isEmpty) return current;
    double minDistance = double.infinity;
    LatLng closest = currentRoute.first;
    for (var point in currentRoute) {
      final dist = _calculateDistance(current, point);
      if (dist < minDistance) {
        minDistance = dist;
        closest = point;
      }
    }
    return closest;
  }

  int _getClosestRouteIndex(LatLng current) {
    if (currentRoute.isEmpty) return 0;

    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < currentRoute.length; i++) {
      final dist = _calculateDistance(current, currentRoute[i]);

      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const double R = 6371000;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final aCalc =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(a.latitude)) *
            math.cos(_toRad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return R * (2 * math.atan2(math.sqrt(aCalc), math.sqrt(1 - aCalc)));
  }

  double _toRad(double value) => value * (math.pi / 180);

  void stopLocationUpdates() {
    WakelockPlus.disable();
    positionStream?.cancel();
    positionStream = null;
  }

  Future<void> goOnline() async {
    if (_isOnline) return;

    _isOnline = true;

    await GeofireService.goOnline();
    await GeofireService.updateLocationRealtime();

    startLocationUpdates();

    notifyListeners();
  }

  Future<void> goOffline() async {
    if (!_isOnline) return;

    _isOnline = false;

    GeofireService.goOffline();

    stopLocationUpdates();

    notifyListeners();
  }

  Future<void> moveToNextOrder() async {
    if (activeOrders == null || activeOrders!.isEmpty) {
      focusedOrder = null;
      orderData = null;
      currentRoute = [];
      notifyListeners();
      return;
    }

    activeOrders!.removeWhere((o) => o.orderId == focusedOrder?.orderId);

    if (activeOrders!.isEmpty) {
      focusedOrder = null;
      orderData = null;
      currentRoute = [];
      notifyListeners();
      return;
    }

    focusedOrder = activeOrders!.first;
    orderData = focusedOrder;

    log(
      "NEXT ORDER PICKUP STATUS: ${focusedOrder?.orderId} | ${focusedOrder?.isPickedUp}",
    );

    if (focusedOrder?.isPickedUp == true) {
      deliveryLocation = LatLng(
        focusedOrder!.userAddress!.latitude!,
        focusedOrder!.userAddress!.longitude!,
      );

      inDelivery = true;

      await startNavigationToCustomer();

      notifyListeners();

      return;
    }

    restaurantLocation = LatLng(
      focusedOrder!.restaurantDetails.address!.latitude!,
      focusedOrder!.restaurantDetails.address!.longitude!,
    );

    deliveryLocation = LatLng(
      focusedOrder!.userAddress!.latitude!,
      focusedOrder!.userAddress!.longitude!,
    );

    inDelivery = false;

    await startNavigationToRestaurant();

    notifyListeners();
  }
}
