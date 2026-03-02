import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/constants/app_translators.dart';
import 'package:xium_app/views/screens/welcome/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init(); // ✅ IMPORTANT

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? lang = box.read('lang');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(),

      locale: lang == 'fr'
          ? const Locale('fr', 'FR')
          : const Locale('en', 'US'),

      fallbackLocale: const Locale('en', 'US'),

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: const SplashScreen(),
    );
  }
}
