import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/screens/home/home_screen.dart';
import 'package:xium_app/views/widgets/my_button.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Container(
                height: 300,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xff3463CD).withValues(alpha: 0.27),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// -------- WHITE CIRCLE WITH DONE ICON ----------
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff175293), // ✔ WHITE CIRCLE
                        ),
                        child: Icon(
                          Icons.done,
                          color: AppColors.primary, // ✔ GREEN DONE ICON
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// -------- TITLE --------
                      MyText(
                        text: "Bank connected\n successfully.",
                        size: 18,
                        weight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              MyButton(
                onTap: () {
                  Get.offAll(() => HomeScreen());
                },
                buttonText: "Continue",
                radius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
