class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String mobile;
  final String gender;
  final DateTime? dob;
  final String? email;
  final String bloodType;
  final String? profileImagePath;
  final String? weight; // New
  final String? height; // New

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.gender = 'Male',
    this.dob,
    this.email,
    this.bloodType = 'O+',
    this.profileImagePath,
    this.weight,
    this.height,
  });

  String get fullName => "$firstName $lastName";

  String get age {
    if (dob == null) return "--";
    final now = DateTime.now();
    int age = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      age--;
    }
    return age.toString();
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      mobile: map['mobile'] ?? '',
      gender: map['gender'] ?? 'Male',
      email: map['email'],
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      bloodType: map['bloodType'] ?? 'O+',
      profileImagePath: map['profileImagePath'],
      weight: map['weight'],
      height: map['height'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'gender': gender,
      'email': email,
      'dob': dob?.toIso8601String(),
      'bloodType': bloodType,
      'profileImagePath': profileImagePath,
      'weight': weight,
      'height': height,
    };
  }

  // Helper to create a copy with updated fields
  UserModel copyWith({String? profileImagePath}) {
    return UserModel(
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
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
