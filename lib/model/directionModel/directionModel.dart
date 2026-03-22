import 'dart:convert';

class DirectionModel {
  final String distanceInKM;
  final int distanceInMeter;
  final String durationInHour;
  final int duration;
  final String polylinePoints;

  DirectionModel({
    required this.distanceInKM,
    required this.distanceInMeter,
    required this.durationInHour,
    required this.duration,
    required this.polylinePoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'distanceInKM': distanceInKM,
      'distanceInMeter': distanceInMeter,
      'durationInHour': durationInHour,
      'duration': duration,
      'polylinePoints': polylinePoints,
    };
  }

  factory DirectionModel.fromMap(Map<String, dynamic> map) {
    return DirectionModel(
      distanceInKM: map['distanceInKM'] ?? '',
      distanceInMeter: map['distanceInMeter']?.toInt() ?? 0,
      durationInHour: map['durationInHour'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
      polylinePoints: map['polylinePoints'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DirectionModel.fromJson(String source) =>
      DirectionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
