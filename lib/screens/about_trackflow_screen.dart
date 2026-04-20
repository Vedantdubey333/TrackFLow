import 'package:flutter/material.dart';

class AboutTrackFlowScreen extends StatelessWidget {
  const AboutTrackFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("About TrackFlow"), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset("assets/images/logo.png", height: 100)),
            const SizedBox(height: 24),
            const Text("TrackFlow", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Text("Intelligent Decision Debt Tracker", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 24),
            _section("The Concept", "Every quick decision made under pressure creates 'Decision Debt'—a hidden risk that can crash a project later. TrackFlow uses AI to quantify that risk and ensure you pay off your technical and product debt before it's too late."),
            _section("Key Features", "• AI-Powered Risk Analysis (via Groq API)\n• Dynamic Debt Dashboard\n• Category Risk Heatmaps\n• Scheduled Review Reminders"),
            _section("Tech Stack", "Built with Flutter, Firebase Firestore for real-time data persistence, and Llama 3 (Groq) for advanced risk assessment logic."),
            const SizedBox(height: 40),
            const Center(child: Text("v1.0.0 - Project Submission", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5)),
        ],
      ),
    );
  }
}