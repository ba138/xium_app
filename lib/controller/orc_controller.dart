import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:xium_app/constants/app_colors.dart';

class OcrController extends GetxController {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔹 State
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString uploadedFileUrl = ''.obs;

  static const String _cloudFunctionUrl =
      "https://us-central1-xium-app.cloudfunctions.net/processImageDocument";

  /// 📸 Pick image
  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      error.value = '';

      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      await _uploadAndProcess(File(pickedFile.path), filetype: "image");
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// 📄 Pick PDF File
  Future<void> pickPdf() async {
    try {
      error.value = '';

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      File file = File(result.files.single.path!);

      await _uploadAndProcess(file, filetype: "filetype");
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// ☁️ Upload File → Firebase → Send to Cloud Function
  Future<void> _uploadAndProcess(File file, {required String filetype}) async {
    try {
      isLoading.value = true;

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw "User not logged in";
      }

      Get.snackbar(
        "Uploading File".tr,
        "Please wait while we process your document.".tr,
        snackPosition: SnackPosition.TOP,
        colorText: AppColors.onPrimary,
      );

      final fileName = "ocr_${DateTime.now().millisecondsSinceEpoch}.$filetype";

      final ref = _storage.ref().child("users/$uid/ocr/$fileName");

      await ref.putFile(file);

      final fileUrl = await ref.getDownloadURL();
      uploadedFileUrl.value = fileUrl;

      await _sendToCloudFunction(uid, fileUrl, filetype);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 Call Cloud Function
  Future<void> _sendToCloudFunction(
    String uid,
    String fileUrl,
    String filetype,
  ) async {
    final response = await http.post(
      Uri.parse(_cloudFunctionUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uid": uid, "fileUrl": fileUrl, "filetype": filetype}),
    );

    if (response.statusCode != 200) {
      throw "Document processing failed";
    }
  }
}
