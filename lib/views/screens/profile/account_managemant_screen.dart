import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/user_controller.dart';
import 'package:xium_app/views/widgets/glassy_container.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class AccountManagemantScreen extends StatefulWidget {
  final String name;
  final String email;

  const AccountManagemantScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<AccountManagemantScreen> createState() =>
      _AccountManagemantScreenState();
}

class _AccountManagemantScreenState extends State<AccountManagemantScreen> {
  var controller = Get.put(UserController());
  @override
  void initState() {
    controller.nameController.text = widget.name;
    controller.emailController.text = widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
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

                    MyText(text: "Account Management", size: 16),

                    const Spacer(),

                    /// ✅ Glassy dotted border container placed here
                  ],
                ),
                const SizedBox(height: 40),
                GlassContainer(
                  height: MediaQuery.of(context).size.height * 0.63,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      MyText(text: "Edit my information", size: 16),
                      const SizedBox(height: 20),
                      MyTextField(
                        hint: "Your Full Name",
                        label: "Name",
                        radius: 12,
                        controller: controller.nameController,
                      ),
                      MyTextField(
                        hint: "Salmanuix@gmail.com",
                        label: "Email",
                        radius: 12,
                        controller: controller.emailController,
                      ),
                      MyTextField(
                        hint: "********",
                        label: "Password",
                        radius: 12,

                        isReadOnly: true,
                        controller: controller.currentPasswordController,
                      ),
                      MyTextField(
                        hint: "********",
                        label: "New Password",
                        radius: 12,
                        controller: controller.newPasswordController,
                      ),
                      const SizedBox(height: 30),
                      MyButton(
                        onTap: () {
                          controller.updateUserInfo();
                        },
                        buttonText: "Save Changes",
                        radius: 12,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: MyText(
                          text: "Update your information and save the changes",
                          size: 12,
                          color: AppColors.grayColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      MyText(
                        text: "Delete my account",
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        text:
                            "Deleting your account will permanently remove all documents and data. This cannot be undone",
                        size: 12,
                        color: AppColors.grayColor,
                      ),
                      const SizedBox(height: 40),
                      MyButton(
                        onTap: () {
                          Get.defaultDialog(
                            title: "Delete Account",
                            middleText: "This action is permanent. Continue?",
                            textConfirm: "Delete",
                            textCancel: "Cancel",
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back();
                              controller.deleteUserAccount();
                            },
                          );
                        },
                        buttonText: "Delete permanently",
                        radius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
