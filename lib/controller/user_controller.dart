import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/model/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xium_app/views/screens/auth/login_screen.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final currentPasswordController = TextEditingController();

  /// Reactive user model
  final Rxn<UserModel> user = Rxn<UserModel>();

  /// Loading state
  final isLoading = false.obs;

  StreamSubscription<DocumentSnapshot>? _userSub;

  @override
  void onInit() {
    super.onInit();
    _listenToUser();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  /// 🔹 Listen to current user document
  void _listenToUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;

    _userSub = _firestore.collection("users").doc(uid).snapshots().listen((
      doc,
    ) {
      if (!doc.exists) {
        user.value = null;
        isLoading.value = false;
        return;
      }

      final data = doc.data()!;
      user.value = UserModel.fromJson({
        ...data,
        'uid': uid, // ensure uid is always set
      });

      isLoading.value = false;
    });
  }

  /// 🔥 Delete user account (Auth + Firestore via Cloud Function)
  Future<void> deleteUserAccount() async {
    try {
      isLoading.value = true;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      // 🔐 Get fresh ID token
      final token = await currentUser.getIdToken(true);

      final response = await http.post(
        Uri.parse(
          "https://us-central1-xium-app.cloudfunctions.net/deleteUserAccount",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body["error"] ?? "Failed to delete account");
      }

      // ✅ Sign out locally after deletion
      await _auth.signOut();

      // 🧹 Clear local state
      user.value = null;

      Get.offAll(() => LoginScreen()); // or your login route
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updateUserInfo() async {
    try {
      isLoading.value = true;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final uid = currentUser.uid;

      final newName = nameController.text.trim();
      final newEmail = emailController.text.trim();
      final newPassword = newPasswordController.text.trim();
      final currentPassword = currentPasswordController.text.trim();

      final emailChanged = newEmail.isNotEmpty && newEmail != currentUser.email;

      final passwordChanged = newPassword.isNotEmpty;

      /// 🔐 Re-auth required ONLY for email/password
      if (emailChanged || passwordChanged) {
        if (currentPassword.isEmpty) {
          throw Exception("Current password is required");
        }

        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );

        await currentUser.reauthenticateWithCredential(credential);
      }

      /// 🔹 Update PASSWORD
      if (passwordChanged) {
        if (newPassword.length < 6) {
          throw Exception("Password must be at least 6 characters");
        }

        await currentUser.updatePassword(newPassword);
      }

      /// 🔹 Update EMAIL
      if (emailChanged) {
        await currentUser.verifyBeforeUpdateEmail(newEmail);
      }

      /// 🔹 Update Firestore (name & email)
      if (newName.isNotEmpty || emailChanged) {
        await _firestore.collection("users").doc(uid).set({
          if (newName.isNotEmpty) "username": newName,
          if (emailChanged) "email": newEmail,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      /// 🚪 LOGOUT ONLY IF EMAIL CHANGED
      if (emailChanged) {
        await _auth.signOut();
        user.value = null;

        Get.offAll(() => LoginScreen());

        Get.snackbar(
          "Verify Email",
          "Verification email sent. Please verify and log in again.",
          snackPosition: SnackPosition.TOP,
          colorText: AppColors.primary,
        );
        return;
      }

      /// ✅ Success (name/password only)
      Get.snackbar(
        "Success",
        "Account updated successfully",
        snackPosition: SnackPosition.TOP,
        colorText: AppColors.primary,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Authentication Error",
        e.message ?? "Auth failed",
        snackPosition: SnackPosition.TOP,
        colorText: AppColors.primary,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        colorText: AppColors.primary,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Quick helpers for UI
  bool get isBankConnected => user.value?.source['bank'] == 'connected';

  bool get isEmailConnected => user.value?.source['email'] == 'connected';

  bool get isSmsConnected => user.value?.source['sms'] == 'connected';

  bool get isOcrConnected => user.value?.source['osr'] == 'connected';
}
