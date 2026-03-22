import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/model/userModel/userModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/textStyles.dart';
import 'package:driver/view/historyScreen/HistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List account = [
    [FontAwesomeIcons.shop, 'Orders'],
    [FontAwesomeIcons.locationPin, 'Address'],
    [FontAwesomeIcons.heart, 'Your Favorites'],
    [FontAwesomeIcons.star, 'Restaurant Reviews'],
    [FontAwesomeIcons.wallet, 'Wallet'],
    [FontAwesomeIcons.gift, 'Send a gift'],
    [FontAwesomeIcons.suitcase, 'Business preferences'],
    [FontAwesomeIcons.person, 'Help'],
    [FontAwesomeIcons.tag, 'Uber Pass'],
    [FontAwesomeIcons.ticket, 'Deliver with uber'],
    [FontAwesomeIcons.gear, 'Settings'],
    [FontAwesomeIcons.powerOff, 'Sign Out'],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getDeliveryGuyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          children: [
            SizedBox(height: 2.h),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.deliveryGuyProfile == null) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 3.h,
                        backgroundColor: black,
                        child: CircleAvatar(
                          backgroundColor: white,
                          child: FaIcon(
                            FontAwesomeIcons.user,
                            size: 3.h,
                            color: grey,
                          ),
                          radius: 3.h - 2,
                        ),
                      ),
                      SizedBox(width: 4.h),
                      Text('Hello User', style: AppTextStyles.body16),
                    ],
                  );
                } else {
                  DriverModel userData = profileProvider.deliveryGuyProfile!;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 3.h,
                        backgroundColor: black,
                        child: CircleAvatar(
                          backgroundColor: white,
                          backgroundImage: NetworkImage(
                            userData.profilePicUrl!,
                          ),
                          radius: 3.h - 2,
                        ),
                      ),
                      SizedBox(width: 4.h),
                      Text(userData.name!, style: AppTextStyles.body16),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 2.h),
            ListView.builder(
              itemCount: account.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {},
                  leading: FaIcon(account[index][0], size: 2.h),
                  title: Text(account[index][1], style: AppTextStyles.body14),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
