import 'package:flutter/material.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_button.dart';

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CommonImageView(imagePath: Assets.logo),
              MyButton(
                onTap: () {},
                buttonText: "Login with Email and Password",
                radius: 12,
                hasicon: true,
                choiceIcon: Assets.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
