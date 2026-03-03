import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/auth_controller.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/auth/login_screen.dart';
import 'package:xium_app/views/screens/welcome/widgets/glassiy_button.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    var authController = Get.put(AuthController());
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(Assets.gobgimage)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                CommonImageView(imagePath: Assets.logo, height: 300),
                Spacer(),

                /// 🔹 Login with Email
                MyButton(
                  onTap: () {
                    Get.offAll(() => LoginScreen());
                  },
                  buttonText: "login_email".tr,
                  radius: 12,
                  hasicon: true,
                  choiceIcon: Assets.phone,
                ),

                const SizedBox(height: 20),

                /// 🔹 OR Divider
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.grayColor,
                      ),
                    ),
                    MyText(text: "or_login_with".tr),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔹 Google Login
                Platform.isAndroid
                    ? GlassiyButton(
                        title: "sign_in_google".tr,
                        ontap: () {
                          authController.signInWithGoogle();
                        },
                        image: Assets.google,
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 12),

                /// 🔹 Apple Login
                Platform.isIOS
                    ? GlassiyButton(
                        title: "sign_in_apple".tr,
                        ontap: () {
                          authController.signInWithApple();
                        },
                        image: Assets.fb,
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
