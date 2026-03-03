import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class PhoneConnectController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Loading
  final isLoading = false.obs;

  /// 🔹 Connect phone
  Future<void> connectPhone(String phoneNumber, String countryCode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      Get.snackbar("Error", "User not logged in".tr);
      return;
    }

    try {
      isLoading.value = true;

      final userRef = _db.collection("users").doc(uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        Get.snackbar("Error", "User not found".tr);
        return;
      }

      final userData = userSnap.data()!;
      final source = Map<String, dynamic>.from(userData['source'] ?? {});

      /// ✅ Check if already connected
      if (source['sms'] == 'connected') {
        Get.snackbar(
          "Already Connected".tr,
          "Phone number is already connected".tr,
          colorText: AppColors.primary,
        );
        return;
      }

      /// ✅ Validate input
      if (countryCode.isEmpty || phoneNumber.isEmpty) {
        Get.snackbar("Error", "Please enter phone number".tr);
        return;
      }

      final fullPhone = "$countryCode$phoneNumber";

      /// ✅ Save to Firestore
      await userRef.update({
        "phone": fullPhone,
        "source.sms": "connected",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      /// ✅ Show success dialog
      showSuccessDialog();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Success Dialog
  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff3463CD).withValues(alpha: 0.27),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff175293),
                ),
                child: Icon(Icons.done, color: AppColors.primary, size: 32),
              ),

              const SizedBox(height: 18),

              /// TITLE
              MyText(
                text: "Phone Number\nConnected Successfully".tr,
                size: 18,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              /// SUBTITLE
              MyText(
                text: "SMS-based receipts will be detected automatically.".tr,
                size: 10,
                color: Colors.white70,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
