enum TransactionType { topup, cashout, transfer, airtime, data, utility, school, merchant }
enum TransactionStatus { pending, completed, failed, cancelled }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double fee;
  final String currency;
  final String? reference;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.fee = 0,
    this.currency = 'UGX',
    this.reference,
    this.description,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  double get totalAmount => amount + fee;
  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;

  String get typeLabel {
    switch (type) {
      case TransactionType.topup: return 'Top Up';
      case TransactionType.cashout: return 'Cash Out';
      case TransactionType.transfer: return 'Transfer';
      case TransactionType.airtime: return 'Airtime';
      case TransactionType.data: return 'Data Bundle';
      case TransactionType.utility: return 'Utility Payment';
      case TransactionType.school: return 'School Fees';
      case TransactionType.merchant: return 'Merchant Payment';
    }
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? json['transaction_id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      type: _parseTransactionType(json['type'] ?? json['transaction_type']),
      status: _parseTransactionStatus(json['status']),
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'UGX',
      reference: json['reference'],
      description: json['description'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Null get recipientName => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'fee': fee,
      'currency': currency,
      'reference': reference,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  static TransactionType _parseTransactionType(dynamic type) {
    if (type == null) return TransactionType.transfer;
    if (type is TransactionType) return type;
    return TransactionType.values.firstWhere(
      (e) => e.name == type.toString().toLowerCase(),
      orElse: () => TransactionType.transfer,
    );
  }

  static TransactionStatus _parseTransactionStatus(dynamic status) {
    if (status == null) return TransactionStatus.pending;
    if (status is TransactionStatus) return status;
    return TransactionStatus.values.firstWhere(
      (e) => e.name == status.toString().toLowerCase(),
      orElse: () => TransactionStatus.pending,
    );
  }
}