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
        child: GestureDetector(
          onTap: () {
            // This will close the keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior
              .translucent, // ensures taps on empty space are detected
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  MyText(
                    text: "sign_in_account".tr,
                    size: 32,
                    textAlign: TextAlign.start,
                    weight: FontWeight.bold,
                  ),
                  SizedBox(height: 8),
                  MyText(text: "sign_in_account".tr),
                  SizedBox(height: 40),

                  MyTextField(
                    hint: "example@gmail.com",
                    radius: 12,
                    label: "email".tr,
                    controller: emailController,
                  ),
                  Obx(() {
                    return MyTextField(
                      hint: "*********",
                      radius: 12,
                      label: "password".tr,
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
                      text: "forget_password".tr,
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
                    buttonText: "login".tr,
                    radius: 12,
                  ),
                  const SizedBox(height: 20),
                  Platform.isIOS
                      ? SizedBox.shrink()
                      : Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: AppColors.grayColor,
                              ),
                            ),
                            MyText(text: "or_login_with".tr),
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
                          title: "sign_in_google".tr,
                          ontap: () {
                            authController.signInWithGoogle();
                          },
                          image: Assets.google,
                        )
                      : SizedBox.shrink(),
                  // const SizedBox(height: 12),
                  // Platform.isIOS
                  //     ? GlassiyButton(
                  //         title: "sign_in_apple".tr,
                  //         ontap: () {
                  //           authController.signInWithApple();
                  //         },
                  //         image: Assets.fb,
                  //       )
                  //     : SizedBox.shrink(),
                  SizedBox(height: Platform.isIOS ? 40 : 80),

                  Row(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(text: "dont_have_account".tr),
                      MyText(
                        text: "register".tr,
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
      ),
    );
  }
}
