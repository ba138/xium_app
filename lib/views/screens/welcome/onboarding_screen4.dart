import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
                GestureDetector(
                  onTap: () {
                    _showLanguageBottomSheet();
                  },
                  child: Row(
                    children: [
                      MyText(text: "Language".tr, color: Colors.transparent),
                      const Spacer(),
                      MyText(
                        text: Get.locale?.languageCode == 'fr'
                            ? "Français"
                            : "English",
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
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
                Platform.isIOS
                    ? SizedBox.shrink()
                    : Row(
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
                Platform.isAndroid
                    ? GlassiyButton(
                        title: "Register With Google".tr,
                        ontap: () {
                          authController.signInWithGoogle();
                        },
                        image: Assets.google,
                      )
                    : SizedBox.shrink(),

                // /// 🔹 Apple Login
                // Platform.isIOS
                //     ? GlassiyButton(
                //         title: "sign_in_apple".tr,
                //         ontap: () {
                //           authController.signInWithApple();
                //         },
                //         image: Assets.fb,
                //       )
                //     : const SizedBox.shrink(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            /// English
            _languageTile(title: "English", locale: const Locale('en', 'US')),

            const SizedBox(height: 12),

            /// French
            _languageTile(title: "Français", locale: const Locale('fr', 'FR')),
          ],
        ),
      ),
    );
  }

  Widget _languageTile({required String title, required Locale locale}) {
    final isSelected = Get.locale?.languageCode == locale.languageCode;
    final box = GetStorage();

    return InkWell(
      onTap: () {
        Get.updateLocale(locale);

        // ✅ SAVE LANGUAGE HERE
        box.write('lang', locale.languageCode);

        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
