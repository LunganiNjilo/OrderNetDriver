import 'dart:developer';
import 'dart:io';
import 'package:driver/controller/services/imageServices/imageServices.dart';
import 'package:driver/controller/services/profileService/profileService.dart';
import 'package:driver/model/driverModel/driverModel.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  DriverModel? deliveryGuyProfile;
  File? userProfileImage;
  String? userProfileImageurl;

  pickImageFromGallery(BuildContext context) async {
    userProfileImage = await ImageServices.pickSingleImage(context: context);
    notifyListeners();
  }

  uploadImageAndGetImageUrl(BuildContext context) async {
    if (userProfileImage == null) {
      log('No Image Selected');
      return;
    }
    List<String> url = await ImageServices.uploadImageToFirebaseStorageNGetURL(
      images: [userProfileImage!],
      context: context,
    );
    if (url.isNotEmpty) {
      userProfileImageurl = url[0];
      log(userProfileImageurl!);
    }
    notifyListeners();
  }

  getDeliveryGuyProfile() async {
    deliveryGuyProfile = await ProfileServices.getDeliveryPartnerProfileData();
    notifyListeners();
  }
}
