import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.onPrimary,
                    ),
                  ),

                  const SizedBox(width: 10),

                  MyText(text: "Profile & Setting", size: 16),

                  const Spacer(),

                  /// ✅ Glassy dotted border container placed here
                ],
              ),
              const SizedBox(height: 30),
              MyText(text: "User Information", size: 10),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(text: "John Doe", size: 16),
                          MyText(text: "johndoe@example.com", size: 10),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.buttonColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: MyText(text: "Edit Profile", size: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              MyText(text: "Connections & Integrations", size: 10),
              const SizedBox(height: 20),
              profileTile(),
              Divider(thickness: 0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileTile() {
    return Row(
      children: [
        CommonImageView(imagePath: Assets.gmail, height: 40),
        MyText(text: "Gmail", size: 16),
        Spacer(),
        MyText(text: "Connected", color: AppColors.grayColor),
      ],
    );
  }
}
