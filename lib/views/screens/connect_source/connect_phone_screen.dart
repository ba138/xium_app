import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/phone_connect_controller.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ConnectPhoneScreen extends StatefulWidget {
  const ConnectPhoneScreen({super.key});

  @override
  State<ConnectPhoneScreen> createState() => _ConnectPhoneScreenState();
}

class _ConnectPhoneScreenState extends State<ConnectPhoneScreen> {
  String selectedCode = "+1";
  final TextEditingController phoneController = TextEditingController();
  var phoneConnectController = Get.put(PhoneConnectController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02071A), // dark gradient BG look
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// BACK BUTTON + TITLE
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

              MyText(text: "Connect Phone number", size: 20),
              const SizedBox(height: 10),

              MyText(
                text:
                    "Receive digital receipts automatically from stores\nthat send SMS confirmations.",
                size: 12,
                color: AppColors.grayColor,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// SCREEN TITLE

              /// ADD PHONE LABEL
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  MyText(text: "Add Phone No", weight: FontWeight.bold),
                ],
              ),

              const SizedBox(height: 12),

              /// PHONE INPUT GLASSY BOX
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        /// COUNTRY PICKER
                        CountryCodePicker(
                          onChanged: (code) {
                            setState(() {
                              selectedCode = code.dialCode ?? "+1";
                            });
                          },
                          barrierColor: Colors.transparent,
                          backgroundColor: AppColors.background,
                          initialSelection: 'US',
                          favorite: const ['US', '+1'],
                          showCountryOnly: false,
                          showFlagMain: true,
                          showFlagDialog: true,
                          flagWidth: 25,
                          textStyle: const TextStyle(color: Colors.white),
                          padding: EdgeInsets.zero,
                        ),

                        const SizedBox(width: 8),

                        /// PHONE TEXTFIELD
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "1234-2323",
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              MyButton(
                onTap: () {
                  phoneConnectController.connectPhone(
                    phoneController.text,
                    selectedCode,
                  );
                },
                buttonText: "Connect phone number",
                radius: 12,
              ),

              const SizedBox(height: 18),

              /// FOOTER TEXT
              const Center(
                child: Text(
                  "Your number is used only to detect receipts.\nNo SMS will be sent.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
