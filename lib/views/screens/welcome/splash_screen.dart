import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/controller/splash_controller.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var splashController = Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(Assets.gobgimage)),
        ),
        child: Center(
          child: FadeTransition(
            opacity: splashController.fadeAnimation,
            child: ScaleTransition(
              scale: splashController.scaleAnimation,
              child: CommonImageView(height: 200, imagePath: Assets.logo),
            ),
          ),
        ),
      ),
    );
  }
}
