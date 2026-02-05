import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: const [
          OnboardPage(
            title: "What is Decision Debt?",
            description:
                "Decision Debt is the cost of poor or delayed decisions.\n\nExample:\nChoosing a quick fix today that causes bigger problems tomorrow.",
          ),
          OnboardPage(
            title: "Why track decisions?",
            description:
                "• Business impact\n• Missed deadlines\n• Rework cost\n\nUntracked decisions silently slow teams down.",
          ),
          OnboardPage(
            title: "How TrackFlow helps",
            description:
                "• Track decisions\n• Review outcomes\n• Learn patterns\n\nMake smarter decisions over time.",
            isLast: true,
          ),
        ],
      ),
    );
  }
}
class OnboardPage extends StatelessWidget {
  final String title;
  final String description;
  final bool isLast;

  const OnboardPage({
    super.key,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F2040),
            Color(0xFF081226),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          if (isLast)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ya Home/Login page
              },
              child: const Text("Get Started"),
            ),
        ],
      ),
    );
  }
}
