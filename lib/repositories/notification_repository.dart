import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/notification_provider.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getUserNotifications(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // FIX: Safely handle null timestamp
        DateTime notifTime;
        if (data['time'] != null) {
          notifTime = (data['time'] as Timestamp).toDate();
        } else {
          notifTime = DateTime.now(); // Fallback if missing
        }

        return NotificationModel(
          title: data['title'] ?? 'No Title',
          body: data['body'] ?? '',
          time: notifTime,
        );
      }).toList();
    });
  }

  Future<void> createNotification(String uid, String title, String body) async {
    await _db.collection('users').doc(uid).collection('notifications').add({
      'title': title,
      'body': body,
      'time': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
