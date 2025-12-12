import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ConnectEmailScreen extends StatefulWidget {
  const ConnectEmailScreen({super.key});

  @override
  State<ConnectEmailScreen> createState() => _ConnectEmailScreenState();
}

class _ConnectEmailScreenState extends State<ConnectEmailScreen> {
  int selectedIndex = -1; // nothing selected initially

  final List<Map<String, dynamic>> emailOptions = [
    {"image": Assets.gmail, "title": "Sign In with Gmail"},
    {"image": Assets.outlook, "title": "Sign In with Outlook"},
    {"image": Assets.mail, "title": "Sign in with another address"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyText(text: "Connect Email", size: 16),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 30),
              MyText(text: "Connect your email address", size: 20),
              const SizedBox(height: 10),
              MyText(
                text:
                    "To automatically retrieve your invoices, receipts and warranties sent by email",
                size: 12,
                color: AppColors.grayColor,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              /// ========================
              ///     FOUR CONTAINERS
              /// ========================
              Expanded(
                child: ListView.separated(
                  itemCount: emailOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    final data = emailOptions[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.greenAccent,
                                      width: 0.5,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                CommonImageView(
                                  imagePath: data['image'],
                                  height: 30,
                                ),
                                const SizedBox(width: 14),

                                /// TEXT
                                MyText(
                                  text: data["title"],
                                  size: 14,
                                  weight: FontWeight.w600,
                                ),

                                const Spacer(),

                                /// GREEN CIRCLE + DONE ICON
                                if (isSelected)
                                  Container(
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.done,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Spacer(),
              MyButton(onTap: () {}, buttonText: "Save Changes", radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}
