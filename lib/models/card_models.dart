// ==========================================
// FILE: lib/models/card_models.dart
// Verve card models for Interswitch integration
// ==========================================

class CardModel {
  final String id;
  final String userId;
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final String cvv;
  final String cardType; // 'verve'
  final double balance;
  final String currency;
  final CardStatus status;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  CardModel({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cvv,
    this.cardType = 'verve',
    required this.balance,
    this.currency = 'UGX',
    this.status = CardStatus.active,
    this.isDefault = false,
    required this.createdAt,
    this.lastUsedAt,
  });

  // Masked card number for display
  String get maskedCardNumber {
    if (cardNumber.length < 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(12)}';
  }

  // Last 4 digits
  String get last4Digits {
    if (cardNumber.length < 4) return cardNumber;
    return cardNumber.substring(cardNumber.length - 4);
  }

  bool get isActive => status == CardStatus.active;
  bool get isFrozen => status == CardStatus.frozen;
  bool get isBlocked => status == CardStatus.blocked;

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? json['card_id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      cardNumber: json['card_number'] ?? json['cardNumber'] ?? '',
      cardholderName: json['cardholder_name'] ?? json['cardholderName'] ?? '',
      expiryDate: json['expiry_date'] ?? json['expiryDate'] ?? '',
      cvv: json['cvv'] ?? '',
      cardType: json['card_type'] ?? json['cardType'] ?? 'verve',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UGX',
      status: _parseStatus(json['status']),
      isDefault: json['is_default'] ?? json['isDefault'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastUsedAt: json['last_used_at'] != null || json['lastUsedAt'] != null
          ? DateTime.parse(json['last_used_at'] ?? json['lastUsedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_number': cardNumber,
      'cardholder_name': cardholderName,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'card_type': cardType,
      'balance': balance,
      'currency': currency,
      'status': status.name,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'last_used_at': lastUsedAt?.toIso8601String(),
    };
  }

  static CardStatus _parseStatus(dynamic status) {
    if (status == null) return CardStatus.active;
    final statusStr = status.toString().toLowerCase();
    
    switch (statusStr) {
      case 'active':
        return CardStatus.active;
      case 'frozen':
        return CardStatus.frozen;
      case 'blocked':
        return CardStatus.blocked;
      case 'expired':
        return CardStatus.expired;
      default:
        return CardStatus.active;
    }
  }

  CardModel copyWith({
    String? id,
    String? userId,
    String? cardNumber,
    String? cardholderName,
    String? expiryDate,
    String? cvv,
    String? cardType,
    double? balance,
    String? currency,
    CardStatus? status,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return CardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardNumber: cardNumber ?? this.cardNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}

enum CardStatus {
  active,
  frozen,
  blocked,
  expired,
}

// Card transaction model
class CardTransaction {
  final String id;
  final String cardId;
  final String type; // 'top-up', 'transfer', 'purchase'
  final double amount;
  final String currency;
  final String description;
  final DateTime timestamp;
  final String status;

  CardTransaction({
    required this.id,
    required this.cardId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    return CardTransaction(
      id: json['id'] ?? '',
      cardId: json['card_id'] ?? json['cardId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UGX',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'completed',
    );
  }
}