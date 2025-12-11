import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/home/widgets/add_expanses_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class DocViewScreen extends StatelessWidget {
  const DocViewScreen({super.key});

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
                    MyText(
                      text: "+ More",
                      size: 16,
                      onTap: () {
                        Get.to((AddExpenseScreen()));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CommonImageView(imagePath: Assets.receipt),
                const SizedBox(height: 20),
                docTile(title: 'Amount', subTitle: "\$20", ontap: () {}),
                docTile(
                  title: 'Merchant',
                  subTitle: "John Smith",
                  ontap: () {},
                ),
                docTile(title: 'Date', subTitle: "02/12/2025", ontap: () {}),
                docTile(title: 'Source', subTitle: "Email", ontap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget docTile({
    required String title,
    required String subTitle,
    required VoidCallback ontap,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: title),
                MyText(text: subTitle, size: 18, weight: FontWeight.bold),
              ],
            ),
            GestureDetector(
              onTap: ontap,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 24,
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(thickness: 0.6),
      ],
    );
  }
}
