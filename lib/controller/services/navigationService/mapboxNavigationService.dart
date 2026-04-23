import 'dart:convert';
import 'package:http/http.dart' as http;

class MapboxNavigationService {
  final String accessToken = "YOUR_TOKEN_HERE"; // must be pk.

  Future<List<List<double>>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/"
        "$startLng,$startLat;$endLng,$endLat"
        "?geometries=geojson&overview=full&access_token=$accessToken";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return [];
    }

    final data = json.decode(response.body);

    if (data["routes"] == null || data["routes"].isEmpty) {
      return [];
    }

    final coords = data["routes"][0]["geometry"]["coordinates"] as List;

    return coords.map<List<double>>((c) => [c[1], c[0]]).toList();
  }
}
