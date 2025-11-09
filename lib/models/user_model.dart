// User data structure

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final double walletBalance;
  final int kycLevel;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    required this.walletBalance,
    required this.kycLevel,
    required this.isVerified,
    required this.createdAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      profileImage: json['profile_image'] ?? json['profileImage'],
      walletBalance: (json['wallet_balance'] ?? json['walletBalance'] ?? 0).toDouble(),
      kycLevel: json['kyc_level'] ?? json['kycLevel'] ?? 1,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'wallet_balance': walletBalance,
      'kyc_level': kycLevel,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImage,
    double? walletBalance,
    int? kycLevel,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      walletBalance: walletBalance ?? this.walletBalance,
      kycLevel: kycLevel ?? this.kycLevel,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}