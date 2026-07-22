import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteSnapResult {
  final LatLng point;
  final int segmentIndex;
  final double distance;

  const RouteSnapResult({
    required this.point,
    required this.segmentIndex,
    required this.distance,
  });
}

class RouteSnapper {
  static RouteSnapResult snapToRoute(
    LatLng gps,
    List<LatLng> route, {
    int startIndex = 0,
  }) {
    if (route.length < 2) {
      return RouteSnapResult(
        point: gps,
        segmentIndex: 0,
        distance: double.infinity,
      );
    }

    double bestDistance = double.infinity;
    LatLng bestPoint = route.first;
    int bestSegment = 0;

    final searchStart = math.max(0, startIndex - 5);
    final searchEnd = math.min(route.length - 2, startIndex + 30);

    for (int i = searchStart; i <= searchEnd; i++) {
      final projected = _project(gps, route[i], route[i + 1]);
      final distance = _distance(gps, projected);

      if (distance < bestDistance) {
        bestDistance = distance;
        bestPoint = projected;
        bestSegment = i;
      }
    }

    return RouteSnapResult(
      point: bestPoint,
      segmentIndex: bestSegment,
      distance: bestDistance,
    );
  }

  static LatLng _project(LatLng p, LatLng a, LatLng b) {
    final ax = a.longitude;
    final ay = a.latitude;

    final bx = b.longitude;
    final by = b.latitude;

    final px = p.longitude;
    final py = p.latitude;

    final abx = bx - ax;
    final aby = by - ay;

    final abSquared = abx * abx + aby * aby;

    if (abSquared == 0) return a;

    double t = ((px - ax) * abx + (py - ay) * aby) / abSquared;

    t = t.clamp(0.0, 1.0);

    return LatLng(ay + aby * t, ax + abx * t);
  }

  static double _distance(LatLng a, LatLng b) {
    return math.sqrt(
      math.pow(a.latitude - b.latitude, 2) +
          math.pow(a.longitude - b.longitude, 2),
    );
  }
}
