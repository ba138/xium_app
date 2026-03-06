import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/controller/reward_controller.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  var controller = Get.put(RewardController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rewards".tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Track your points, missions & benefits".tr,
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              Obx(
                () => _glassContainer(
                  height: MediaQuery.of(context).size.height * 0.275,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Total XIUM Points".tr,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        controller.userPoints.value.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue.withOpacity(0.2),
                        ),
                        child: Text(
                          controller.userLevelName.value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 16),

                      LinearProgressIndicator(
                        value: controller.levelProgress.value,
                        backgroundColor: Colors.white24,
                        color: AppColors.buttonColor,
                        minHeight: 6,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        controller.pointsToNextLevel.value == 0
                            ? "max_level_reached".tr
                            : "more_points_next_level".trParams({
                                "points": controller.pointsToNextLevel.value
                                    .toString(),
                              }),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              /// Total Points Card
              const SizedBox(height: 28),

              // /// Quick Actions
              // const Text(
              //   "Quick Actions",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // Row(
              //   children: [
              //     Expanded(child: _smallStat("Documents\nAdded", "247")),
              //     const SizedBox(width: 12),
              //     Expanded(child: _smallStat("Connected\nSources", "4")),
              //     const SizedBox(width: 12),
              //     Expanded(child: _smallStat("Invited\nFriends", "5")),
              //   ],
              // ),

              // const SizedBox(height: 28),

              /// Missions
              Text(
                "missions".tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              Obx(
                () => _missionTile(
                  progress: controller.scanProgress.value,
                  title: "Scan a document".tr,
                  icon: Icons.scanner_outlined,
                ),
              ),

              const SizedBox(height: 12),

              Obx(
                () => _missionTile(
                  progress: controller.emailProgress.value,
                  title: "Import a doc from email".tr,
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 12),

              Obx(
                () => _missionTile(
                  progress: controller.bankProgress.value,
                  title: "Import a doc from bank".tr,
                  icon: Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(height: 28),

              /// User Status
              Text(
                "User Status".tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              _glassContainer(
                height: MediaQuery.of(context).size.height * 0.38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
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
                          child: Icon(
                            Icons.star_border_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CURRENT LEVEL".tr,
                              style: TextStyle(color: Colors.white54),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Beginner".tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                    Text(
                      "Your level evolves based on your activity within the application."
                          .tr,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Possible Benefits",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.blue.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.star_half_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: "Point bonuses on each activity".tr,
                          weight: FontWeight.w500,
                          size: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.blue.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.watch_later_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: "Early access to certain features".tr,
                          weight: FontWeight.w500,
                          size: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.blue.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: "Priority status during new updates".tr,
                          weight: FontWeight.w500,
                          size: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
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

  Widget _smallStat(String title, String value) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionTile({
    required double progress,
    bool completed = false,
    required String title,
    required IconData icon,
  }) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  Colors.blue.shade900.withValues(alpha: 0.9),
                ],
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
              ),
            ),
            child: Center(child: Icon(icon, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      "+100 pts",
                      style: TextStyle(
                        color: AppColors.buttonColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  color: completed ? Colors.green : Colors.blue,
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
