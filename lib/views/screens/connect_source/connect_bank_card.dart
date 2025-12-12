import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/connect_source/redirecting_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class ConnectBankCard extends StatefulWidget {
  const ConnectBankCard({super.key});

  @override
  State<ConnectBankCard> createState() => _ConnectBankCardState();
}

class _ConnectBankCardState extends State<ConnectBankCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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

              const SizedBox(height: 150),

              Icon(
                Icons.account_balance,
                size: 100,
                color: AppColors.buttonColor,
              ),

              MyText(text: "Connect your bank account", size: 20),
              const SizedBox(height: 10),

              MyText(
                text:
                    "XIUM will detect store names from your transactions to organize your receipts automatically.",
                size: 12,
                color: AppColors.grayColor,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              MyText(
                text: "Secure, encrypted, removable anytime.",
                color: AppColors.buttonColor,
              ),

              const Spacer(),

              MyButton(
                onTap: () => _openBankSelectionSheet(),
                buttonText: "Continue with secure banking",
                radius: 12,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  CommonImageView(imagePath: Assets.tink, height: 30),
                  CommonImageView(imagePath: Assets.bridge, height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBankSelectionSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xff0C1A44), // GREEN COLOR
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.grayColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: MyText(
                text: "Select Bank",
                size: 20,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            MyTextField(
              hint: "Search bank",
              prefix: Icon(Icons.search, color: AppColors.primary),
              radius: 12,
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _bankTile("Revolut", Assets.revolut),
                  const SizedBox(height: 10),
                  _bankTile("N26", Assets.n26),
                  const SizedBox(height: 10),

                  _bankTile("Monzo", Assets.monzo),
                  const SizedBox(height: 10),

                  _bankTile("Barclays", Assets.barclays),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _bankTile(String name, String logo) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Get.to(() => RedirectingScreen());
          },
          child: Row(
            children: [
              CommonImageView(imagePath: logo, height: 40),
              const SizedBox(width: 12),
              MyText(text: name, size: 18, weight: FontWeight.bold),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.grayColor, thickness: 0.5),
      ],
    );
  }
}
