import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final FoodOrderModel order;

  const DeliveryDetailsScreen({super.key, required this.order});

  Widget _tile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.6.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.small12.copyWith(color: grey)),
                SizedBox(height: .3.h),
                Text(value, style: AppTextStyles.body14Bold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(elevation: 0, title: const Text("Delivery Details")),

      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),

                SizedBox(height: 1.h),

                Text(
                  "Completed",
                  style: AppTextStyles.body18Bold.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          _tile(
            icon: Icons.fastfood,
            title: "Food",
            value: order.foodDetails.name,
          ),

          _tile(
            icon: Icons.storefront,
            title: "Restaurant",
            value: order.restaurantDetails.restaurantName ?? "",
          ),

          _tile(
            icon: Icons.location_on,
            title: "Delivery Address",
            value:
                "${order.userAddress?.streetAddress ?? ''}\n"
                "${order.userAddress?.suburb ?? ''}, "
                "${order.userAddress?.city ?? ''}",
          ),

          _tile(
            icon: Icons.payments,
            title: "Delivery Fee",
            value: "R${order.deliveryCharges}",
          ),

          _tile(
            icon: Icons.receipt_long,
            title: "Order ID",
            value: order.orderId ?? "",
          ),

          _tile(
            icon: Icons.access_time,
            title: "Delivered At",
            value: DateFormat(
              "dd MMM yyyy • HH:mm",
            ).format(order.orderDeliveredAt!),
          ),
        ],
      ),
    );
  }
}
