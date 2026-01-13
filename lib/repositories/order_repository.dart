import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/result.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Security Fix: Calculate total server-side (simulated)
  Future<Result<void>> placeOrder({
    required String userId,
    required List<String> testIds, // We only accept IDs, not prices
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      // 1. Availability Check
      final isAvailable = await checkSlotAvailability(date, timeSlot);
      if (!isAvailable) {
        return const Failure(
            "Time slot already booked. Please choose another.");
      }

      // 2. Security: Fetch fresh prices from DB to prevent tampering
      double calculatedTotal = 0.0;
      List<String> testNames = [];

      // Note: In a real backend (Cloud Functions), this would happen atomically.
      // Here we fetch eagerly.
      if (testIds.isEmpty) return const Failure("No tests selected.");

      // Fetch all tests securely
      // (Splitting into chunks of 10 for 'whereIn' limits if necessary, simplified here)
      final snapshot = await _db
          .collection('tests')
          .where(FieldPath.documentId, whereIn: testIds)
          .get();

      if (snapshot.docs.length != testIds.length) {
        return const Failure(
            "One or more selected tests are no longer available.");
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        double price = (data['price'] ?? 0).toDouble();
        double? discount = data['discountedPrice']?.toDouble();
        calculatedTotal += (discount ?? price);
        testNames.add(data['name'] ?? 'Unknown Test');
      }

      // 3. Write Order
      await _db.collection('orders').add({
        'userId': userId,
        'testName': testNames.join(", "),
        'itemIds': testIds,
        'date': Timestamp.fromDate(date),
        'status': 'Scheduled',
        'totalAmount': calculatedTotal, // Trusted calculation
        'timeSlot': timeSlot,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<bool> checkSlotAvailability(DateTime date, String timeSlot) async {
    // Normalize date to midnight for comparison
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('orders')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('timeSlot', isEqualTo: timeSlot)
        .where('status',
            whereNotIn: ['Cancelled', 'Completed']) // Ignore cancelled/done
        .get();

    // If any doc exists, the slot is taken
    return snapshot.docs.isEmpty;
  }
}
