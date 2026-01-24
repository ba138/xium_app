import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:xium_app/views/screens/home/home_screen.dart';

class OcrController extends GetxController {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔹 State
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString uploadedImageUrl = ''.obs;

  static const String _cloudFunctionUrl =
      "https://us-central1-xium-app.cloudfunctions.net/processImageDocument";

  /// 📸 Pick image from camera or gallery
  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      error.value = '';

      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      await _uploadAndProcess(File(pickedFile.path));
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// ☁️ Upload image → Firebase Storage → send to Cloud Function
  Future<void> _uploadAndProcess(File imageFile) async {
    try {
      isLoading.value = true;

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw "User not logged in";
      }
      Get.snackbar(
        "Uploading Image",
        "Image will be processed shortly.",
        snackPosition: SnackPosition.TOP,
      );
      Get.offAll(() => HomeScreen());
      final fileName = "ocr_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = _storage.ref().child("users/$uid/ocr/$fileName");

      await ref.putFile(imageFile);

      final imageUrl = await ref.getDownloadURL();
      uploadedImageUrl.value = imageUrl;

      await _sendToCloudFunction(uid, imageUrl);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 Call Cloud Function
  Future<void> _sendToCloudFunction(String uid, String imageUrl) async {
    final response = await http.post(
      Uri.parse(_cloudFunctionUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uid": uid, "imageUrl": imageUrl}),
    );

    if (response.statusCode != 200) {
      debugPrint("Cloud Function response: ${response.body}");
      throw "OCR processing failed";
    }
  }
}
