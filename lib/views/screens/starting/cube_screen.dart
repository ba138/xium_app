import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/views/screens/home/home_screen.dart';
import 'package:xium_app/views/widgets/my_Text.dart';

class CubeScreen extends StatefulWidget {
  const CubeScreen({super.key});

  @override
  State<CubeScreen> createState() => _CubeScreenState();
}

class _CubeScreenState extends State<CubeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 🔥 rotate for EXACT 3 SECONDS
    );

    rotation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Get.offAll(() => const HomeScreen());
      }
    });
  }

  void rotateAndGo() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050B18),
      body: SafeArea(
        child: GestureDetector(
          onTap: rotateAndGo,
          child: Column(
            children: [
              const SizedBox(height: 30),

              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: rotation,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: rotation.value * pi,
                        child: Image.asset(
                          "assets/images/cube.png",
                          width: 260,
                          height: 260,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Icon(Icons.keyboard_arrow_up, size: 50, color: Colors.white),
              Icon(Icons.keyboard_arrow_up, size: 35, color: Colors.white),

              const SizedBox(height: 8),

              MyText(
                text: "Tap to enter your XIUM space",
                size: 16,
                color: Colors.white,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
