import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:driver/controller/services/ApisNKeys/ApisNKeys.dart';
import 'package:driver/model/directionModel/directionModel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionService {
  static Future getDirectionDetails(
    LatLng pickupLocation,
    LatLng dropLocation,
    BuildContext context,
  ) async {
    final api = Uri.parse(APIs.directionAPI(pickupLocation, dropLocation));

    try {
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Connection Time Out');
            },
          )
          .onError((error, stackTrace) {
            throw Exception(error);
          });
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        DirectionModel directionDetails = DirectionModel(
          distanceInKM:
              decodedResponse['routes'][0]['legs'][0]['distance']['text'],
          distanceInMeter:
              decodedResponse['routes'][0]['legs'][0]['distance']['value'],
          durationInHour:
              decodedResponse['routes'][0]['legs'][0]['duration']['text'],
          duration:
              decodedResponse['routes'][0]['legs'][0]['duration']['value'],
          polylinePoints:
              decodedResponse['routes'][0]['overview_polyline']['points'],
        );
        log(directionDetails.toMap().toString());
        return directionDetails;
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e);
    }
  }
}
