import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String testName;
  final DateTime date;
  final String status;
  final double totalAmount;
  final String timeSlot; // <--- ADD THIS

  OrderModel({
    required this.id,
    required this.userId,
    required this.testName,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.timeSlot, // <--- ADD THIS
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      testName: map['testName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? 'Pending',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      timeSlot: map['timeSlot'] ?? '09:00 AM', // <--- READ THIS
    );
  }
}
