import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/dashboard_controller.dart';
import 'package:xium_app/controller/user_controller.dart';
import 'package:xium_app/model/document_model.dart';
import 'package:xium_app/views/screens/connect_source/add_loyalty_card_info_screen.dart';
import 'package:xium_app/views/screens/connect_source/connect_email_screen.dart';
import 'package:xium_app/views/screens/connect_source/connect_phone_screen.dart';
import 'package:xium_app/views/screens/home/doc_view_screen.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var dashboardController = Get.put(DashboardController());
  var userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.buttonColor,
                      radius: 24,
                      backgroundImage: NetworkImage(
                        userController.user.value?.profilePictureUrl ??
                            "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: "Welcome back".tr,
                          size: 16,
                          weight: FontWeight.bold,
                          color: Colors.white,
                        ),

                        MyText(
                          text:
                              userController.user.value?.username ?? "John Doe",
                          size: 16,
                          weight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Obx(
                () => _overviewSection(
                  dashboardController.totalDocs.value.toString(),
                  dashboardController.totalWarranties.value.toString(),
                  dashboardController.totalSubscriptions.value.toString(),
                  dashboardController.monthlyTotalPrice.value.toStringAsFixed(
                    2,
                  ),
                  dashboardController.totalAmountAllDocs.value.toString(),
                ),
              ),

              const SizedBox(height: 24),
              _quickActions(),
              const SizedBox(height: 24),
              _recentActivity(),
              const SizedBox(height: 24),
              _insights(dashboardController),
              const SizedBox(height: 24),
              _levelCard(dashboardController),
              const SizedBox(height: 24),
              _comingSoon(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    double radius = 24,
    double height = 200,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade800.withOpacity(0.6),
            Colors.blue.shade900.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _overviewSection(
    String totlDocs,
    String totalWarranties,
    String totalSubscriptions,
    String monthlyTotalPrice,
    String totalAmountAllDocs,
  ) {
    return _glassContainer(
      height: MediaQuery.of(context).size.height * 0.48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview".tr,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "€${(double.tryParse(totalAmountAllDocs) ?? 0).toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2, // 👈 increase this to reduce height

            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                title: "Documents".tr,
                value: totlDocs,
                subtitle: "+12 this month".tr,
                icon: Icons.description_outlined,
              ),
              _StatCard(
                title: "Monthly Spending".tr,
                value: "€$monthlyTotalPrice",
                subtitle: "vs last".tr,
                icon: Icons.bar_chart_outlined,
              ),
              _StatCard(
                title: "Active Warranties".tr,
                value: totalWarranties,
                subtitle: "expiring soon".tr,
                icon: Icons.verified_user_outlined,
              ),
              _StatCard(
                title: "Subscriptions".tr,
                value: totalSubscriptions,
                subtitle: "mo total",
                icon: Icons.payment_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final items = [
      Icons.mail_outline,
      Icons.account_balance_outlined,
      Icons.phone_iphone,
      Icons.credit_card_outlined,
    ];

    final labels = ["Email".tr, "Bank".tr, "Phone".tr, "Loyalty".tr];
    final tap = {
      0: () => Get.to(() => ConnectEmailScreen()),
      1: () {
        // Get.to(() => ConnectBankCard());
        Get.snackbar(
          "Coming Soon".tr,
          "Bank connection feature will be available soon.".tr,
          snackPosition: SnackPosition.TOP,
          colorText: Colors.white,
        );
      },
      2: () => Get.to(() => ConnectPhoneScreen()),
      3: () => Get.to(() => AddLoyaltyInfoScreen()),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions".tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    tap[index]?.call();
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.buttonColor,
                          Colors.blue.shade900.withValues(alpha: 0.9),
                        ],
                        begin: AlignmentGeometry.topCenter,
                        end: AlignmentGeometry.bottomCenter,
                      ),
                    ),
                    child: Icon(items[index], color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _recentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyText(
              text: "Recent Activity".tr,
              size: 18,
              weight: FontWeight.bold,
              color: Colors.white,
            ),
            const Spacer(),
            // MyText(text: "See All".tr, size: 14, color: Colors.blueAccent),
          ],
        ),
        const SizedBox(height: 12),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: dashboardController.getTopNewestDocs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                "No Activity",
                style: TextStyle(color: Colors.white),
              );
            }

            /// 🔹 Convert Firestore docs → Model
            List<DocumentModel> docs = snapshot.data!.docs
                .map((doc) => DocumentModel.fromFirestore(doc))
                .toList();

            return Column(
              children: List.generate(docs.length, (index) {
                DocumentModel data = docs[index];

                return InkWell(
                  onTap: () {
                    Get.to(
                      () => DocViewScreen(
                        document: data,
                        storeLogo: data.storeLogo,
                        storeName: data.storeName,
                        documentCount:
                            dashboardController.topDocTypeCount.value,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xff6C7278).withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.buttonColor.withOpacity(0.3),
                          ),
                          child: buildStoreLogo(data),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            "${data.storeName ?? "Unknown"}\n${data.documentType ?? ""}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        Text(
                          "${data.currency ?? ""}${data.amount ?? 0}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget buildStoreLogo(DocumentModel data) {
    if (data.storeLogo != null && data.storeLogo!.isNotEmpty) {
      return Image.network(
        data.storeLogo!,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return const Icon(Icons.home, color: Colors.white);
        },
      );
    } else {
      return const Icon(Icons.home, color: Colors.white);
    }
  }

  Widget _insights(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: "Insights".tr,
          size: 18,
          color: Colors.white,
          weight: FontWeight.bold,
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 120,
          child: Obx(
            () => ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                _InsightCard(
                  icon: Icons.sell_outlined,
                  title: "Top Category".tr,
                  value: controller.topDocType.value.isEmpty
                      ? "-".tr
                      : controller.topDocType.value,
                  subtitle: controller.topDocTypeCount.value > 0
                      ? "${controller.topDocTypeCount.value} ${"documents".tr}"
                      : "-".tr,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  icon: Icons.store_rounded,
                  title: "Top Merchant".tr,
                  value: controller.topStoreName.value.isEmpty
                      ? "-".tr
                      : controller.topStoreName.value.length > 12
                      ? "${controller.topStoreName.value.substring(0, 12)}..."
                      : controller.topStoreName.value,
                  subtitle: controller.topStoreCount.value > 0
                      ? "${controller.topStoreCount.value} ${"transactions".tr}"
                      : "-".tr,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  icon: Icons.payment_outlined,
                  title: "Largest Expense".tr,
                  value:
                      "€${controller.topSpendingAmount.value.toStringAsFixed(2)}",
                  subtitle: controller.topSpendingDoc.value.isEmpty
                      ? "-"
                      : controller.topSpendingDoc.value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _levelCard(DashboardController controller) {
    return _glassContainer(
      height: 110,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.buttonColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "XIUM Level".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${controller.userLevel.value}",
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Points".tr,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${controller.userPoints.value}",
                      style: TextStyle(
                        color: AppColors.buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: controller.levelProgress.value,
              backgroundColor: Colors.white24,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _comingSoon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blueGrey.shade900.withOpacity(0.7),
      ),
      child: Row(
        children: [
          Icon(Icons.rocket_launch, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "xium_evolving".tr,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.buttonColor,
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              MyText(
                text: title,
                size: 10,
                weight: FontWeight.w500,
                color: AppColors.onPrimary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Color(0xff6C7278).withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.buttonColor),
          Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              top: 8.0,
              bottom: 8,
            ),
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.buttonColor.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Flutter widget example
}
