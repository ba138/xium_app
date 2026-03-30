import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/auth_controller.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  var emailController = TextEditingController();
  var authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onError),
        ),
        title: MyText(
          text: "forgot_password".tr,
          size: 18,
          color: AppColors.onError,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Close the keyboard when user taps outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  MyText(text: "enter_email_reset".tr, size: 16),
                  SizedBox(height: 40),

                  MyTextField(
                    hint: "example@gmail.com",
                    radius: 12,
                    label: "email".tr,
                    controller: emailController,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  MyButton(
                    onTap: () {
                      authController.resetPassword(emailController.text);
                    },
                    buttonText: "continue".tr,
                    radius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
