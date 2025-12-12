import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/connect_source/sync_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class RedirectingScreen extends StatefulWidget {
  const RedirectingScreen({super.key});

  @override
  State<RedirectingScreen> createState() => _RedirectingScreenState();
}

class _RedirectingScreenState extends State<RedirectingScreen> {
  void timer() {
    Future.delayed(Duration(seconds: 4), () {
      Get.to(() => SyncScreen());
    });
  }

  @override
  void initState() {
    timer();
    super.initState();
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
              Align(
                alignment: Alignment.bottomLeft,
                child: MyText(text: "Connecting"),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              CommonImageView(imagePath: Assets.shiled, height: 80),
              MyText(
                text: "Redirecting to secure\n banking portal…",
                size: 20,
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  CommonImageView(imagePath: Assets.tink, height: 30),
                  CommonImageView(imagePath: Assets.bridge, height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
