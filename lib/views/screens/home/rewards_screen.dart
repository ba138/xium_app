import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050B2C), Color(0xFF0A1A4F), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
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

                /// Total Points Card
                _glassCard(
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
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.white24,
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "760 more points to reach the next level",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5C8DFF), Color(0xFF3A66FF)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "View my benefits",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// Quick Actions
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _smallStat("Documents\nAdded", "247")),
                    const SizedBox(width: 12),
                    Expanded(child: _smallStat("Connected\nSources", "4")),
                    const SizedBox(width: 12),
                    Expanded(child: _smallStat("Invited\nFriends", "5")),
                  ],
                ),

                const SizedBox(height: 28),

                /// Missions
                const Text(
                  "Missions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _missionTile(progress: 1, completed: true),
                const SizedBox(height: 12),
                _missionTile(progress: 0.5),
                const SizedBox(height: 12),
                _missionTile(progress: 0.8),
                const SizedBox(height: 28),

                /// Referral
                const Text(
                  "Referral",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Invite Your Contacts And Earn Additional Points",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: const Text(
                          "XIUM-7K2F9X",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.people, color: Colors.white54),
                          SizedBox(width: 6),
                          Text(
                            "5 referrals",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.stars, color: Colors.white54),
                          SizedBox(width: 6),
                          Text(
                            "100 pts earned",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// User Status
                const Text(
                  "User Status",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                      SizedBox(height: 12),
                      Text(
                        "Your level evolves based on your activity within the application.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white.withOpacity(0.08),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, color: Colors.white54),
            Icon(Icons.description, color: Colors.white54),
            Icon(Icons.add_circle_outline, color: Colors.white54),
            Icon(Icons.card_giftcard, color: Colors.white),
            Icon(Icons.person, color: Colors.white54),
          ],
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

  Widget _missionTile({required double progress, bool completed = false}) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Invite a friend",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: completed ? Colors.green : Colors.blue,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
