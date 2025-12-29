import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                MyText(
                  text: "Forgot Password",
                  size: 32,
                  textAlign: TextAlign.start,
                  weight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                MyText(text: "Enter your email account to reset password"),
                SizedBox(height: 40),

                MyTextField(
                  hint: "Alexanold@mail.com",
                  radius: 12,
                  label: "Email",
                  controller: emailController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                MyButton(
                  onTap: () {
                    authController.resetPassword(emailController.text);
                  },
                  buttonText: "Continue",
                  radius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
