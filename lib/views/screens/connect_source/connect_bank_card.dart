import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

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
              Spacer(),
              MyButton(
                onTap: () {},
                buttonText: "Continue with secure banking",
                radius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
