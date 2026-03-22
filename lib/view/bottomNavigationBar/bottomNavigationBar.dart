import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:driver/controller/services/pushNotificationService/pushNotificationService.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/view/account/account.dart';
import 'package:driver/view/historyScreen/HistoryScreen.dart';
import 'package:driver/view/homeScreen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarEats extends StatefulWidget {
  const BottomNavigationBarEats({super.key});

  @override
  State<BottomNavigationBarEats> createState() =>
      _BottomNavigationBarEatsState();
}

class _BottomNavigationBarEatsState extends State<BottomNavigationBarEats> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PushNotificationService.initializeFCM(context);
      context.read<ProfileProvider>().getDeliveryGuyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Bottom Navigation Bar Demo',
      home: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: HomeScreen(),
            item: ItemConfig(
              icon: FaIcon(FontAwesomeIcons.house),
              title: "Home",
              activeForegroundColor: black,
              inactiveBackgroundColor: grey,
            ),
          ),
          PersistentTabConfig(
            screen: HistoryScreen(),
            item: ItemConfig(
              icon: FaIcon(FontAwesomeIcons.list),
              title: "History",
              activeForegroundColor: black,
              inactiveBackgroundColor: grey,
            ),
          ),
          PersistentTabConfig(
            screen: AccountScreen(),
            item: ItemConfig(
              icon: FaIcon(FontAwesomeIcons.person),
              title: "Account",
              activeForegroundColor: black,
              inactiveBackgroundColor: grey,
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) =>
            Style1BottomNavBar(navBarConfig: navBarConfig),
      ),
    );
  }
}
