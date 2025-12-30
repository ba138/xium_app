import 'dart:ui';
import 'package:flutter/material.dart';
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
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), // blur behind
          child: Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // 🌫️ Glass color overlay
              color: Colors.white.withValues(alpha: 0.12),
              // 🌟 Soft border
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.5,
              ),
              // ✨ Subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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
