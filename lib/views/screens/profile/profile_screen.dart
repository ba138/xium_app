import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/auth_controller.dart';
import 'package:xium_app/controller/user_controller.dart';
import 'package:xium_app/views/screens/connect_source/connect_source_screen.dart';
import 'package:xium_app/views/screens/profile/account_managemant_screen.dart';
import 'package:xium_app/views/screens/profile/privacy_policy_screen.dart';
import 'package:xium_app/views/screens/profile/security_screen.dart';
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

                    MyText(text: "Profile & Setting".tr, size: 16),

                    const Spacer(),

                    /// ✅ Glassy dotted border container placed here
                  ],
                ),
                const SizedBox(height: 30),
                MyText(text: "User Information".tr, size: 10),
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
                MyText(text: "Connections & Integrations".tr, size: 10),
                const SizedBox(height: 20),
                Obx(() {
                  return Column(
                    children: [
                      profileTile(
                        title: "Gmail".tr,
                        image: Icons.email,
                        isConnected: userController.isEmailConnected,
                      ),
                      Divider(thickness: 0.09),
                      profileTile(
                        title: "Phone".tr,
                        image: Icons.phone,
                        isConnected: userController.isEmailConnected,
                      ),
                      Divider(thickness: 0.09),
                      profileTile(
                        title: "Bank".tr,
                        image: Icons.account_balance,
                        isConnected: userController.isBankConnected,
                      ),
                      Divider(thickness: 0.09),
                      profileTile(
                        title: "Loyalty".tr,
                        image: Icons.credit_card,
                        isConnected: userController.isOcrConnected,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 40),
                MyBorderButton(
                  buttonText: "Manage Connection".tr,
                  onTap: () {
                    Get.to(() => ConnectSourceScreen());
                  },
                  bgColor: Colors.transparent,
                  radius: 12,
                  borderColor: AppColors.buttonColor,
                ),
                const SizedBox(height: 30),
                MyText(text: "Application Settings".tr, size: 10),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    _showLanguageBottomSheet();
                  },
                  child: Row(
                    children: [
                      MyText(text: "Language".tr),
                      const Spacer(),
                      MyText(
                        text: Get.locale?.languageCode == 'fr'
                            ? "Français"
                            : "English",
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MyText(
                  text: "Terms of Service".tr,
                  onTap: () {
                    Get.to(() => TermsOfServiceScreen());
                  },
                ),
                const SizedBox(height: 20),
                MyText(
                  text: "Privacy Policy".tr,
                  onTap: () {
                    Get.to(() => PrivacyPolicyScreen());
                  },
                ),
                const SizedBox(height: 20),

                MyText(
                  text: "Security".tr,
                  onTap: () {
                    Get.to(() => SecurityScreen());
                  },
                ),
                const SizedBox(height: 20),
                MyText(
                  text: "Logout".tr,
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
          text: isConnected ? "Connected".tr : "Not Connected".tr,
          color: AppColors.grayColor,
        ),
      ],
    );
  }

  void _showLanguageBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            /// English
            _languageTile(title: "English", locale: const Locale('en', 'US')),

            const SizedBox(height: 12),

            /// French
            _languageTile(title: "Français", locale: const Locale('fr', 'FR')),
          ],
        ),
      ),
    );
  }

  Widget _languageTile({required String title, required Locale locale}) {
    final isSelected = Get.locale?.languageCode == locale.languageCode;
    final box = GetStorage();

    return InkWell(
      onTap: () {
        Get.updateLocale(locale);

        // ✅ SAVE LANGUAGE HERE
        box.write('lang', locale.languageCode);

        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
