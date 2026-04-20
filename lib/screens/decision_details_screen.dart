import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/decision_model.dart';
import '../services/notification_service.dart';

class DecisionDetailsScreen extends StatefulWidget {
  const DecisionDetailsScreen({super.key});

  @override
  State<DecisionDetailsScreen> createState() => _DecisionDetailsScreenState();
}

class _DecisionDetailsScreenState extends State<DecisionDetailsScreen> {
  String selectedCategory = "Tech";
  bool affectsUserData = false;
  bool _isLoading = false;
  DateTime? selectedReviewDate; 

  final TextEditingController titleController = TextEditingController();
  final TextEditingController timePressureController = TextEditingController();
  final TextEditingController stakeholdersController = TextEditingController();
  final TextEditingController expectationController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    timePressureController.dispose();
    stakeholdersController.dispose();
    expectationController.dispose();
    super.dispose();
  }

  Future<void> _selectReviewDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedReviewDate) {
      setState(() {
        selectedReviewDate = picked;
      });
    }
  }

  Future<void> _analyzeDecision() async {
    final String title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a title")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are a risk analysis assistant. Analyze the project decision and return ONLY a valid JSON object. Required Format: {\"dangerScore\": int, \"concerns\": [string]}"
            },
            {
              "role": "user",
              "content": "Title: $title\nCategory: $selectedCategory\nTime Pressure: ${timePressureController.text}\nExpectations: ${expectationController.text}\nImpacts User Data: $affectsUserData"
            }
          ],
          "response_format": {"type": "json_object"},
          "temperature": 0.2
        }),
      );

      int extractedScore = 50;
      List<String> extractedConcerns = ["Manual review needed"];

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final String aiResponseText = decodedBody['choices'][0]['message']['content'];
        final Map<String, dynamic> aiData = jsonDecode(aiResponseText);

        extractedScore = aiData['dangerScore'] ?? 50;
        extractedConcerns = List<String>.from(aiData['concerns'] ?? []);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final decisionRef = FirebaseFirestore.instance.collection('decisions').doc();
          
          final newDecision = Decision(
            id: decisionRef.id,
            title: title,
            category: selectedCategory,
            dangerScore: extractedScore,
            aiConcerns: extractedConcerns, 
            createdAt: DateTime.now(), 
            userId: user.uid,
            status: 'Active',
            reviewDate: selectedReviewDate, 
          );

          await decisionRef.set(newDecision.toMap());

          // SCHEDULE NOTIFICATION
          if (selectedReviewDate != null) {
            final scheduleTime = DateTime(
              selectedReviewDate!.year, selectedReviewDate!.month, selectedReviewDate!.day, 9, 0, 0,
            );
            if (scheduleTime.isAfter(DateTime.now())) {
              await NotificationService.scheduleNotification(
                id: decisionRef.id.hashCode,
                title: 'Decision Review',
                body: 'Time to review your decision: "$title"',
                scheduledDate: scheduleTime,
              );
            }
          }
        }
      } else {
        throw Exception("Failed to analyze decision.");
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text("Analysis Result & Saved"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Danger Score: $extractedScore"),
                const SizedBox(height: 10),
                const Text("Concerns:"),
                const SizedBox(height: 5),
                ...extractedConcerns.map((c) => Text("• $c")),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); 
                  titleController.clear();
                  timePressureController.clear();
                  expectationController.clear();
                  stakeholdersController.clear();
                  setState(() {
                    selectedCategory = "Tech";
                    affectsUserData = false;
                    selectedReviewDate = null; 
                  });
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error processing decision.")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text("Add New Decision"), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInput("Title", titleController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: ["Tech", "Product", "HR", "Personal"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                  decoration: _inputDecoration("Category"),
                ),
                const SizedBox(height: 16),
                _buildInput("Time Pressure", timePressureController),
                const SizedBox(height: 16),
                _buildInput("Expectations", expectationController, maxLines: 3),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Impacts User Data?"),
                  value: affectsUserData,
                  onChanged: (val) => setState(() => affectsUserData = val),
                ),
                const SizedBox(height: 16),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade400)),
                  title: Text(
                    selectedReviewDate == null ? "Set Review Date (Optional)" : "Review Date: ${DateFormat('MMM dd, yyyy').format(selectedReviewDate!)}",
                    style: TextStyle(color: selectedReviewDate == null ? Colors.grey.shade700 : Colors.black),
                  ),
                  trailing: const Icon(Icons.calendar_month, color: Colors.blue),
                  onTap: () => _selectReviewDate(context),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeDecision,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Analyze & Save Decision", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines, decoration: _inputDecoration(label));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label, filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
    );
  }
}