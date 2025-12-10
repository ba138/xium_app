import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/home/home_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_Text.dart';

class CubeScreen extends StatelessWidget {
  const CubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onTap: () {
              Get.offAll(() => HomeScreen());
            },
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                CommonImageView(imagePath: Assets.cube),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_up_sharp,
                  size: 60,
                  color: AppColors.onPrimary,
                ),
                Icon(
                  Icons.keyboard_arrow_up_sharp,
                  size: 40,
                  color: AppColors.onPrimary,
                ),
                MyText(text: "Tap to enter your XIUM space"),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
