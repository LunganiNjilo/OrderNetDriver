import 'dart:developer';
import 'dart:io';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/services/toastService/toastMessageService.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageServices {
  static getImagesFromGallery({required context}) async {
    List<File> selectedImages = [];
    final pickedFile = await imagePicker.pickMultiImage(imageQuality: 100);
    List<XFile> filePick = pickedFile;

    if (filePick.isNotEmpty) {
      for (var image in filePick) {
        selectedImages.add(File(image.path));
      }
    } else {
      ToastService.sendScaffoldAlert(
        msg: 'No Images Selected',
        toastStatus: 'WARNING',
        context: context,
      );
    }

    log('The Image are \n ${selectedImages.toList().toString()}');

    return selectedImages;
  }

  static pickSingleImage({required context}) async {
    File selectedImages;
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    XFile? filePick = pickedFile!;

    if (filePick != null) {
      selectedImages = File(filePick.path);
      log('The Image is \n ${selectedImages.toString()}');

      return selectedImages;
    } else {
      ToastService.sendScaffoldAlert(
        msg: 'No Images Selected',
        toastStatus: 'WARNING',
        context: context,
      );
    }
  }

  static uploadImageToFirebaseStorageNGetURL({
    required List<File> images,
    required BuildContext context,
  }) async {
    List<String> imagesUrl = [];
    String sellerUID = auth.currentUser!.uid;
    await Future.forEach(images, (image) async {
      String imageName = '$sellerUID${uuid.v1().toString()}';
      Reference ref = storage
          .ref()
          .child('RestaurantBannerImages')
          .child(imageName);

      await ref.putFile(File(image.path));
      String imageUrl = await ref.getDownloadURL();
      imagesUrl.add(imageUrl);
    });

    return imagesUrl;
  }
}
