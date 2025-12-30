import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/auth_controller.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/auth/login_screen.dart';
import 'package:xium_app/views/screens/welcome/widgets/glassiy_button.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.put(AuthController());
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
                Form(
                  key: authController.formKey,
                  child: Column(
                    children: [
                      MyTextField(
                        hint: "Alex",
                        radius: 12,
                        label: "Full Name",
                        controller: authController.fullNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First Name is required';
                          }
                          return null;
                        },
                      ),
                      MyTextField(
                        hint: "Alexanold@mail.com",
                        radius: 12,
                        label: "Email",
                        controller: authController.emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid Email Address';
                          }
                          return null;
                        },
                      ),
                      Obx(() {
                        return MyTextField(
                          hint: "******",
                          radius: 12,
                          label: "Password",
                          suffix: GestureDetector(
                            onTap: () {
                              authController.isShowRegister.value =
                                  !authController.isShowRegister.value;
                            },
                            child: Icon(
                              authController.isShowRegister.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: authController.isShowRegister.value
                                  ? AppColors.onPrimary
                                  : AppColors.buttonColor,
                            ),
                          ),
                          isObSecure: !authController.isShowRegister.value,
                          controller: authController.passwordController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        );
                      }),
                      Obx(() {
                        return MyTextField(
                          hint: "******",
                          radius: 12,
                          label: "Repeat Password",
                          suffix: GestureDetector(
                            onTap: () {
                              authController.isShowRepeatPassword.value =
                                  !authController.isShowRepeatPassword.value;
                            },
                            child: Icon(
                              authController.isShowRepeatPassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: authController.isShowRepeatPassword.value
                                  ? AppColors.onPrimary
                                  : AppColors.buttonColor,
                            ),
                          ),
                          isObSecure:
                              !authController.isShowRepeatPassword.value,
                          controller: authController.repeatPasswordController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please repeat your password';
                            }

                            if (authController.repeatPasswordController.text !=
                                authController.passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                MyButton(
                  onTap: () {
                    authController.createUser();
                  },
                  buttonText: "Register",
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
                    MyText(text: "Or Register with "),
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
                        title: "Register With Google",
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
