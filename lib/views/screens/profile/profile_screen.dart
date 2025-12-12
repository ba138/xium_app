import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/connect_source/connect_source_screen.dart';
import 'package:xium_app/views/screens/profile/account_managemant_screen.dart';
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
                    onTap: () {
                      Get.to(() => AccountManagemantScreen());
                    },
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
              profileTile(title: "Gmail", image: Assets.gmail),
              Divider(thickness: 0.09),
              profileTile(title: "OutLook", image: Assets.outlook),
              Divider(thickness: 0.09),
              profileTile(title: "Bank", image: Assets.bank),
              Divider(thickness: 0.09),
              profileTile(title: "Loyalty", image: Assets.loyalty),
              const SizedBox(height: 40),
              MyBorderButton(
                buttonText: "Manage Connection",
                onTap: () {
                  Get.to(() => ConnectSourceScreen());
                },
                bgColor: Colors.transparent,
                radius: 12,
                borderColor: AppColors.buttonColor,
              ),
              const SizedBox(height: 30),
              MyText(text: "Application Settings", size: 10),
              const SizedBox(height: 20),
              Row(
                children: [
                  MyText(text: "Language"),
                  Spacer(),
                  MyText(text: "English", weight: FontWeight.bold),
                ],
              ),
              const SizedBox(height: 20),
              MyText(text: "Security"),
              const SizedBox(height: 20),
              MyText(text: "Logout"),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileTile({required String image, required String title}) {
    return Row(
      children: [
        CommonImageView(imagePath: image, height: 30),
        const SizedBox(width: 10),
        MyText(text: title, size: 16),
        Spacer(),
        MyText(text: "Connected", color: AppColors.grayColor),
      ],
    );
  }
}
