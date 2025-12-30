import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/auth_controller.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/auth/forget_password_screen.dart';
import 'package:xium_app/views/screens/auth/register_screen.dart';
import 'package:xium_app/views/screens/welcome/widgets/glassiy_button.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                  text: "Sign in to your Account",
                  size: 32,
                  textAlign: TextAlign.start,
                  weight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                MyText(text: "Sign in to your Account"),
                SizedBox(height: 40),

                MyTextField(
                  hint: "Alexanold@mail.com",
                  radius: 12,
                  label: "Email",
                  controller: emailController,
                ),
                Obx(() {
                  return MyTextField(
                    hint: "******",
                    radius: 12,
                    label: "Password",
                    suffix: GestureDetector(
                      onTap: () {
                        authController.isPasswordHidden.value =
                            !authController.isPasswordHidden.value;
                      },
                      child: Icon(
                        authController.isPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: authController.isPasswordHidden.value
                            ? AppColors.onPrimary
                            : AppColors.buttonColor,
                      ),
                    ),
                    controller: passwordController,
                    isObSecure: authController.isPasswordHidden.value,
                  );
                }),
                Align(
                  alignment: Alignment.topRight,
                  child: MyText(
                    text: "Forget Password?",
                    color: AppColors.buttonColor,
                    onTap: () {
                      Get.to(() => ForgetPasswordScreen());
                    },
                  ),
                ),
                const SizedBox(height: 30),
                MyButton(
                  onTap: () {
                    authController.loginUser(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  buttonText: "Login",
                  radius: 12,
                ),
                const SizedBox(height: 20),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.grayColor,
                      ),
                    ),
                    MyText(text: "Or login with "),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Platform.isAndroid
                    ? GlassiyButton(
                        title: "Sign In With Google",
                        ontap: () {
                          authController.signInWithGoogle();
                        },
                        image: Assets.google,
                      )
                    : SizedBox.shrink(),
                const SizedBox(height: 12),
                Platform.isIOS
                    ? GlassiyButton(
                        title: "Sign In With Apple",
                        ontap: () {
                          // authController.signInWithApple();
                        },
                        image: Assets.fb,
                      )
                    : SizedBox.shrink(),
                const SizedBox(height: 80),

                Row(
                  spacing: 6,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(text: "Dont’t have an account?"),

                    MyText(
                      text: "Register",
                      color: AppColors.buttonColor,
                      weight: FontWeight.bold,
                      onTap: () {
                        Get.to(() => RegisterScreen());
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
