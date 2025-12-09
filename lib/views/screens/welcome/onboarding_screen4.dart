import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
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
                CommonImageView(imagePath: Assets.logo),
                Spacer(),
                MyButton(
                  onTap: () {
                    Get.offAll(() => LoginScreen());
                  },
                  buttonText: "Login with Email and Password",
                  radius: 12,
                  hasicon: true,
                  choiceIcon: Assets.phone,
                ),
                const SizedBox(height: 20),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.grayColor,
                      ),
                    ),
                    MyText(text: "Or login with "),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  spacing: 12,
                  children: [
                    GlassiyButton(
                      title: "Google",
                      ontap: () {},
                      image: Assets.google,
                    ),
                    GlassiyButton(
                      title: "Google",
                      ontap: () {},
                      image: Assets.fb,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
