import 'package:flutter/material.dart';
import 'dart:async';
import '../repositories/notification_repository.dart';

class NotificationModel {
  final String title;
  final String body;
  final DateTime time;

  NotificationModel(
      {required this.title, required this.body, required this.time});
}

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo; // Injected Dependency

  NotificationProvider(this._repo);

  List<NotificationModel> _notifications = [];
  StreamSubscription? _subscription;

  List<NotificationModel> get notifications => _notifications;

  void initNotifications(String uid) {
    _subscription?.cancel();
    _subscription = _repo.getUserNotifications(uid).listen((data) {
      _notifications = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
