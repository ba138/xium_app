import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/auth_controller.dart';
import 'package:xium_app/controller/user_controller.dart';
import 'package:xium_app/views/screens/connect_source/connect_source_screen.dart';
import 'package:xium_app/views/screens/profile/account_managemant_screen.dart';
import 'package:xium_app/views/screens/profile/privacy_policy_screen.dart';
import 'package:xium_app/views/screens/profile/terms_screen.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var authController = Get.put(AuthController());
  var userController = Get.put(UserController());
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
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.onPrimary,
                      ),
                    ),

                    const SizedBox(width: 10),

                    MyText(text: "Profile & Setting", size: 16),

                    const Spacer(),

                    /// ✅ Glassy dotted border container placed here
                  ],
                ),
                const SizedBox(height: 30),
                MyText(text: "User Information", size: 10),
                const SizedBox(height: 12),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.onPrimary,
                              image: DecorationImage(
                                image: NetworkImage(
                                  userController
                                          .user
                                          .value
                                          ?.profilePictureUrl ??
                                      "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text:
                                    userController.user.value?.username ??
                                    "John Doe",
                                size: 16,
                              ),
                              MyText(
                                text:
                                    userController.user.value?.email ??
                                    "johndoe@example.com",
                                size: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => AccountManagemantScreen(
                              name: userController.user.value?.username ?? '',
                              email: userController.user.value?.email ?? '',
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.buttonColor),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: MyText(text: "Edit Profile", size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 30),
                MyText(text: "Connections & Integrations", size: 10),
                const SizedBox(height: 20),
                Obx(() {
                  return Column(
                    children: [
                      profileTile(
                        title: "Gmail",
                        image: Icons.email,
                        isConnected: userController.isEmailConnected,
                      ),
                      Divider(thickness: 0.09),
                      profileTile(
                        title: "Phone",
                        image: Icons.phone,
                        isConnected: userController.isEmailConnected,
                      ),
                      Divider(thickness: 0.09),
                      profileTile(
                        title: "Bank",
                        image: Icons.account_balance,
                        isConnected: userController.isBankConnected,
                      ),
                      Divider(thickness: 0.09),
                      profileTile(
                        title: "Loyalty",
                        image: Icons.credit_card,
                        isConnected: userController.isOcrConnected,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 40),
                MyBorderButton(
                  buttonText: "Manage Connection",
                  onTap: () {
                    Get.to(() => ConnectSourceScreen());
                  },
                  bgColor: Colors.transparent,
                  radius: 12,
                  borderColor: AppColors.buttonColor,
                ),
                const SizedBox(height: 30),
                MyText(text: "Application Settings", size: 10),
                const SizedBox(height: 20),
                Row(
                  children: [
                    MyText(text: "Language"),
                    Spacer(),
                    MyText(text: "English", weight: FontWeight.bold),
                  ],
                ),
                const SizedBox(height: 20),
                MyText(
                  text: "Terms of Service",
                  onTap: () {
                    Get.to(() => TermsOfServiceScreen());
                  },
                ),
                const SizedBox(height: 20),
                MyText(
                  text: "Privacy Policy",
                  onTap: () {
                    Get.to(() => PrivacyPolicyScreen());
                  },
                ),
                const SizedBox(height: 20),

                MyText(text: "Security"),
                const SizedBox(height: 20),
                MyText(
                  text: "Logout",
                  onTap: () {
                    authController.logoutUser();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileTile({
    required IconData image,
    required String title,
    required bool isConnected,
  }) {
    return Row(
      children: [
        Icon(image, size: 30, color: AppColors.buttonColor),
        const SizedBox(width: 10),
        MyText(text: title, size: 16),
        Spacer(),
        MyText(
          text: isConnected ? "Connected" : "Not Connected",
          color: AppColors.grayColor,
        ),
      ],
    );
  }
}
