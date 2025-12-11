import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'dart:ui';

class AddLoyaltyCardScreen extends StatelessWidget {
  const AddLoyaltyCardScreen({super.key});

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

                  MyText(text: "Add your loyalty cards", size: 16),

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
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              MyText(
                text: "Scan your loyalty card to help XIUM detect receipts.",
                size: 20,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              MyText(text: "Position your card inside the frame.", size: 14),
              const SizedBox(height: 50),
              Container(
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
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 28),
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
