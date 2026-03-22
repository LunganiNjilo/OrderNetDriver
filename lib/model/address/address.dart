import 'dart:convert';

class AddressModel {
  String? name;
  String? secondaryName;
  String? description;
  String? placeId;
  double? latitude;
  double? longitude;

  AddressModel({
    this.name,
    this.secondaryName,
    this.description,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
