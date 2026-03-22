import 'package:driver/constant/constant.dart';
import 'package:driver/controller/provider/profileProvider/profileProvider.dart';
import 'package:driver/controller/services/profileService/profileService.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/textStyles.dart';
import 'package:driver/widgets/commonElevatedButton.dart';
import 'package:driver/widgets/commonTextfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  TextEditingController vehicleRegistrationNumberController =
      TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController drivingLicenseNumberController =
      TextEditingController();
  bool registerButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          children: [
            SizedBox(height: 2.h),
            Consumer<ProfileProvider>(
              builder: (context, userProfileProvider, child) {
                return InkWell(
                  onTap: () async {
                    await context.read<ProfileProvider>().pickImageFromGallery(
                      context,
                    );
                  },
                  child: CircleAvatar(
                    radius: 5.h,
                    backgroundColor: black,
                    child: CircleAvatar(
                      backgroundColor: white,
                      radius: 5.h - 2,
                      backgroundImage:
                          userProfileProvider.userProfileImage != null
                          ? FileImage(userProfileProvider.userProfileImage!)
                          : null,
                      child: userProfileProvider.userProfileImage == null
                          ? FaIcon(
                              FontAwesomeIcons.user,
                              size: 4.h,
                              color: black,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),
            CommonTextfield(
              controller: nameController,
              title: 'Name',
              hintText: 'name',
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 2.h),
            CommonTextfield(
              controller: vehicleRegistrationNumberController,
              title: 'Vehicle Registration Number',
              hintText: 'Registration Number',
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 2.h),
            CommonTextfield(
              controller: drivingLicenseNumberController,
              title: 'Driving License Number',
              hintText: 'License Number',
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 35.h),
            Commonelevatedbutton(
              onPressed: () async {
                setState(() {
                  registerButtonPressed = true;
                });
                await context.read<ProfileProvider>().uploadImageAndGetImageUrl(
                  context,
                );

                DriverModel driverData = DriverModel(
                  name: nameController.text.trim(),
                  profilePicUrl:
                      context.read<ProfileProvider>().userProfileImageurl ?? '',
                  mobileNumber: auth.currentUser!.phoneNumber!,
                  driverId: auth.currentUser!.uid,
                  vehicleRegistrationNumber: vehicleRegistrationNumberController
                      .text
                      .trim(),
                  drivingLicenseNumber: drivingLicenseNumberController.text
                      .trim(),
                  registeredDateTime: DateTime.now(),
                );

                ProfileServices.registerDriver(driverData, context);
              },
              color: black,
              child: registerButtonPressed
                  ? CircularProgressIndicator(color: white)
                  : Text(
                      'Register',
                      style: AppTextStyles.body14Bold.copyWith(color: white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
