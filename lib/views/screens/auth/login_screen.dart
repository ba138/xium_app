import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/auth/forget_password_screen.dart';
import 'package:xium_app/views/screens/auth/register_screen.dart';
import 'package:xium_app/views/screens/starting/need_permission_screens.dart';
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
                    Get.offAll(() => NeedPermissionScreens());
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
                Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassiyButton(
                      title: "Google",
                      ontap: () {},
                      image: Assets.google,
                    ),
                    GlassiyButton(
                      title: "Facebook",
                      ontap: () {},
                      image: Assets.fb,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

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
