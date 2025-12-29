import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/model/user_model.dart';
import 'package:xium_app/views/screens/auth/login_screen.dart';
import 'package:xium_app/views/widgets/loading_dialog.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<void> createUser() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = passwordController.text.trim();

    // ✅ Check for empty fields
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Full name basic check
    if (fullName.length < 3) {
      Get.snackbar(
        "Error",
        "Full name must be at least 3 characters",
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Email check (must contain @ and .)
    if (!email.contains("@") || !email.contains(".")) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Password length check
    if (password.length < 6) {
      Get.snackbar(
        "Error",
        "Password must be at least 6 characters long",
        colorText: AppColors.primary,
      );
      return;
    }
    if (password != repeatPassword) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        colorText: AppColors.primary,
      );
      return;
    }

    try {
      Get.dialog(LoadingDialogWidget(), barrierDismissible: false);

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed");

      // Send email verification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      final userModel = UserModel(username: fullName, email: email);

      // Save user to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        ...userModel.toJson(),
        'createdAt': FieldValue.serverTimestamp(), // override with server time
        'emailVerified': false, // Add this field
      });

      // Clear input fields
      fullNameController.clear();
      emailController.clear();
      passwordController.clear();

      // Navigate to login
      Get.to(() => LoginScreen());
      Get.snackbar(
        "Success",
        "Account created. Please verify your email.",
        colorText: AppColors.primary,
      );
    } on FirebaseAuthException catch (e) {
      Get.back();

      if (e.code == 'weak-password') {
        Get.snackbar(
          "Weak Password",
          "The password provided is too weak.",
          colorText: AppColors.primary,
        );
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "Email Already In Use",
          "The email is already registered.",
          colorText: AppColors.primary,
        );
      } else if (e.code == 'invalid-email') {
        Get.snackbar(
          "Invalid Email",
          "The email address is not valid.",
          colorText: AppColors.primary,
        );
      } else {
        Get.snackbar(
          "Registration Error",
          e.message ?? "Something went wrong",
          colorText: AppColors.primary,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString(), colorText: AppColors.primary);
    }
  }

  Future<void> loginUser(String email, String password) async {
    // ✅ Empty check
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Email and Password cannot be empty",
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Basic email check (must contain @ and .)
    if (!email.contains("@") || !email.contains(".")) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Password length check
    if (password.length < 6) {
      Get.snackbar(
        "Error",
        "Password must be at least 6 characters long",
        colorText: AppColors.primary,
      );
      return;
    }

    try {
      Get.dialog(const LoadingDialogWidget(), barrierDismissible: false);

      // Sign in user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Login failed");

      // Check email verification
      if (!user.emailVerified) {
        Get.back();
        Get.snackbar(
          "Verify Email",
          "Please verify your email before logging in.",
          colorText: AppColors.primary,
        );
        return;
      } else {
        Get.offAll(() => LoginScreen());
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString(), colorText: AppColors.primary);
    }
  }
}
