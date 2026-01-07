import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/orc_controller.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'dart:ui';

class AddLoyaltyCardScreen extends StatefulWidget {
  const AddLoyaltyCardScreen({super.key});

  @override
  State<AddLoyaltyCardScreen> createState() => _AddLoyaltyCardScreenState();
}

class _AddLoyaltyCardScreenState extends State<AddLoyaltyCardScreen> {
  final orcController = Get.put(OcrController());
  void showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            MyText(text: "Select Image Source", size: 16),

            const SizedBox(height: 24),

            sheetTile(
              icon: Icons.camera_alt,
              title: "Camera",
              onTap: () {
                Get.back();
                orcController.pickImage(fromCamera: true);
              },
            ),

            const SizedBox(height: 16),

            sheetTile(
              icon: Icons.photo_library,
              title: "Gallery",
              onTap: () {
                Get.back();
                orcController.pickImage(fromCamera: false);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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

                  MyText(text: "Scann", size: 16),

                  const Spacer(),
                ],
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              MyText(
                text:
                    "Scan your invoice | receipt | warranty  to help XIUM detect documents.",
                size: 20,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              MyText(
                text: "Position your documents inside the frame.",
                size: 14,
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  showImageSourceSheet();
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF6CA7E7), // top
                        Color(0xFF3463CD), // bottom
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              Spacer(),
              MyText(
                text:
                    "If the store is not recognized, you can select it manually.",
                size: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sheetTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.buttonColor),
            const SizedBox(width: 14),
            MyText(text: title, size: 15),
          ],
        ),
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6;
    const dashSpace = 4;

    final paint = Paint()
      ..color = AppColors.buttonColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
