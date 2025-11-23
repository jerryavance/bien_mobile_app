// ==========================================
// FILE: lib/services/transaction_service.dart
// Real backend API integration for transactions
// ==========================================
import '../models/transaction_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'storage_service.dart';

class TransactionService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  // ==========================================
  // GET TRANSACTIONS
  // ==========================================

  /// Get transaction history for current user's account
  Future<ApiResponse<List<TransactionModel>>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      // Get user's account ID
      final accountId = await _storage.getAccountId();
      if (accountId == null || accountId.isEmpty) {
        return ApiResponse.error(message: 'Account ID not found');
      }

      print('Fetching transactions for account: $accountId');

      final response = await _api.get<Map<String, dynamic>>(
        '/transaction/list/$accountId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] as List?;
        
        if (data == null || data.isEmpty) {
          return ApiResponse.success(data: []);
        }

        // Map API transactions to TransactionModel
        final transactions = data.map((txData) {
          return _mapToTransactionModel(txData as Map<String, dynamic>);
        }).toList();

        // Apply filters if provided
        var filteredTransactions = transactions;

        if (type != null) {
          filteredTransactions = filteredTransactions.where((tx) {
            return tx.type.name.toLowerCase() == type.toLowerCase();
          }).toList();
        }

        if (status != null) {
          filteredTransactions = filteredTransactions.where((tx) {
            return tx.status.name.toLowerCase() == status.toLowerCase();
          }).toList();
        }

        if (search != null && search.isNotEmpty) {
          filteredTransactions = filteredTransactions.where((tx) {
            final searchLower = search.toLowerCase();
            return tx.description?.toLowerCase().contains(searchLower) ?? false;
          }).toList();
        }

        // Sort by date (newest first)
        filteredTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Implement pagination
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;
        
        if (startIndex >= filteredTransactions.length) {
          return ApiResponse.success(data: []);
        }

        final paginatedTransactions = filteredTransactions.sublist(
          startIndex,
          endIndex > filteredTransactions.length 
              ? filteredTransactions.length 
              : endIndex,
        );

        return ApiResponse.success(data: paginatedTransactions);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch transactions',
      );
    } catch (e) {
      print('TransactionService.getTransactions error: $e');
      return ApiResponse.error(message: 'Error fetching transactions: $e');
    }
  }

  /// Get single transaction details
  Future<ApiResponse<TransactionModel>> getTransaction(
    String transactionId,
  ) async {
    try {
      // Get account ID first
      final accountId = await _storage.getAccountId();
      if (accountId == null) {
        return ApiResponse.error(message: 'Account ID not found');
      }

      // Fetch all transactions and find the specific one
      final response = await getTransactions();
      
      if (response.success && response.data != null) {
        final transaction = response.data!.firstWhere(
          (tx) => tx.id == transactionId,
          orElse: () => throw Exception('Transaction not found'),
        );
        
        return ApiResponse.success(data: transaction);
      }

      return ApiResponse.error(
        message: response.message ?? 'Transaction not found',
      );
    } catch (e) {
      print('TransactionService.getTransaction error: $e');
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  // ==========================================
  // TRANSACTION SUMMARY
  // ==========================================

  /// Get transaction summary/statistics
  Future<ApiResponse<Map<String, dynamic>>> getTransactionSummary({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Fetch all transactions
      final response = await getTransactions();
      
      if (!response.success || response.data == null) {
        return ApiResponse.error(message: 'Failed to fetch transactions');
      }

      final transactions = response.data!;
      
      // Calculate summary
      double totalIncome = 0;
      double totalExpense = 0;
      int completedCount = 0;
      int pendingCount = 0;
      int failedCount = 0;

      for (var tx in transactions) {
        if (tx.type == TransactionType.topup) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }

        switch (tx.status) {
          case TransactionStatus.completed:
            completedCount++;
            break;
          case TransactionStatus.pending:
            pendingCount++;
            break;
          case TransactionStatus.failed:
            failedCount++;
            break;
          case TransactionStatus.cancelled:
            break;
        }
      }

      final summary = {
        'total_income': totalIncome,
        'total_expense': totalExpense,
        'net_amount': totalIncome - totalExpense,
        'total_transactions': transactions.length,
        'completed': completedCount,
        'pending': pendingCount,
        'failed': failedCount,
      };

      return ApiResponse.success(data: summary);
    } catch (e) {
      return ApiResponse.error(message: 'Error calculating summary: $e');
    }
  }

  // ==========================================
  // TRANSACTION RECEIPT
  // ==========================================

  /// Get transaction receipt URL (placeholder)
  Future<ApiResponse<String>> getTransactionReceipt(
    String transactionId,
  ) async {
    try {
      // TODO: Implement when receipt API is available
      return ApiResponse.error(message: 'Receipt download not yet available');
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  // ==========================================
  // CHECK STATUS
  // ==========================================

  /// Check transaction status
  Future<ApiResponse<Map<String, dynamic>>> checkTransactionStatus(
    String transactionId,
  ) async {
    try {
      final response = await getTransaction(transactionId);
      
      if (response.success && response.data != null) {
        return ApiResponse.success(data: {
          'status': response.data!.status.name,
          'transaction': response.data!.toJson(),
        });
      }

      return ApiResponse.error(message: 'Transaction not found');
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Map API transaction data to TransactionModel
  TransactionModel _mapToTransactionModel(Map<String, dynamic> data) {
    // Determine transaction type
    final transactionType = data['transaction_type'] as String?;
    TransactionType type = TransactionType.transfer;
    
    if (transactionType != null) {
      switch (transactionType.toLowerCase()) {
        case 'deposit':
          type = TransactionType.topup;
          break;
        case 'withdraw':
          type = TransactionType.cashout;
          break;
        case 'transfer':
          type = TransactionType.transfer;
          break;
        default:
          type = TransactionType.transfer;
      }
    }

    // Determine transaction status
    final paymentStatus = data['payment_status'] as String?;
    TransactionStatus status = TransactionStatus.pending;
    
    if (paymentStatus != null) {
      switch (paymentStatus.toLowerCase()) {
        case 'completed':
          status = TransactionStatus.completed;
          break;
        case 'pending':
          status = TransactionStatus.pending;
          break;
        case 'failed':
          status = TransactionStatus.failed;
          break;
        default:
          status = TransactionStatus.pending;
      }
    }

    // Extract charges
    final charges = data['charges'] as Map<String, dynamic>?;
    double fee = 0;
    if (charges != null) {
      final charge = charges['charge'] ?? 0;
      final tax = charges['tax'] ?? 0;
      fee = (charge + tax).toDouble();
    }

    // Build description
    final recipientName = data['recipient_name'] ?? 'Unknown';
    final amount = data['amount'] ?? '0';
    final description = '${type.name.toUpperCase()} - $recipientName';

    return TransactionModel(
      id: data['id'] ?? data['tranID'] ?? '',
      userId: data['source_account_id'] ?? '',
      type: type,
      status: status,
      amount: double.parse(amount.toString()),
      fee: fee,
      currency: data['currency'] ?? 'UGX',
      reference: data['tranID'] ?? data['gatewayID'],
      description: data['note'] ?? description,
      metadata: data,
      createdAt: DateTime.parse(
        data['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt: data['payment_date'] != null 
          ? DateTime.parse(data['payment_date'])
          : null,
    );
  }
}