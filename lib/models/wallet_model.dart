class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double pendingBalance;
  final String currency;
  final bool isActive;
  final DateTime lastUpdated;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    this.pendingBalance = 0,
    this.currency = 'UGX',
    this.isActive = true,
    required this.lastUpdated,
  });

  double get availableBalance => balance - pendingBalance;

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? json['wallet_id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      pendingBalance: (json['pending_balance'] ?? json['pendingBalance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UGX',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastUpdated: DateTime.parse(json['last_updated'] ?? json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'pending_balance': pendingBalance,
      'currency': currency,
      'is_active': isActive,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}