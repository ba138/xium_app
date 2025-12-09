import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_Text.dart';

class GlassiyButton extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback ontap;

  const GlassiyButton({
    super.key,
    required this.title,
    required this.image,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // blur behind
          child: Container(
            height: 56,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // 🌫️ Glass color overlay
              color: Colors.white.withOpacity(0.12),
              // 🌟 Soft border
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.2,
              ),
              // ✨ Subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonImageView(imagePath: image, height: 20),
                MyText(text: title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
