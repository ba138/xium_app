import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/generated/assets.dart';
import 'package:xium_app/views/screens/home/add_loyalty_card_screen.dart';
import 'package:xium_app/views/screens/home/store_detail_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddLoyaltyCardScreen());
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: AppColors.onPrimary),
                      MyText(text: "Back", size: 16),
                    ],
                  ),
                  CommonImageView(imagePath: Assets.setting, height: 24),
                ],
              ),

              const SizedBox(height: 20),

              MyText(text: "Your Stores", size: 20, weight: FontWeight.bold),
              MyText(
                text: "Select a store to view all your related documents.",
              ),

              const SizedBox(height: 20),

              MyTextField(
                hint: "Search a store",
                radius: 12,
                prefix: Icon(Icons.search),
              ),

              const SizedBox(height: 20),

              // ⭐ ADDING THE GRIDVIEW HERE ⭐
              Expanded(
                child: GridView.builder(
                  itemCount: 15, // total cards
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 in a row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8, // adjust card height
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => StoreDetailScreen());
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.grayColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CommonImageView(
                              imagePath: Assets.walmart,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            MyText(text: "Walmart"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
