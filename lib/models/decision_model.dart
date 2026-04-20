import 'package:cloud_firestore/cloud_firestore.dart';

class Decision {
  final String id;
  final String title;
  final String category;
  final int dangerScore;
  final List<String> aiConcerns;
  final DateTime createdAt;
  final String userId;
  final String status; 
  final DateTime? reviewDate;

  Decision({
    required this.id,
    required this.title,
    required this.category,
    required this.dangerScore,
    required this.aiConcerns,
    required this.createdAt,
    required this.userId,
    this.status = 'Active', 
    this.reviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'dangerScore': dangerScore,
      'aiConcerns': aiConcerns,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'status': status,
      'reviewDate': reviewDate != null ? Timestamp.fromDate(reviewDate!) : null,
    };
  }

  factory Decision.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    
    // Safety check for the timestamp to prevent the Null Type Error
    DateTime parsedDate;
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else {
      // Fallback to current time if the field is missing or null in the DB
      parsedDate = DateTime.now();
    }

    return Decision(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'General',
      dangerScore: data['dangerScore'] ?? 0,
      aiConcerns: List<String>.from(data['aiConcerns'] ?? []),
      createdAt: parsedDate, // Use the safely parsed date
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'Active',
      reviewDate: data['reviewDate'] != null && data['reviewDate'] is Timestamp
          ? (data['reviewDate'] as Timestamp).toDate() 
          : null,
    );
  }
}