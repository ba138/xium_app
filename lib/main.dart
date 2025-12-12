import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/screens/starting/cube_screen.dart';
import 'package:xium_app/views/screens/welcome/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
