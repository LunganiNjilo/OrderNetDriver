import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/textStyles.dart';
import 'package:driver/view/historyScreen/HistoryScreen.dart';
import 'package:driver/view/settingsScreen/settingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver/view/signInLogicScreen/signInLogicScreen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final List account = [
    [FontAwesomeIcons.sackDollar, 'Earnings'],
    [FontAwesomeIcons.circleQuestion, 'Help'],
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

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                Navigator.pop(context);

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInLogicScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to sign out: $e")),
                );
              }
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleMenuNavigation(int index) {
    final String title = account[index][1];

    switch (title) {
      case 'Delivery History':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;

      case 'Sign Out':
        _showSignOutDialog();
        break;

      case 'Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title coming soon')));
    }
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
                          radius: 3.h - 2,
                          child: FaIcon(
                            FontAwesomeIcons.user,
                            size: 3.h,
                            color: grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.h),
                      Text('Driver', style: AppTextStyles.body16),
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
                          backgroundImage:
                              userData.profilePicUrl != null &&
                                  userData.profilePicUrl!.isNotEmpty
                              ? NetworkImage(userData.profilePicUrl!)
                              : null,
                          radius: 3.h - 2,

                          child:
                              userData.profilePicUrl == null ||
                                  userData.profilePicUrl!.isEmpty
                              ? FaIcon(
                                  FontAwesomeIcons.user,
                                  size: 3.h,
                                  color: grey,
                                )
                              : null,
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
                  onTap: () => _handleMenuNavigation(index),
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
