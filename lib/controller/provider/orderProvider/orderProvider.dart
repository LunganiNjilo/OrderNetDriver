import 'dart:developer';

import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier {
  FoodOrderModel? orderData;

  updateFoodOrderData(FoodOrderModel data) {
    orderData = data;
    log("PROVIDER ORDER DATA NOW: ${orderData?.orderId}");
    notifyListeners();
  }

  emptyOrderData() {
    orderData = null;
    notifyListeners();
  }
}
