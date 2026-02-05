import 'package:flutter/material.dart';
import 'decision_details_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // 🔹 Bottom Nav current index
  int _currentIndex = 0;

  // 🔹 Backend se aane wali values (abhi dummy)
  final int totalDecisions = 124;
  final int pendingDecisions = 15;
  final int highRiskDecisions = 8;
  final int decisionDebtScore = 45; // 0–100

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "TrackFlow Dashboard",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      // 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= TOP CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [

                  Text(
                    "$totalDecisions",
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const Text(
                    "Total Decisions Taken",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _smallStat(
                        icon: Icons.access_time,
                        color: Colors.orange,
                        value: pendingDecisions,
                        label: "Pending",
                      ),
                      _smallStat(
                        icon: Icons.warning,
                        color: Colors.red,
                        value: highRiskDecisions,
                        label: "High-risk",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= DECISION DEBT SCORE =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  const Text(
                    "Decision Debt Score",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: CircularProgressIndicator(
                          value: decisionDebtScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey,
                          color: _scoreColor(decisionDebtScore),
                        ),
                      ),
                      Text(
                        "$decisionDebtScore",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    decisionDebtScore < 40
                        ? "Low"
                        : decisionDebtScore < 70
                            ? "Moderate"
                            : "High",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(decisionDebtScore),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _actionButton(
              text: "Add New Decision",
              icon: Icons.add,
              color: Colors.blue,
              onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DecisionDetailsScreen(),
                        ),
                      );
              },
            ),
            _actionButton(
              text: "View Analytics",
              icon: Icons.bar_chart,
              color: Colors.green,
              onTap: () {},
            ),
            _actionButton(
              text: "Review Reminders",
              icon: Icons.alarm,
              color: Colors.orange,
              onTap: () {},
            ),
          ],
        ),
      ),

      // 🔹 ✅ BOTTOM NAVIGATION BAR (ADDED HERE)
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ================= SMALL STAT =================
  Widget _smallStat({
    required IconData icon,
    required Color color,
    required int value,
    required String label,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$value",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= ACTION BUTTON =================
  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV BAR =================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black12,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          _navItem(Icons.home, "Home", 0),
          _navItem(Icons.assignment, "Decisions", 1),
          _navItem(Icons.bar_chart, "Analytics", 2),
          _navItem(Icons.person, "Profile", 3),
        ],
      ),
    );
  }

  // ================= NAV ITEM WITH GLOW =================
  BottomNavigationBarItem _navItem(
      IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        size: 26,
        color: isActive ? Colors.blue : Colors.grey,
        shadows: isActive
            ? [
                Shadow(
                  blurRadius: 12,
                  color: Colors.blue.withOpacity(0.6),
                )
              ]
            : [],
      ),
      label: label,
    );
  }

  // ================= SCORE COLOR =================
  Color _scoreColor(int score) {
    if (score < 40) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }
}
