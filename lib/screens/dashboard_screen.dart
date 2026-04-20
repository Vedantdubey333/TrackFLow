import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'decision_details_screen.dart';
import 'analytics_screen.dart';
import 'past_decision_screen.dart';
import '../models/decision_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Normalizes old out-of-100 scores to out-of-10 safely
  int _normalizeScore(int rawScore) {
    return rawScore > 10 ? (rawScore / 10).round() : rawScore;
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 STRICT USER AUTHENTICATION CHECK
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text("Authentication required")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(currentUserId),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              // 🔒 STRICT USER FILTER
              stream: FirebaseFirestore.instance
                  .collection('decisions')
                  .where('userId', isEqualTo: currentUserId) 
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20), 
                    child: Text("Database Error: ${snapshot.error}\n(You may need to click the index link in your debug console)", style: const TextStyle(color: Colors.red))
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.only(top: 50), child: Center(child: CircularProgressIndicator()));
                }

                final docs = snapshot.data?.docs ?? [];
                
                // --- ADVANCED METRICS CALCULATION ---
                int totalActiveDebt = 0; 
                int activeCriticalCount = 0;
                int resolvedCount = 0;
                double avgAppetite = 0;

                if (docs.isNotEmpty) {
                  int totalScore = 0;
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    int score = _normalizeScore(data['dangerScore'] ?? 0);
                    String status = data['status'] ?? 'Active';
                    
                    totalScore += score;
                    
                    if (status == 'Active') {
                      totalActiveDebt += score; // Sum of unresolved risk
                      if (score >= 7) activeCriticalCount++;
                    } else if (status == 'Resolved' || status == 'Mitigated') {
                      resolvedCount++;
                    }
                  }
                  avgAppetite = totalScore / docs.length;
                }

                double resolutionRate = docs.isEmpty ? 0 : (resolvedCount / docs.length) * 100;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌟 PRIMARY INSIGHT: Active Accumulated Debt
                      _buildAccumulatedDebtCard(totalActiveDebt, activeCriticalCount),
                      const SizedBox(height: 16),

                      // Secondary Metrics Grid
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard("Resolution Rate", "${resolutionRate.toStringAsFixed(1)}%", Icons.task_alt, Colors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMetricCard("Avg Risk Appetite", "${avgAppetite.toStringAsFixed(1)}/10", Icons.speed, Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Quick Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton("Log Decision", Icons.add, Colors.blue.shade700, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DecisionDetailsScreen()))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionButton("Deep Analytics", Icons.insights, Colors.indigo.shade600, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen()))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      const Text("Active Risk Backlog", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      
                      if (docs.isEmpty) 
                         const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("Your backlog is clean.", style: TextStyle(color: Colors.grey)))),

                      // Show ONLY Active decisions in the backlog
                      ...docs.where((doc) => (doc.data() as Map)['status'] == 'Active').take(5).map((doc) {
                        final decision = Decision.fromFirestore(doc);
                        final int score = _normalizeScore(decision.dangerScore);
                        return _buildListTile(context, decision, score);
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String uid) {
    return SliverAppBar(
      expandedHeight: 110.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue.shade900,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snapshot) {
            String name = "Leader";
            if (snapshot.hasData && snapshot.data!.exists) {
              name = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Leader';
              name = name.split(' ')[0]; 
            }
            return Text("Welcome, $name", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22));
          },
        ),
      ),
    );
  }

  Widget _buildAccumulatedDebtCard(int totalActiveDebt, int criticalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: totalActiveDebt > 30 ? [Colors.red.shade700, Colors.red.shade500] : [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (totalActiveDebt > 30 ? Colors.red : Colors.blue).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Active Decision Debt", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$totalActiveDebt", style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, height: 1.0)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text("points", style: TextStyle(color: Colors.white70, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: criticalCount > 0 ? Colors.orangeAccent : Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  criticalCount > 0 ? "$criticalCount critical issues require immediate attention" : "No critical issues active. Good job.",
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Decision decision, int score) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PastDecisionScreen(decision: decision))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: score >= 7 ? Colors.red.shade50 : (score >= 4 ? Colors.orange.shade50 : Colors.green.shade50), shape: BoxShape.circle),
              child: Text("$score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: score >= 7 ? Colors.red : (score >= 4 ? Colors.orange : Colors.green))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(decision.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(decision.category, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400)
          ],
        ),
      ),
    );
  }
}