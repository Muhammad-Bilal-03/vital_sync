import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class UserProvider extends ChangeNotifier {
  final BaseAuthRepository _authRepo; // Injected Dependency

  UserProvider(this._authRepo);

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authRepo.login(email, password);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String gender,
    required DateTime dob,
    required String password,
    required String bloodType,
    required String weight,
    required String height,
  }) async {
    _setLoading(true);
    try {
      _user = await _authRepo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        gender: gender,
        dob: dob,
        bloodType: bloodType,
        weight: weight,
        height: height,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    return false;
  }

  void logout() {
    _authRepo.logout();
    _user = null;
    notifyListeners();
  }

  void updateProfileImage(String path) {
    if (_user != null) {
      _user = _user!.copyWith(profileImagePath: path);
      notifyListeners();
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
