import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/views/screens/home/home_screen.dart';
import 'package:xium_app/views/screens/welcome/onboarding_screen1.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  final _auth = FirebaseAuth.instance;
  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();

    // Listen for incoming app links

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleSessionNavigation();
      }
    });
  }

  void _handleSessionNavigation() async {
    final user = _auth.currentUser;

    if (user == null) {
      Get.offAll(() => OnboardingScreen1());

      return;
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }
}
