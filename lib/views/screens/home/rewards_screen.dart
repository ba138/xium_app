import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
              const Text(
                "Rewards",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Track your points, missions & benefits",
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              _glassContainer(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Total XIUM Points",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "12,400",
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
                      child: const Text(
                        "Intermediate",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: Colors.white24,
                      color: AppColors.buttonColor,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "760 more points to reach the next level",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                  ],
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
              const Text(
                "Missions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              _missionTile(progress: 1, title: "Scan a document"),
              const SizedBox(height: 12),
              _missionTile(progress: 0, title: "Import a doc from email"),
              const SizedBox(height: 12),
              _missionTile(progress: 0, title: "Import a doc from bank"),
              const SizedBox(height: 28),

              /// User Status
              const Text(
                "User Status",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              _glassContainer(
                height: MediaQuery.of(context).size.height * 0.36,
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
                              "CURRENT LEVEL",
                              style: TextStyle(color: Colors.white54),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Beginner",
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
                      "Your level evolves based on your activity within the application.",
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
                          text: "Early access to new features",
                          weight: FontWeight.w500,
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
                            Icons.star_half_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: "Early access to new features",
                          weight: FontWeight.w500,
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
                            Icons.star_half_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MyText(
                          text: "Early access to new features",
                          weight: FontWeight.w500,
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
            padding: const EdgeInsets.all(18),
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
            child: Center(
              child: Icon(Icons.scanner_outlined, color: Colors.white),
            ),
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
                      ),
                    ),
                    const Text(
                      "+100 pts",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
