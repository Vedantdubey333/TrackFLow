import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  int _normalizeScore(int rawScore) {
    return rawScore > 10 ? (rawScore / 10).round() : rawScore;
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 STRICT USER AUTHENTICATION CHECK
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black,
        title: const Text("30-Day Intelligence", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: currentUserId == null 
        ? const Center(child: Text("Authentication required"))
        : StreamBuilder<QuerySnapshot>(
        // 🔒 STRICT USER FILTER + 30 DAY WINDOW FOR BETTER INSIGHTS
        stream: FirebaseFirestore.instance
            .collection('decisions')
            .where('userId', isEqualTo: currentUserId) 
            .where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 30)))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState();

          final docs = snapshot.data!.docs;
          
          // --- CALCULATE DEEP INSIGHTS ---
          Map<String, List<int>> categoryScores = {};
          int resolvedIn30Days = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            String cat = data['category'] ?? 'Other';
            int score = _normalizeScore(data['dangerScore'] ?? 0);
            
            if (!categoryScores.containsKey(cat)) categoryScores[cat] = [];
            categoryScores[cat]!.add(score);

            if (data['status'] == 'Resolved') resolvedIn30Days++;
          }

          // Calculate average risk per category for the Heatmap
          Map<String, double> categoryAverages = {};
          String highestRiskCategory = "None";
          double highestRiskAverage = 0;

          categoryScores.forEach((cat, scores) {
            double avg = scores.reduce((a, b) => a + b) / scores.length;
            categoryAverages[cat] = avg;
            if (avg > highestRiskAverage) {
              highestRiskAverage = avg;
              highestRiskCategory = cat;
            }
          });

          // Generate dynamic insight text
          String aiInsightText = "";
          if (highestRiskAverage >= 7) {
            aiInsightText = "Your $highestRiskCategory decisions carry critical risk (${highestRiskAverage.toStringAsFixed(1)}/10). We recommend halting new $highestRiskCategory decisions until active debt is mitigated.";
          } else if (highestRiskAverage >= 5) {
            aiInsightText = "$highestRiskCategory is your most volatile sector right now. Proceed with caution.";
          } else {
            aiInsightText = "Your risk distribution is remarkably stable across all categories. Excellent management.";
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader("Category Risk Heatmap"),
              const Text("Average danger score generated per category.", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
              
              // 🌟 PRIMARY INSIGHT: Category Risk Heatmap
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: categoryAverages.entries.map((e) => _buildHeatmapRow(e.key, e.value)).toList(),
                ),
              ),

              const SizedBox(height: 24),
              _buildHeader("System Analysis"),
              const SizedBox(height: 12),

              // 🌟 DYNAMIC TEXT INSIGHT
              _buildInsightCard(
                icon: Icons.psychology, 
                color: Colors.indigo,
                title: "Algorithmic Recommendation",
                subtitle: aiInsightText,
              ),
              const SizedBox(height: 12),
              
              // 🌟 VELOCITY INSIGHT
              _buildInsightCard(
                icon: Icons.speed, 
                color: resolvedIn30Days > (docs.length / 3) ? Colors.green : Colors.orange,
                title: "Resolution Velocity",
                subtitle: "You resolved $resolvedIn30Days issues this month while creating ${docs.length}. " + 
                          (resolvedIn30Days > (docs.length / 3) ? "You are keeping up with your debt." : "Debt is accumulating faster than you are resolving it."),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Not enough data to generate intelligence.", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5));
  }

  Widget _buildHeatmapRow(String cat, double avgScore) {
    Color barColor = avgScore >= 7 ? Colors.red : (avgScore >= 4 ? Colors.orange : Colors.green);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          Expanded(
            child: Stack(
              children: [
                Container(height: 16, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10))),
                FractionallySizedBox(
                  widthFactor: avgScore / 10, // Scale out of 10
                  child: Container(
                    height: 16, 
                    decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(10))
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(avgScore.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: barColor, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInsightCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}