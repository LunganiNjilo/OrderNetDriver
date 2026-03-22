import 'dart:convert';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool today = true;
  bool month = false;
  bool year = false;

  // void checkTimestamoIsToday(int timestamp) {
  //   DateTime now = DateTime.now();
  //   DateTime dateFromTimeStamp = DateTime.fromMicrosecondsSinceEpoch(timestamp);
  //   if (dateFromTimeStamp.year == now.year) {
  //     if (dateFromTimeStamp.month == now.month) {
  //       if (dateFromTimeStamp.day == now.day) {}
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(100.w, 10.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Stats', style: AppTextStyles.body18Bold),
                Builder(
                  builder: (context) {
                    if (today) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            today = false;
                            month = true;
                            year = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.7.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.sp),
                            border: Border.all(color: black87),
                          ),

                          child: Text('Today', style: AppTextStyles.body18Bold),
                        ),
                      );
                    } else if (month) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            today = false;
                            month = false;
                            year = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.7.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.sp),
                            border: Border.all(color: black87),
                          ),

                          child: Text('Month', style: AppTextStyles.body18Bold),
                        ),
                      );
                    } else if (year) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            today = true;
                            month = false;
                            year = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.7.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.sp),
                            border: Border.all(color: black87),
                          ),

                          child: Text('Year', style: AppTextStyles.body18Bold),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          children: [
            StreamBuilder(
              stream: realTimeDatabaseRef
                  .child('OrderHistory')
                  .orderByChild('restaurantUId')
                  .equalTo(auth.currentUser!.uid)
                  .onValue,
              builder: (context, event) {
                if (event.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (event.data == null) {
                  return Center(
                    child: Text(
                      'No Previous Orders',
                      style: AppTextStyles.body16,
                    ),
                  );
                }

                final snapshot = event.data?.snapshot;

                if (snapshot == null ||
                    !snapshot.exists ||
                    snapshot.value == null) {
                  return Center(
                    child: Text(
                      'No Previous Orders',
                      style: AppTextStyles.body16,
                    ),
                  );
                }

                final values =
                    event.data!.snapshot.value as Map<dynamic, dynamic>;

                List<FoodOrderModel> todayOrderDataList = [];
                List<FoodOrderModel> monthOrderDataList = [];
                List<FoodOrderModel> yearOrderDataList = [];

                values.forEach((key, value) {
                  FoodOrderModel foodData = FoodOrderModel.fromMap(
                    jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
                  );
                  DateTime now = DateTime.now();
                  DateTime dateFromTimeStamp =
                      DateTime.fromMicrosecondsSinceEpoch(
                        foodData.orderDeliveredAt!.microsecondsSinceEpoch,
                      );
                  if (dateFromTimeStamp.year == now.year) {
                    yearOrderDataList.add(foodData);
                    if (dateFromTimeStamp.month == now.month) {
                      monthOrderDataList.add(foodData);
                      if (dateFromTimeStamp.day == now.day) {
                        todayOrderDataList.add(foodData);
                      }
                    }
                  }
                });

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: today
                      ? todayOrderDataList.length
                      : month
                      ? monthOrderDataList.length
                      : yearOrderDataList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 3.w),

                  itemBuilder: (context, index) {
                    FoodOrderModel currentFoodData = today
                        ? todayOrderDataList[index]
                        : month
                        ? monthOrderDataList[index]
                        : yearOrderDataList[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 1.5.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.sp),
                        border: Border.all(color: black87),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 1.h),
                                Text(
                                  currentFoodData.foodDetails.name,
                                  style: AppTextStyles.body14Bold,
                                ),
                                SizedBox(height: 0.5.h),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Restuarant: ',
                                        style: AppTextStyles.body14,
                                      ),
                                      TextSpan(
                                        text: currentFoodData
                                            .restaurantDetails
                                            .restaurantName,
                                        style: AppTextStyles.body14,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  DateFormat(
                                    'd MMM, h:mm a',
                                  ).format(currentFoodData.orderDeliveredAt!),
                                  style: AppTextStyles.small10.copyWith(
                                    color: grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'R${currentFoodData.deliveryCharges}',
                            style: AppTextStyles.body16Bold,
                          ),
                        ],
                      ),
                    );
                  },
                );

                return const SizedBox();
              },
            ),

            // FirebaseAnimatedList(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            //   query: realTimeDatabaseRef
            //       .child('OrderHistory')
            //       .orderByChild('restuatrantUId')
            //       .equalTo(auth.currentUser!.uid),
            //   itemBuilder: (context, snapshot, animation, index) {
            //     log(snapshot.value.toString());
            //     FoodOrderModel foodData = FoodOrderModel.fromMap(
            //       jsonDecode(jsonEncode(snapshot.value))
            //           as Map<String, dynamic>,
            //     );

            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
