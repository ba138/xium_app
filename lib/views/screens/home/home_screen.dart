import 'package:flutter/material.dart';
import 'package:xium_app/constants/app_colors.dart';
import 'package:xium_app/views/widgets/my_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.amber, radius: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      MyText(
                        text: "Welcome back, Bas!",
                        size: 16,
                        weight: FontWeight.bold,
                        color: Colors.white,
                      ),

                      MyText(
                        text: "Here's your financial snapshot",
                        size: 12,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _overviewSection(context),

              const SizedBox(height: 24),
              _quickActions(),
              const SizedBox(height: 24),
              _recentActivity(),
              const SizedBox(height: 24),
              _insights(),
              const SizedBox(height: 24),
              _levelCard(),
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

  Widget _overviewSection(BuildContext context) {
    return _glassContainer(
      height: MediaQuery.of(context).size.height * 0.48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overview",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text(
                "€14,832",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text("+3.2%", style: TextStyle(color: Colors.blueAccent)),
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
            children: const [
              _StatCard(
                title: "Documents",
                value: "247",
                subtitle: "+12 this month",
                icon: Icons.description_outlined,
              ),
              _StatCard(
                title: "Monthly Spending",
                value: "€1,248",
                subtitle: "-5.1% vs last",
                icon: Icons.bar_chart_outlined,
              ),
              _StatCard(
                title: "Active Warranties",
                value: "18",
                subtitle: "3 expiring soon",
                icon: Icons.verified_user_outlined,
              ),
              _StatCard(
                title: "Subscriptions",
                value: "190",
                subtitle: "€186/mo total",
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
      Icons.qr_code_scanner,
      Icons.upload,
      Icons.mail,
      Icons.account_balance,
      Icons.phone_iphone,
    ];

    final labels = ["Scan", "Import", "Email", "Bank", "Phone"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
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
                  child: Icon(items[index], color: Colors.white),
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
            const Text(
              "Recent Activity",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            MyText(text: "See All", size: 12, color: Colors.blueAccent),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Color(0xff6C7278).withOpacity(0.3),
              ),
              child: Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.buttonColor.withValues(alpha: 0.3),
                    ),
                    child: Icon(Icons.home, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Rent Payment\nHousing",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    "€950.00",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _insights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Insights",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: _InsightCard(
                icon: Icons.sell_outlined,
                title: "Top Category",
                value: "Shopping",
                subtitle: "34% of expenses",
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InsightCard(
                icon: Icons.store_rounded,

                title: "Top Merchant",
                value: "Amazon",
                subtitle: "23 transactions",
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InsightCard(
                icon: Icons.payment_outlined,

                title: "Largest Expense",
                value: "€950",
                subtitle: "Rent - Feb 20",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _levelCard() {
    return _glassContainer(
      height: 110,
      child: Column(
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
                    child: Center(child: Icon(Icons.star, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "XIUM Level",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "7",
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
                    "Points",
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "200",
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

          SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.78,
            backgroundColor: Colors.white24,
            color: Colors.blue,
          ),
          SizedBox(height: 8),
        ],
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
        children: const [
          Icon(Icons.rocket_launch, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "XIUM is evolving\nAI-powered categorization & smart alerts coming soon",
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
      padding: const EdgeInsets.all(14),
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
            padding: const EdgeInsets.all(8.0),
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
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
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
}
