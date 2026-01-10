import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/welcome/onboarding_screen2.dart';
import 'package:xium_app/views/screens/welcome/widgets/welcome_button.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.gobgimage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Spacer(),

                    /// IMAGE
                    CommonImageView(
                      imagePath: Assets.welcomeImage1,
                      height: constraints.maxHeight * 0.3,
                    ),

                    const SizedBox(height: 40),

                    /// INDICATOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 5,
                          width: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grayColor,
                          ),
                        ),
                        const SizedBox(width: 8),
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

                    const Spacer(),

                    /// TITLE
                    MyText(
                      text: "Centralize everything automatically",
                      size: 24,
                      weight: FontWeight.w500,
                    ),

                    const SizedBox(height: 12),

                    /// SUBTITLE
                    MyText(
                      text:
                          "Your receipts, invoices and warranties are collected and sorted effortlessly",
                    ),
                    const SizedBox(height: 40),

                    /// BUTTON
                    WelcomeButton(
                      title: "Next",
                      ontap: () {
                        Get.to(() => OnboardingScreen2());
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
