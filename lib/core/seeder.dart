import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedTests() async {
    final collection = _db.collection('tests');

    // Check if we already have Packages seeded
    final packageSnapshot =
        await collection.where('category', isEqualTo: 'Package').limit(1).get();

    if (packageSnapshot.docs.isNotEmpty) {
      print("Packages already seeded.");
      return;
    }

    print("Seeding missing packages...");

    final List<Map<String, dynamic>> newPackages = [
      {
        'name': 'Full Body Checkup (50% OFF)',
        'category': 'Package',
        'price': 10000,
        'discountedPrice': 5000,
        'tatHours': 48,
        'description':
            'Includes CBC, LFT, Lipid Profile, Kidney Function, and more.'
      },
      {
        'name': 'Heart Health Bundle',
        'category': 'Package',
        'price': 5000,
        'discountedPrice': 3500,
        'tatHours': 24,
        'description': 'Complete cardiac risk assessment profile.'
      },
      {
        'name': 'Family Care (Buy 2 Get 1 Free)',
        'category': 'Package',
        'price': 4500,
        'discountedPrice': 3000,
        'tatHours': 24,
        'description': 'Screening for 3 family members at the price of 2.'
      },
    ];

    for (var pack in newPackages) {
      await collection.add(pack);
    }

    print("Packages seeded successfully!");
  }
}
