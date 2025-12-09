import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/glassy_container.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class NeedPermissionScreens extends StatefulWidget {
  const NeedPermissionScreens({super.key});

  @override
  State<NeedPermissionScreens> createState() => _NeedPermissionScreensState();
}

class _NeedPermissionScreensState extends State<NeedPermissionScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonImageView(imagePath: Assets.shiled, height: 60),
              MyText(
                text: "Enable Accessibility",
                size: 24,
                textAlign: TextAlign.start,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              MyText(
                text:
                    "XIUM needs certain authorizations to automatically retrieve your documents and provide you with a smooth  and secure experience",

                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GlassContainer(
                height: MediaQuery.of(context).size.height * 0.33,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text:
                          "You can modify these authorizations at any time in the settings.",
                      size: 16,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(height: 6),
                    MyText(text: "Allow the List of permissions below"),
                    const SizedBox(height: 12),
                    permissionRow(title: "Email", icon: Icons.email),
                    const SizedBox(height: 10),

                    permissionRow(title: "Camera", icon: Icons.camera_alt),
                    const SizedBox(height: 10),

                    permissionRow(
                      title: "Notification",
                      icon: Icons.notifications,
                    ),
                    const SizedBox(height: 10),

                    permissionRow(title: "Bank", icon: Icons.account_balance),
                  ],
                ),
              ),
              Spacer(),
              MyButton(
                onTap: () {},
                buttonText: "Allow and continue",
                radius: 12,
              ),
              const SizedBox(height: 10),
              MyBorderButton(
                buttonText: "Later",
                onTap: () {},
                radius: 12,
                bgColor: Colors.transparent,
                borderColor: AppColors.buttonColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget permissionRow({required String title, required IconData icon}) {
    return Row(
      spacing: 10,
      children: [
        Icon(icon, color: AppColors.buttonColor),
        MyText(text: title, size: 16),
      ],
    );
  }
}
