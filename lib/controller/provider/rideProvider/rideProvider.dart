import 'dart:async';
import 'dart:math';
import 'package:driver/controller/services/directionServices/directionService.dart';
import 'package:driver/controller/services/locationServices/locationService.dart';
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

  double _lastBearing = 0;

  /// =========================
  /// START LIVE TRACKING (FAST)
  /// =========================
  void startLiveTracking(BuildContext context) {
    positionStream?.cancel();

    positionStream = LocationService.getLiveLocationStream().listen((
      Position position,
    ) {
      currentPosition = position;

      LatLng latLng = LatLng(position.latitude, position.longitude);

      /// 🔥 REAL-TIME BEARING (movement-based)
      double bearing;
      if (deliveryGuyLocation != null) {
        bearing = _calculateBearing(deliveryGuyLocation!, latLng);
      } else {
        bearing = position.heading;
      }

      deliveryGuyLocation = latLng;

      updateDriverMarker(rotation: bearing);

      _moveCameraInstant(latLng, bearing);

      notifyListeners();
    });
  }

  /// =========================
  /// CAMERA (NO LAG)
  /// =========================
  void _moveCameraInstant(LatLng driverLocation, double bearing) {
    if (mapController == null) return;

    final cameraPosition = CameraPosition(
      target: driverLocation,
      zoom: 19.5, // 🔥 stable
      tilt: 65, // 🔥 not too aggressive
      bearing: bearing,
    );

    mapController!.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  /// =========================
  /// BEARING FROM MOVEMENT
  /// =========================
  double _calculateBearing(LatLng start, LatLng end) {
    double lat = (end.latitude - start.latitude);
    double lng = (end.longitude - start.longitude);

    return atan2(lng, lat) * (180 / pi);
  }

  /// =========================
  /// ROUTE (UNCHANGED)
  /// =========================
  Future<void> _updateRoute(BuildContext context) async {
    if (currentPosition == null) return;

    LatLng currentLatLng = LatLng(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

    LatLng? target = inDelivery ? deliveryLocation : restaurantLocation;

    if (target == null) return;

    try {
      DirectionModel directionDetails =
          await DirectionService.getDirectionDetails(
            currentLatLng,
            target,
            context,
          );

      List<PointLatLng> decoded = PolylinePoints.decodePolyline(
        directionDetails.polylinePoints,
      );

      List<LatLng> points = decoded
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      Set<Polyline> polyline = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 6,
          points: points,
        ),
      };

      if (inDelivery) {
        polylineSetTowardsDelivery = polyline;
      } else {
        polylineSetTowardsRestaurant = polyline;
      }

      notifyListeners();
    } catch (e) {
      print("Route error: $e");
    }
  }

  /// =========================
  /// ORDER DATA
  /// =========================
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

    if (currentPosition == null) {
      currentPosition = await LocationService.getCurrentLocation();
    }

    await _updateRoute(context);

    notifyListeners();
  }

  /// =========================
  /// MARKERS (VISIBLE + RED)
  /// =========================
  void updateDriverMarker({double rotation = 0}) {
    if (deliveryGuyLocation == null) return;

    deliveryMarker = {
      Marker(
        markerId: const MarkerId('driver'),
        position: deliveryGuyLocation!,
        rotation: rotation,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        zIndex: 999,

        /// 🔥 BACK TO RED + BIGGER FEEL
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      if ((inDelivery ? deliveryLocation : restaurantLocation) != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: inDelivery ? deliveryLocation! : restaurantLocation!,
        ),
    };
  }

  /// =========================
  /// BASIC
  /// =========================
  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void updateInDeliveryStatus(bool status) {
    inDelivery = status;
    notifyListeners();
  }

  void stopLiveTracking() {
    positionStream?.cancel();
  }

  void nullifyRidesDates() {
    stopLiveTracking();

    deliveryMarker.clear();
    polylineSetTowardsRestaurant.clear();
    polylineSetTowardsDelivery.clear();

    deliveryLocation = null;
    restaurantLocation = null;
    orderData = null;

    notifyListeners();
  }
}
