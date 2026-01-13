import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_model.dart';

class TestRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<TestModel>> getPopularTests() async {
    try {
      final snapshot = await _db.collection('tests').get();

      // If Firestore is empty, return an empty list (or handle seeding later)
      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TestModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown Test',
          category: data['category'] ?? 'General',
          price: (data['price'] ?? 0).toDouble(),
          discountedPrice: data['discountedPrice']?.toDouble(),
          tatHours: data['tatHours'] ?? 24,
        );
      }).toList();
    } catch (e) {
      print("Error fetching tests: $e");
      return [];
    }
  }
}
