import 'dart:async';

import 'package:driver/constant/constant.dart';
import 'package:driver/controller/services/locationServices/locationService.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';

class GeofireService {
  static DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child('Driver/${auth.currentUser!.uid}/driverStatus');

  static StreamSubscription<Position>? _positionStream;

  /// =========================
  /// GO ONLINE
  /// =========================
  static goOnline() async {
    Position currentPosition = await LocationService.getCurrentLocation();

    Geofire.initialize('OnlineDrivers');

    Geofire.setLocation(
      auth.currentUser!.uid,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    databaseReference.set('ONLINE');
  }

  /// =========================
  /// GO OFFLINE
  /// =========================
  static goOffline() {
    Geofire.removeLocation(auth.currentUser!.uid);

    databaseReference.set('OFFLINE');

    _positionStream?.cancel();
  }

  /// =========================
  /// 🔥 REALTIME LOCATION (BACKEND ONLY)
  /// =========================
  static updateLocationRealtime() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    _positionStream?.cancel();

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (event) {
            /// ✅ ONLY update backend (Geofire)
            Geofire.setLocation(
              auth.currentUser!.uid,
              event.latitude,
              event.longitude,
            );

            /// ❌ DO NOT TOUCH RideProvider HERE
          },
        );
  }
}
