import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class NoSourceFoundScreen extends StatelessWidget {
  const NoSourceFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    // Image
                    child: Center(
                      child: CommonImageView(
                        imagePath: Assets.source,
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              MyText(
                text: "No stores detected yet.",
                size: 20,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              MyText(text: "Connect a source to start automatic retrieval"),
              Spacer(),
              MyButton(onTap: () {}, buttonText: "Connect_Sources", radius: 12),
              const SizedBox(height: 10),
              MyBorderButton(
                buttonText: "Skip",
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
}
