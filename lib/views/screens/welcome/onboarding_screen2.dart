import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/welcome/onboarding_screen3.dart';
import 'package:xium_app/views/screens/welcome/widgets/welcome_button.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
                    GestureDetector(
                      onTap: () {
                        _showLanguageBottomSheet();
                      },
                      child: Row(
                        children: [
                          MyText(
                            text: "Language".tr,
                            color: Colors.transparent,
                          ),
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
                    const Spacer(),

                    /// IMAGE (same vertical logic as screen 1)
                    CommonImageView(
                      imagePath: Assets.welcomeImage2,
                      height: constraints.maxHeight * 0.22,
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
                      ],
                    ),

                    const Spacer(),

                    /// TITLE
                    Align(
                      alignment: Alignment.topLeft,
                      child: MyText(
                        text: "onboard2_title".tr,
                        size: 24,
                        weight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// SUBTITLE
                    MyText(text: "onboard2_subtitle".tr),

                    const SizedBox(height: 40),

                    /// BUTTON
                    WelcomeButton(
                      title: "next_button".tr,
                      ontap: () {
                        Get.to(() => OnboardingScreen3());
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
