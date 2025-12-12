import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/screens/connect_source/connect_bank_card.dart';
import 'package:xium_app/views/screens/connect_source/connect_email_screen.dart';
import 'package:xium_app/views/screens/connect_source/connect_phone_screen.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ConnectSourceScreen extends StatefulWidget {
  const ConnectSourceScreen({super.key});

  @override
  State<ConnectSourceScreen> createState() => _ConnectSourceScreenState();
}

class _ConnectSourceScreenState extends State<ConnectSourceScreen> {
  final List<Map<String, dynamic>> sources = [
    {
      "icon": Icons.email,
      "title": "Email",
      "connected": true,
      "subtitle": "Automatically import receipts from your inbox",
      "ontap": () {
        Get.to(() => ConnectEmailScreen());
      },
    },
    {
      "icon": Icons.phone,
      "title": "Phone",
      "connected": false,
      "subtitle": "Automatically import receipts from your inbox",
      "ontap": () {
        Get.to(() => ConnectPhoneScreen());
      },
    },
    {
      "icon": Icons.account_balance,
      "title": "Bank Card",
      "connected": false,
      "subtitle": "Automatically import receipts from your inbox",
      "ontap": () {
        Get.to(() => ConnectBankCard());
      },
    },
    {
      "icon": Icons.credit_card,
      "title": "Loyalty Cards",
      "connected": true,
      "subtitle": "Sync receipts from loyalty accounts.",
      "ontap": () {},
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
                child: GridView.builder(
                  itemCount: sources.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.90,
                  ),
                  itemBuilder: (context, index) {
                    final item = sources[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: GestureDetector(
                          onTap: item['ontap'],
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
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: MyText(
                                    text: item["connected"]
                                        ? "Connected"
                                        : "Not Connected",
                                    size: 10,
                                    weight: FontWeight.w500,
                                    color: item["connected"]
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
                ),
              ),
              MyButton(
                onTap: () {},
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
