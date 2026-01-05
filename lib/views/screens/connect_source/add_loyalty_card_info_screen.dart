import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/loyalty_card_controller.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class AddLoyaltyInfoScreen extends StatelessWidget {
  AddLoyaltyInfoScreen({super.key});

  final TextEditingController storeController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  var loyaltyCardController = Get.put(LoyaltyCardController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 Back
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MyText(text: "Back", size: 16),
                ],
              ),

              const SizedBox(height: 30),

              /// 🏷 Title
              MyText(
                text: "Add Loyalty Card",
                size: 22,
                weight: FontWeight.w600,
              ),

              const SizedBox(height: 8),

              MyText(
                text:
                    "Save your loyalty cards to automatically link receipts and track rewards.",
                size: 12,
                color: AppColors.grayColor,
              ),

              const SizedBox(height: 30),

              /// 🧊 Glass Card
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        _inputField(
                          controller: storeController,
                          label: "Store Name",
                          hint: "e.g. Nike, Amazon, Starbucks",
                          icon: Icons.store,
                        ),

                        const SizedBox(height: 16),

                        _inputField(
                          controller: cardNumberController,
                          label: "Loyalty Card Number",
                          hint: "Enter membership ID",
                          icon: Icons.credit_card,
                        ),

                        const SizedBox(height: 16),

                        _inputField(
                          controller: nicknameController,
                          label: "Nickname (Optional)",
                          hint: "e.g. My Nike Card",
                          icon: Icons.edit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// 💾 Save Button
              MyButton(
                buttonText: "Save Loyalty Card",
                radius: 14,
                onTap: () {
                  // 🔜 Connect logic later
                  loyaltyCardController.addLoyaltyCard(
                    storeName: storeController.text,
                    cardNumber: cardNumberController.text,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Reusable Input Field
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(text: label, size: 12),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: AppColors.buttonColor),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
