import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobile,
    required String gender,
    required DateTime dob,
    required String bloodType,
    required String weight,
    required String height,
  });
  Future<void> logout();
}

class AuthRepository implements BaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return await _getUserProfile(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
    return null;
  }

  @override
  Future<UserModel?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobile,
    required String gender,
    required DateTime dob,
    required String bloodType,
    required String weight,
    required String height,
  }) async {
    try {
      // 1. Create Auth User
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final uid = credential.user!.uid;

      // 2. Create Model
      final newUser = UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        gender: gender,
        dob: dob,
        email: email,
        bloodType: bloodType,
        weight: weight,
        height: height,
      );

      // 3. Save to Firestore
      await _db.collection('users').doc(uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Registration failed";
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel> _getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    } else {
      throw "User profile not found.";
    }
  }
}
