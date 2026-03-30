import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/home_controller.dart';
import 'package:xium_app/controller/plaid_controller.dart';
import 'package:xium_app/views/screens/home/store_detail_screen.dart';
import 'package:xium_app/views/widgets/common_image_view.dart';
import 'package:xium_app/views/widgets/my_text.dart';
import 'package:xium_app/views/widgets/my_text_field.dart';
import 'package:shimmer/shimmer.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final controller = Get.put(HomeController());
  final tinkController = Get.put(TinkController());
  String truncate(String text, int max) {
    if (text.length <= max) return text;
    return text.substring(0, max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // This will close the keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: "Your Stores".tr,
                  size: 20,
                  weight: FontWeight.bold,
                ),
                MyText(
                  text: "Select a store to view all your related documents.".tr,
                ),

                const SizedBox(height: 20),

                MyTextField(
                  hint: "Search a store".tr,
                  radius: 12,
                  prefix: const Icon(Icons.search),
                  onChanged: (value) {
                    controller.searchStores(value); // 🔥 CALL FUNCTION
                  },
                ),

                const SizedBox(height: 20),

                // ⭐ ADDING THE GRIDVIEW HERE ⭐
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return storeGridShimmer();
                    }

                    if (controller.filteredStores.isEmpty) {
                      return Center(child: MyText(text: "No stores found".tr));
                    }

                    return GridView.builder(
                      itemCount: controller.filteredStores.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemBuilder: (context, index) {
                        final store = controller.filteredStores[index];

                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => StoreDetailScreen(
                                storeName: store.storeName,
                                storeLogo: store.storeLogo,
                                documentCount: store.documentCount,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
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
                                store.storeLogo != null &&
                                        store.storeLogo!.isNotEmpty
                                    ? CommonImageView(
                                        url: store.storeLogo!,
                                        height: 40,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        Icons.store,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),

                                const SizedBox(height: 8),
                                MyText(text: truncate(store.storeName, 9)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget storeGridShimmer() {
    return GridView.builder(
      itemCount: 12, // fake items
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Color(0xFF2A2A2A), // dark card
          highlightColor: Color(0xFF3A3A3A), // soft light pass

          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 12, width: 60, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
