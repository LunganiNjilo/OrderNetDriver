import 'dart:async';
import 'dart:math' as math;

import 'package:driver/controller/services/locationServices/locationService.dart';
import 'package:driver/controller/services/navigationService/mapboxNavigationService.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class RideProvider extends ChangeNotifier {
  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  LatLng? restaurantLocation;
  LatLng? deliveryLocation;
  FoodOrderModel? orderData;
  bool inDelivery = false;

  final MapboxNavigationService _navService = MapboxNavigationService();
  List<LatLng> currentRoute = [];

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
        final snapped = _getClosestPointOnRoute(rawLatLng);

        if (currentPosition != null) {
          finalHeading = _calculateBearing(
            LatLng(currentPosition!.latitude, currentPosition!.longitude),
            snapped,
          );
        }

        // 🔥 LAG KILLER: factor set to 0.8 for near-instant reaction
        finalPosition = _smoothMove(rawLatLng, snapped, 0.8);

        final distance = _calculateDistance(rawLatLng, snapped);
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
    orderData = data;
    restaurantLocation = LatLng(
      data.restaurantDetails.address!.latitude!,
      data.restaurantDetails.address!.longitude!,
    );
    deliveryLocation = LatLng(
      data.userAddress!.latitude!,
      data.userAddress!.longitude!,
    );
    currentPosition ??= await LocationService.getCurrentLocation();
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
    if (route.isEmpty) return;
    currentRoute = route.map((e) => LatLng(e[0], e[1])).toList();
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
    if (route.isEmpty) return;
    currentRoute = route.map((e) => LatLng(e[0], e[1])).toList();
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
}
