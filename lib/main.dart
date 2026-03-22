import 'package:driver/controller/provider/authProvider/MobileAuthProvider.dart';
import 'package:driver/controller/provider/orderProvider/orderProvider.dart';
import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:driver/controller/provider/rideProvider/rideProvider.dart';
import 'package:driver/firebase_options.dart';
import 'package:driver/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'driver',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Driver());
}

class Driver extends StatelessWidget {
  const Driver({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, _, __) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<MobileAuthprovider>(
              create: (_) => MobileAuthprovider(),
            ),
            ChangeNotifierProvider<ProfileProvider>(
              create: (_) => ProfileProvider(),
            ),
            ChangeNotifierProvider<RideProvider>(create: (_) => RideProvider()),
            ChangeNotifierProvider<OrderProvider>(
              create: (_) => OrderProvider(),
            ),
          ],
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(),
            home: const SignInLogicScreen(),
          ),
        );
      },
    );
  }
}
