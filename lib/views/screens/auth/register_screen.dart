import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/screens/auth/login_screen.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                MyText(
                  text: "Register",
                  size: 32,
                  textAlign: TextAlign.start,
                  weight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                MyText(text: "Create your Account"),
                SizedBox(height: 40),
                MyTextField(hint: "Alex", radius: 12, label: "Full Name"),
                MyTextField(
                  hint: "Alexanold@mail.com",
                  radius: 12,
                  label: "Email",
                ),
                MyTextField(
                  hint: "******",
                  radius: 12,
                  label: "Password",
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: AppColors.onPrimary,
                  ),
                ),
                MyTextField(
                  hint: "******",
                  radius: 12,
                  label: "Repeat Password",
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: AppColors.onPrimary,
                  ),
                ),

                const SizedBox(height: 30),
                MyButton(onTap: () {}, buttonText: "Register", radius: 12),
                const SizedBox(height: 40),

                Row(
                  spacing: 6,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(text: "Already have account?"),

                    MyText(
                      text: "Login",
                      color: AppColors.buttonColor,
                      weight: FontWeight.bold,
                      onTap: () {
                        Get.to(() => LoginScreen());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
