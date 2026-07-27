import 'dart:convert';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/foodOrderModel/foodOrderModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/textStyles.dart';
import 'package:driver/view/historyScreen/deliveryDetailsScreen.dart';
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

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final ValueNotifier<String> searchQuery = ValueNotifier("");

  // void checkTimestamoIsToday(int timestamp) {
  //   DateTime now = DateTime.now();
  //   DateTime dateFromTimeStamp = DateTime.fromMicrosecondsSinceEpoch(timestamp);
  //   if (dateFromTimeStamp.year == now.year) {
  //     if (dateFromTimeStamp.month == now.month) {
  //       if (dateFromTimeStamp.day == now.day) {}
  //     }
  //   }
  // }

  Widget buildFilterButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCard({
    required String title,
    required int deliveries,
    required int earnings,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body16Bold),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green.shade50,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.green,
                        size: 22,
                      ),
                    ),

                    SizedBox(height: .8.h),

                    Text("$deliveries", style: AppTextStyles.body18Bold),

                    Text(
                      "Deliveries",
                      style: AppTextStyles.small12.copyWith(color: grey),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(
                        Icons.payments,
                        color: Colors.orange,
                        size: 22,
                      ),
                    ),

                    SizedBox(height: .8.h),

                    Text("R$earnings", style: AppTextStyles.body18Bold),

                    Text(
                      "Earnings",
                      style: AppTextStyles.small12.copyWith(color: grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    print("Search bar rebuilt");
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextField(
        focusNode: searchFocusNode,
        controller: searchController,
        onChanged: (value) {
          searchQuery.value = value.trim().toLowerCase();
        },
        decoration: InputDecoration(
          hintText: "Restaurant, customer, food or order ID",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.value.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    searchQuery.value = "";
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery History', style: AppTextStyles.body18Bold),
                    SizedBox(height: .3.h),
                    Text(
                      'View your completed deliveries',
                      style: AppTextStyles.small12.copyWith(color: grey),
                    ),
                  ],
                ),
                SizedBox(
                  width: 48.w,
                  child: Row(
                    children: [
                      buildFilterButton(
                        title: "Today",
                        selected: today,
                        onTap: () {
                          setState(() {
                            today = true;
                            month = false;
                            year = false;
                          });
                        },
                      ),

                      SizedBox(width: 2.w),

                      buildFilterButton(
                        title: "Month",
                        selected: month,
                        onTap: () {
                          setState(() {
                            today = false;
                            month = true;
                            year = false;
                          });
                        },
                      ),

                      SizedBox(width: 2.w),

                      buildFilterButton(
                        title: "Year",
                        selected: year,
                        onTap: () {
                          setState(() {
                            today = false;
                            month = false;
                            year = true;
                          });
                        },
                      ),
                    ],
                  ),
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
                  .orderByChild('deliveryGuyUId')
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

                int todayEarnings = 0;
                int monthEarnings = 0;
                int yearEarnings = 0;

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
                    yearEarnings += foodData.deliveryCharges;

                    if (dateFromTimeStamp.month == now.month) {
                      monthOrderDataList.add(foodData);
                      monthEarnings += foodData.deliveryCharges;

                      if (dateFromTimeStamp.day == now.day) {
                        todayOrderDataList.add(foodData);
                        todayEarnings += foodData.deliveryCharges;
                      }
                    }
                  }
                });

                List<FoodOrderModel> displayedOrders = today
                    ? todayOrderDataList
                    : month
                    ? monthOrderDataList
                    : yearOrderDataList;

                if (searchQuery.value.isNotEmpty) {
                  displayedOrders = displayedOrders.where((order) {
                    final restaurant =
                        (order.restaurantDetails.restaurantName ?? "")
                            .toLowerCase();

                    final customer = (order.userData?.displayName ?? "")
                        .toLowerCase();

                    final food = order.foodDetails.name.toLowerCase();

                    final orderId = (order.orderId ?? "").toLowerCase();

                    final address =
                        [
                              order.userAddress?.streetAddress,
                              order.userAddress?.suburb,
                              order.userAddress?.city,
                            ]
                            .where((e) => e != null && e!.isNotEmpty)
                            .join(" ")
                            .toLowerCase();

                    return restaurant.contains(searchQuery.value) ||
                        customer.contains(searchQuery.value) ||
                        food.contains(searchQuery.value) ||
                        orderId.contains(searchQuery.value) ||
                        address.contains(searchQuery.value);
                  }).toList();
                }

                return Column(
                  children: [
                    buildSearchBar(),
                    if (searchQuery.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Text(
                          "${displayedOrders.length} result${displayedOrders.length == 1 ? '' : 's'} found",
                          style: AppTextStyles.small12.copyWith(color: grey),
                        ),
                      ),
                    buildSummaryCard(
                      title: today
                          ? "Today's Summary"
                          : month
                          ? "This Month"
                          : "This Year",
                      deliveries: today
                          ? todayOrderDataList.length
                          : month
                          ? monthOrderDataList.length
                          : yearOrderDataList.length,
                      earnings: today
                          ? todayEarnings
                          : month
                          ? monthEarnings
                          : yearEarnings,
                    ),

                    if (displayedOrders.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "No deliveries found",
                              style: AppTextStyles.body18Bold,
                            ),
                            SizedBox(height: .5.h),
                            Text(
                              "Try searching by restaurant,\ncustomer, food or order ID.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body14.copyWith(color: grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(displayedOrders.length, (index) {
                        FoodOrderModel currentFoodData = displayedOrders[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeliveryDetailsScreen(
                                  order: currentFoodData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 1.2.h),
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Completed",
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Spacer(),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Delivery Fee",
                                          style: AppTextStyles.small12.copyWith(
                                            color: grey,
                                          ),
                                        ),
                                        Text(
                                          "R${currentFoodData.deliveryCharges}",
                                          style: AppTextStyles.body18Bold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.5.h),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.orange.shade100,
                                      child: Text(
                                        (currentFoodData
                                                    .restaurantDetails
                                                    .restaurantName ??
                                                "R")
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 3.w),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentFoodData
                                                    .restaurantDetails
                                                    .restaurantName ??
                                                "",
                                            style: AppTextStyles.body18Bold,
                                          ),

                                          SizedBox(height: .4.h),

                                          Text(
                                            currentFoodData.foodDetails.name,
                                            style: AppTextStyles.body14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.h),

                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Color(0xFFE8F5E9),
                                      child: Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                    ),

                                    SizedBox(width: 2.w),

                                    Expanded(
                                      child: Text(
                                        currentFoodData.userData?.displayName ??
                                            "Customer",
                                        style: AppTextStyles.body14.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.h),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.red,
                                    ),

                                    SizedBox(width: 2.w),

                                    Expanded(
                                      child: Text(
                                        [
                                              currentFoodData
                                                  .userAddress
                                                  ?.streetAddress,
                                              currentFoodData
                                                  .userAddress
                                                  ?.suburb,
                                              currentFoodData.userAddress?.city,
                                            ]
                                            .where(
                                              (e) => e != null && e!.isNotEmpty,
                                            )
                                            .join(", "),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.small12.copyWith(
                                          color: grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 1.h),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Colors.green,
                                    ),

                                    SizedBox(width: 2.w),

                                    Expanded(
                                      child: Text(
                                        "Delivered • ${DateFormat('d MMM yyyy • h:mm a').format(currentFoodData.orderDeliveredAt!)}",
                                        style: AppTextStyles.small12.copyWith(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
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

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
