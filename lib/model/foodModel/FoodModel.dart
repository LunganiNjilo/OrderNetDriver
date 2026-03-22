class FoodModel {
  String name;
  String restaurantUId;
  DateTime uploadTime;
  String foodId;
  String description;
  String foodImageUrl;
  bool isVegetarian;
  String actualPrice;
  String discountedPrice;
  int? quantity;
  FoodModel({
    required this.name,
    required this.restaurantUId,
    required this.uploadTime,
    required this.foodId,
    required this.description,
    required this.foodImageUrl,
    required this.isVegetarian,
    required this.actualPrice,
    required this.discountedPrice,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'restaurantUId': restaurantUId,
      'uploadTime': uploadTime.toIso8601String(),
      'foodId': foodId,
      'description': description,
      'foodImageUrl': foodImageUrl,
      'isVegetarian': isVegetarian,
      'actualPrice': actualPrice,
      'discountedPrice': discountedPrice,
      'quantity': quantity,
    };
  }

  static FoodModel fromMap(Map<String, dynamic> map) {
    return FoodModel(
      name: map['name'] != null ? map['name'] as String : '',
      restaurantUId: map['restaurantUId'] ?? '',
      uploadTime: map['uploadTime'] is DateTime
          ? map['uploadTime']
          : DateTime.tryParse(map['uploadTime'] ?? '') ?? DateTime.now(),
      foodId: map['foodId'] ?? '',
      description: map['description'] ?? '',
      foodImageUrl: map['foodImageUrl'] ?? '',
      isVegetarian: map['isVegetarian'] ?? false,
      actualPrice: map['actualPrice'] ?? '',
      discountedPrice: map['discountedPrice'] ?? '',
      quantity: map['quantity'] != null ? map['quantity'] as int : 0,
    );
  }
}
