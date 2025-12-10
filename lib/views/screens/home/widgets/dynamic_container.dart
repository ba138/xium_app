import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class DynamicContainer extends StatelessWidget {
  final String text;
  final bool isSelected;

  const DynamicContainer({
    super.key,
    required this.text,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors
                      .buttonColor // selected color
                : Colors.white.withValues(alpha: 0.20),
            border: Border.all(
              color: isSelected
                  ? AppColors.buttonColor
                  : Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: MyText(
            text: text,
            size: 12,
            weight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
