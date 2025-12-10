import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class DocViewScreen extends StatelessWidget {
  const DocViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      MyText(text: "Invoice – Walmart", size: 16),
                    ],
                  ),
                  MyText(text: "+ More", size: 16, onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
