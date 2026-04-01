import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/model/user_model.dart';
import 'package:xium_app/views/screens/auth/login_screen.dart';
import 'package:xium_app/views/screens/starting/need_permission_screens.dart';
import 'package:xium_app/views/widgets/loading_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  var isPasswordHidden = false.obs;
  var isShowRegister = false.obs;
  var isShowRepeatPassword = false.obs;
  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    try {
      Get.dialog(const LoadingDialogWidget(), barrierDismissible: false);

      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await FirebaseAuth.instance.signInWithProvider(
        appleProvider,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Apple sign-in failed");
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final userModel = UserModel(
          uid: firebaseUser.uid,
          username: firebaseUser.displayName ?? "Apple User",
          email: firebaseUser.email ?? "",
          profilePictureUrl:
              "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
        );

        await docRef.set({
          ...userModel.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
          'provider': 'apple',
        });
      }

      Get.back();
      Get.offAll(() => const NeedPermissionScreens());
    } catch (e) {
      Get.back();
      debugPrint("Apple Sign-In Error: $e");
      Get.snackbar("Apple Sign-In Error", e.toString());
    }
  }

  Future<void> createUser() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = passwordController.text.trim();

    // ✅ Check for empty fields
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error".tr,
        "All fields are required".tr,
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Full name basic check
    if (fullName.length < 3) {
      Get.snackbar(
        "Error".tr,
        "Full name must be at least 3 characters".tr,
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Email check (must contain @ and .)
    if (!email.contains("@") || !email.contains(".")) {
      Get.snackbar(
        "Error".tr,
        "Please enter a valid email address".tr,
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Password length check
    if (password.length < 6) {
      Get.snackbar(
        "Error".tr,
        "Password must be at least 6 characters long".tr,
        colorText: AppColors.primary,
      );
      return;
    }
    if (password != repeatPassword) {
      Get.snackbar(
        "Error".tr,
        "Passwords do not match".tr,
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

      final userModel = UserModel(
        uid: user.uid,
        username: fullName,
        email: email,
        profilePictureUrl:
            "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
      );

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
      showVerificationEmailDialog();

      // Navigate to login
    } on FirebaseAuthException catch (e) {
      Get.back();

      if (e.code == 'weak-password') {
        Get.snackbar(
          "Weak Password".tr,
          "The password provided is too weak.".tr,
          colorText: AppColors.primary,
        );
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "Email Already In Use".tr,
          "The email is already registered.".tr,
          colorText: AppColors.primary,
        );
      } else if (e.code == 'invalid-email') {
        Get.snackbar(
          "Invalid Email".tr,
          "The email address is not valid.".tr,
          colorText: AppColors.primary,
        );
      } else {
        Get.snackbar(
          "Registration Error".tr,
          e.message ?? "Something went wrong".tr,
          colorText: AppColors.primary,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error".tr, e.toString(), colorText: AppColors.primary);
    }
  }

  Future<void> loginUser(String email, String password) async {
    // ✅ Empty check
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "Error".tr,
        "Email and Password can't be empty".tr,
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Basic email check (must contain @ and .)
    if (!email.contains("@") || !email.contains(".")) {
      Get.snackbar(
        "Error".tr,
        "Please enter a valid email address".tr,
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Password length check
    if (password.length < 6) {
      Get.snackbar(
        "Error".tr,
        "Password must be at least 6 characters long".tr,
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
          "Verify Email".tr,
          "Please verify your email before logging in.".tr,
          colorText: AppColors.primary,
        );
        return;
      } else {
        Get.offAll(() => NeedPermissionScreens());
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString(), colorText: AppColors.primary);
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        "Error".tr,
        "Please enter your email",
        colorText: AppColors.primary,
      );
      return;
    }

    // ✅ Email format check
    if (!email.contains("@") || !email.contains(".")) {
      Get.snackbar(
        "Error".tr,
        "Please enter a valid email address".tr,
        colorText: AppColors.primary,
      );
      return;
    }

    try {
      Get.dialog(const LoadingDialogWidget(), barrierDismissible: false);
      // Check if email exists in users collection
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          "Email Not Registered".tr,
          "No account found with this email.".tr,
          colorText: AppColors.primary,
        );
        return;
      }
      await _auth.sendPasswordResetEmail(email: email);
      showResetPasswordDialog();
    } on FirebaseAuthException catch (e) {
      Get.back(); // Close loading dialog
      if (e.code == 'invalid-email') {
        Get.snackbar(
          "Invalid Email".tr,
          "Please enter a valid email address.".tr,
          colorText: AppColors.primary,
        );
      } else {
        Get.snackbar(
          "Error".tr,
          e.message ?? "Something went wrong".tr,
          colorText: AppColors.primary,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar("Error", e.toString(), colorText: AppColors.primary);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      Get.dialog(LoadingDialogWidget(), barrierDismissible: false);

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Get.back();
        Get.snackbar(
          "Cancelled",
          "Google sign-in was cancelled.",
          colorText: AppColors.primary,
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase authentication failed");
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);

      final doc = await docRef.get();

      /// 🔹 CASE 1: User already exists → Login only
      if (doc.exists) {
        Get.back();

        Get.snackbar(
          "Welcome back",
          "Signed in successfully",
          colorText: AppColors.primary,
        );

        Get.offAll(() => const NeedPermissionScreens());
        return;
      }

      /// 🔹 CASE 2: New user → Create account
      final userModel = UserModel(
        uid: firebaseUser.uid,
        username: firebaseUser.displayName ?? 'No Name',
        email: firebaseUser.email ?? '',
        profilePictureUrl:
            firebaseUser.photoURL ??
            "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
      );

      await docRef.set({
        ...userModel.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();

      Get.snackbar(
        "Success",
        "Account created using Google",
        colorText: AppColors.primary,
      );

      Get.offAll(() => const NeedPermissionScreens());
    } catch (e) {
      Get.back();
      debugPrint("Google Sign-In Error: $e");

      Get.snackbar(
        "Google Sign-In Error",
        e.toString(),
        colorText: AppColors.primary,
      );
    }
  }

  Future<void> logoutUser() async {
    try {
      Get.dialog(const LoadingDialogWidget(), barrierDismissible: false);

      // 🔹 Google sign-out (safe to call even if not logged in with Google)
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      // 🔹 Firebase sign-out (covers Email, Apple, Google)
      await _auth.signOut();

      Get.back(); // close loading
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.back();
      Get.snackbar('Logout Failed', e.toString(), colorText: AppColors.primary);
    }
  }

  void showVerificationEmailDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff0A0D2E), // card over background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              MyText(
                text: "verification_email_sent".tr,
                size: 18,
                weight: FontWeight.w600,
                color: Colors.white,
              ),

              const SizedBox(height: 12),

              /// MESSAGE
              MyText(
                text: "verification_email_message"
                    .tr, // translation key for message
                size: 13,
                color: Colors.white70,
              ),

              const SizedBox(height: 24),

              /// ACTION BUTTON
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      buttonText: "ok".tr,
                      radius: 12,
                      onTap: () {
                        Get.back();
                        Get.to(() => LoginScreen());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showResetPasswordDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff0A0D2E), // card over background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              MyText(
                text: "reset_password".tr,
                size: 18,
                weight: FontWeight.w600,
                color: Colors.white,
              ),

              const SizedBox(height: 12),

              /// MESSAGE
              MyText(
                text: "reset_password_message".tr, // translation key
                size: 13,
                color: Colors.white70,
              ),

              const SizedBox(height: 24),

              /// ACTION BUTTON
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      buttonText: "ok".tr,
                      radius: 12,
                      onTap: () {
                        Get.back();
                        Get.to(() => LoginScreen());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
