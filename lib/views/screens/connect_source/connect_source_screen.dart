import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/user_controller.dart';
import 'package:xium_app/views/screens/connect_source/connect_bank_card.dart';
import 'package:xium_app/views/screens/connect_source/connect_email_screen.dart';
import 'package:xium_app/views/screens/connect_source/connect_phone_screen.dart';
import 'package:xium_app/views/screens/home/add_loyalty_card_screen.dart';
import 'package:xium_app/views/screens/starting/cube_screen.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ConnectSourceScreen extends StatefulWidget {
  const ConnectSourceScreen({super.key});

  @override
  State<ConnectSourceScreen> createState() => _ConnectSourceScreenState();
}

class _ConnectSourceScreenState extends State<ConnectSourceScreen> {
  var userController = Get.put(UserController());
  final List<Map<String, dynamic>> sources = [
    {
      "key": "email",
      "icon": Icons.email,
      "title": "Email",
      "subtitle": "Automatically import receipts from your inbox",
      "ontap": () => Get.to(() => ConnectEmailScreen()),
    },
    {
      "key": "sms",
      "icon": Icons.phone,
      "title": "Phone",
      "subtitle": "Automatically import receipts from your inbox",
      "ontap": () => Get.to(() => ConnectPhoneScreen()),
    },
    {
      "key": "bank",
      "icon": Icons.account_balance,
      "title": "Bank Card",
      "subtitle": "Automatically import receipts from your bank",
      "ontap": () => Get.to(() => ConnectBankCard()),
    },
    {
      "key": "osr",
      "icon": Icons.credit_card,
      "title": "Loyalty Cards",
      "subtitle": "Sync receipts from loyalty accounts",
      "ontap": () => Get.to(() => AddLoyaltyCardScreen()),
    },
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
                  MyText(text: "Back", size: 16),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 30),

              MyText(text: "Connect Sources", size: 20),
              const SizedBox(height: 10),

              MyText(
                text:
                    "Connect your sources to automatically collect and organize all your receipts, invoices and warranties.",
                size: 12,
                color: AppColors.grayColor,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Obx(() {
                  final user = userController.user.value;

                  if (user == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                    itemCount: sources.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: 0.90,
                        ),
                    itemBuilder: (context, index) {
                      final item = sources[index];
                      final String key = item["key"];

                      final bool connected = user.source[key] == "connected";

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: GestureDetector(
                            onTap: () {
                              // if (connected) {
                              //   Get.snackbar(
                              //     "Already Connected",
                              //     "${item["title"]} is already connected",
                              //     snackPosition: SnackPosition.TOP,
                              //     backgroundColor: Colors.black87,
                              //     colorText: Colors.white,
                              //   );
                              // } else {
                              //   item["ontap"]();
                              // }
                              item["ontap"]();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item["icon"],
                                        size: 20,
                                        color: AppColors.buttonColor,
                                      ),
                                      const SizedBox(width: 6),
                                      MyText(
                                        text: item["title"],
                                        size: 14,
                                        weight: FontWeight.w600,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: MyText(
                                      text: connected
                                          ? "Connected"
                                          : "Not Connected",
                                      size: 10,
                                      weight: FontWeight.w500,
                                      color: connected
                                          ? Colors.greenAccent
                                          : AppColors.onPrimary,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  MyText(
                                    text: item["subtitle"],
                                    size: 11,
                                    color: AppColors.grayColor,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              MyButton(
                onTap: () {
                  Get.to(() => CubeScreen());
                },
                buttonText: "Continue without connecting",
                radius: 12,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
