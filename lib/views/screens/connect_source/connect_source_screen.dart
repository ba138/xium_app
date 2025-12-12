import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class ConnectSourceScreen extends StatefulWidget {
  const ConnectSourceScreen({super.key});

  @override
  State<ConnectSourceScreen> createState() => _ConnectSourceScreenState();
}

class _ConnectSourceScreenState extends State<ConnectSourceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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

                  MyText(text: "Back", size: 16),

                  const Spacer(),

                  /// ✅ Glassy dotted border container placed here
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
