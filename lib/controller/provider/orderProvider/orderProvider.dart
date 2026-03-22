import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier {
  FoodOrderModel? orderData;

  updateFoodOrderData(FoodOrderModel data) {
    orderData = data;
    notifyListeners();
  }

  emptyOrderData() {
    orderData = null;
    notifyListeners();
  }
}
