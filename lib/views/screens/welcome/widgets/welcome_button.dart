import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class WelcomeButton extends StatelessWidget {
  final String title;
  final VoidCallback ontap;
  const WelcomeButton({super.key, required this.ontap, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(0xff3463CD),
        ),
        child: Row(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(text: title, size: 16),
            Icon(Icons.arrow_forward, color: AppColors.onPrimary, size: 16),
          ],
        ),
      ),
    );
  }
}
