import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';

class LoyaltyCardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  /// 🔹 Add Loyalty Card
  Future<void> addLoyaltyCard({
    required String storeName,
    required String cardNumber,
    String? nickname,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        Get.snackbar("Error", "User not logged in".tr);
        return;
      }

      if (storeName.isEmpty || cardNumber.isEmpty) {
        Get.snackbar(
          "Error",
          "Store name and card number are required".tr,
          colorText: AppColors.onPrimary,
        );
        return;
      }

      isLoading.value = true;

      /// 🔹 Create document
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("loyaltyCards")
          .add({
            "storeName": storeName,
            "cardNumber": cardNumber,
            "nickname": nickname ?? "",
            "createdAt": FieldValue.serverTimestamp(),
          });

      /// 🔹 Update source → connected
      await _firestore.collection("users").doc(uid).update({
        "source.osr": "connected",
      });

      isLoading.value = false;

      Get.back(); // close screen

      Get.snackbar(
        "Success",
        "Loyalty card added successfully".tr,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }
}
