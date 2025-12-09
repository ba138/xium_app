import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/welcome/onboarding_screen2.dart';
import 'package:xium_app/views/screens/welcome/widgets/welcome_button.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/glassy_container.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.gobgimage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  GlassContainer(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    child: Center(
                      child: CommonImageView(
                        imagePath: Assets.welcomeImage1,
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
                        width: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppColors.onPrimary,
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
                        width: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  MyText(
                    text: "Centralize everything automatically",
                    size: 24,
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 12),
                  MyText(
                    text:
                        "Your receipts, invoices and warranties are collected and sorted effortlessly",
                  ),
                  const SizedBox(height: 30),
                  WelcomeButton(
                    title: "Next",
                    ontap: () {
                      Get.to(() => OnboardingScreen2());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
