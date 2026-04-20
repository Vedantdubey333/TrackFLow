import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/decision_model.dart';

class PastDecisionScreen extends StatefulWidget {
  final Decision decision;

  const PastDecisionScreen({super.key, required this.decision});

  @override
  State<PastDecisionScreen> createState() => _PastDecisionScreenState();
}

class _PastDecisionScreenState extends State<PastDecisionScreen> {
  late String currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.decision.status;
  }

  Future<void> _updateStatus(String? newStatus) async {
    if (newStatus == null || newStatus == currentStatus) return;

    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance
          .collection('decisions')
          .doc(widget.decision.id)
          .update({'status': newStatus});
          
      setState(() => currentStatus = newStatus);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status updated successfully")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteDecision() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Decision?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('decisions').doc(widget.decision.id).delete();
        if (mounted) Navigator.pop(context); 
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Decision Details"), backgroundColor: Colors.blue,
        actions: [IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: _deleteDecision, tooltip: "Delete Decision")],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentStatus,
                  isExpanded: true,
                  icon: _isUpdating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_drop_down),
                  items: ['Active', 'Mitigated', 'Resolved'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text("Status: $value", style: const TextStyle(fontWeight: FontWeight.bold)));
                  }).toList(),
                  onChanged: _isUpdating ? null : _updateStatus,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.decision.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(widget.decision.category), backgroundColor: Colors.blue.shade100),
                Text(DateFormat('MMM dd, yyyy').format(widget.decision.createdAt), style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            if (widget.decision.reviewDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Colors.orange), const SizedBox(width: 4),
                  Text("Review due: ${DateFormat('MMM dd, yyyy').format(widget.decision.reviewDate!)}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.decision.dangerScore > 7 ? Colors.red.shade50 : (widget.decision.dangerScore > 4 ? Colors.orange.shade50 : Colors.green.shade50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.decision.dangerScore > 7 ? Colors.red : (widget.decision.dangerScore > 4 ? Colors.orange : Colors.green))
              ),
              child: Column(
                children: [
                  const Text("Danger Score", style: TextStyle(fontSize: 16)), const SizedBox(height: 8),
                  Text("${widget.decision.dangerScore}/10", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: widget.decision.dangerScore > 70 ? Colors.red : (widget.decision.dangerScore > 40 ? Colors.orange : Colors.green))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("AI Risk Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.decision.aiConcerns.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text("• $c", style: const TextStyle(fontSize: 16, height: 1.5)))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}