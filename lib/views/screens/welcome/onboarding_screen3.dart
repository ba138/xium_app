import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/welcome/onboarding_screen4.dart';
import 'package:xium_app/views/screens/welcome/widgets/welcome_button.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/glassy_container.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: Center(
                    child: CommonImageView(
                      imagePath: Assets.welcomeImage3,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grayColor,
                      ),
                    ),

                    Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grayColor,
                      ),
                    ),
                    Container(
                      height: 5,
                      width: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                MyText(
                  text: "Secure. Simple. Instant",
                  size: 24,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                MyText(
                  text: "Your data is encrypted and accessible in one gesture.",
                ),
                const SizedBox(height: 50),
                WelcomeButton(
                  title: "Next",
                  ontap: () {
                    Get.to(() => OnboardingScreen4());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
