import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/screens/home/add_loyalty_card_screen.dart';
import 'package:xium_app/views/screens/home/document_screen.dart';
import 'package:xium_app/views/screens/home/home_screen.dart';
import 'package:xium_app/views/screens/home/rewards_screen.dart';
import 'package:xium_app/views/screens/profile/profile_screen.dart';

// Import your screens

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.add_circle_outline,

    Icons.card_giftcard_outlined,
    Icons.settings_outlined,
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const DocumentScreen(),
    const AddLoyaltyCardScreen(),

    const RewardsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex], // Display selected screen

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: 50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient background behind nav bar (left side only)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          AppColors.buttonColor.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Glassy nav bar with cutout
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: CustomPaint(
                      painter: GlassNavBarPainter(
                        notchX: _circleCenterX(context, _currentIndex),
                        notchWidth: 80,
                        notchHeight: 100,
                      ),
                      child: SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_icons.length, (index) {
                            bool isSelected = _currentIndex == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _currentIndex = index),
                              child: SizedBox(
                                width: 56,
                                height: 70,
                                child: Center(
                                  child: isSelected
                                      ? const SizedBox(width: 28, height: 28)
                                      : Icon(
                                          _icons[index],
                                          size: 28,
                                          color: Colors.white70,
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating circle with red fill for selected icon
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                bottom: 28,
                left: _circleCenterX(context, _currentIndex) - 28,
                child: _buildCircle(_icons[_currentIndex], selected: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _circleCenterX(BuildContext context, int index) {
    double width = MediaQuery.of(context).size.width;
    double itemWidth = width / _icons.length;
    return itemWidth * index + itemWidth / 2;
  }

  Widget _buildCircle(IconData icon, {bool selected = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: selected ? AppColors.buttonColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassNavBarPainter extends CustomPainter {
  final double notchX;
  final double notchWidth;
  final double notchHeight;

  GlassNavBarPainter({
    required this.notchX,
    this.notchWidth = 80,
    this.notchHeight = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, glassPaint);

    final Paint clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    Rect notchRect = Rect.fromCenter(
      center: Offset(notchX, 0),
      width: notchWidth,
      height: notchHeight,
    );

    canvas.drawOval(notchRect, clearPaint);
  }

  @override
  bool shouldRepaint(GlassNavBarPainter oldDelegate) =>
      oldDelegate.notchX != notchX;
}
