import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/welcome/onboarding_screen4.dart';
import 'package:xium_app/views/screens/welcome/widgets/welcome_button.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

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
                    const Spacer(),

                    /// IMAGE
                    CommonImageView(
                      imagePath: Assets.welcomeImage3,
                      height: constraints.maxHeight * 0.2,
                    ),

                    const SizedBox(height: 40),

                    /// INDICATOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        const SizedBox(width: 8),
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

                    const Spacer(),

                    /// TITLE
                    Align(
                      alignment: Alignment.topLeft,
                      child: MyText(
                        text: "Secure. Simple. Instant",
                        size: 24,
                        weight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// SUBTITLE
                    Align(
                      alignment: Alignment.topLeft,
                      child: MyText(
                        text:
                            "Your data is encrypted and accessible in one gesture.",
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// BUTTON
                    WelcomeButton(
                      title: "Next",
                      ontap: () {
                        Get.to(() => OnboardingScreen4());
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
