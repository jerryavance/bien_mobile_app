// ==========================================
// STEP 2: Update UserModel with Complete Fields
// FILE: lib/models/user_model.dart
// ==========================================
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String? bio;
  final bool emailVerified;
  final bool phoneVerified;
  final bool twoFactorEnabled;
  final String accountStatus; // 'active', 'suspended', 'pending'
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.bio,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.twoFactorEnabled = false,
    this.accountStatus = 'active',
    required this.createdAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['userId'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      profilePicture: json['profilePicture'] ?? json['profile_picture'],
      bio: json['bio'],
      emailVerified: json['emailVerified'] ?? json['email_verified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? json['phone_verified'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? json['two_factor_enabled'] ?? false,
      accountStatus: json['accountStatus'] ?? json['account_status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Null get profileImage => null;

  Null get initials => null;

  Null get isPhoneVerified => null;

  Null get isEmailVerified => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'bio': bio,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'accountStatus': accountStatus,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}