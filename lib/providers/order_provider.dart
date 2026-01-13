import 'package:flutter/material.dart';
import 'dart:async';
import '../core/result.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepo;

  List<OrderModel> _orders = [];
  StreamSubscription? _orderSubscription;
  bool _isLoading = false; // Still useful for UI loading spinners

  // New: Result state for one-off actions
  Result<void>? _orderStatus;

  OrderProvider(this._orderRepo);

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  Result<void>? get orderStatus => _orderStatus;

  void initOrders(String uid) {
    _isLoading = true;
    notifyListeners();

    _orderSubscription?.cancel();
    _orderSubscription = _orderRepo.getUserOrders(uid).listen((orderList) {
      _orders = orderList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print("Error fetching orders: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Returns Result so UI can handle specific errors/success
  Future<Result<void>> placeOrder({
    required String userId,
    required List<String> testIds, // Changed to IDs for security
    required DateTime date,
    required String timeSlot,
  }) async {
    _isLoading = true;
    _orderStatus = null;
    notifyListeners();

    final result = await _orderRepo.placeOrder(
      userId: userId,
      testIds: testIds,
      date: date,
      timeSlot: timeSlot,
    );

    _isLoading = false;
    _orderStatus = result;
    notifyListeners();

    return result;
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
