// ==========================================
// FILE: lib/providers/transaction_provider.dart
// Updated transaction state management with real backend
// ==========================================
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  
  // Filters
  String? _selectedType;
  String? _selectedStatus;
  String? _searchQuery;
  DateTime? _startDate;
  DateTime? _endDate;

  // Summary data
  Map<String, dynamic>? _summary;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String? get selectedType => _selectedType;
  String? get selectedStatus => _selectedStatus;
  String? get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  Map<String, dynamic>? get summary => _summary;

  // Fetch transactions with filters
  Future<void> fetchTransactions({
    bool refresh = false,
    TransactionType? type,
    TransactionStatus? status,
    String? search,
    DateTime? start,
    DateTime? end,
  }) async {
    if (refresh) {
      _transactions = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _transactionService.getTransactions(
      page: _currentPage,
      type: type?.name ?? _selectedType,
      status: status?.name ?? _selectedStatus,
      search: search ?? _searchQuery,
      startDate: (start ?? _startDate)?.toIso8601String(),
      endDate: (end ?? _endDate)?.toIso8601String(),
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      if (response.data!.isEmpty) {
        _hasMore = false;
      } else {
        _transactions.addAll(response.data!);
        _currentPage++;
      }
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to fetch transactions';
    }
    
    notifyListeners();
  }

  // Get single transaction
  Future<TransactionModel?> getTransaction(String transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _transactionService.getTransaction(transactionId);

    _isLoading = false;

    if (response.success && response.data != null) {
      _errorMessage = null;
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Failed to fetch transaction';
      notifyListeners();
      return null;
    }
  }

  // Fetch transaction summary
  Future<void> fetchSummary({
    String? period,
    DateTime? start,
    DateTime? end,
  }) async {
    final response = await _transactionService.getTransactionSummary(
      period: period,
      startDate: start?.toIso8601String(),
      endDate: end?.toIso8601String(),
    );

    if (response.success && response.data != null) {
      _summary = response.data;
      notifyListeners();
    }
  }

  // Get transaction receipt URL
  Future<String?> getReceiptUrl(String transactionId) async {
    final response = await _transactionService.getTransactionReceipt(transactionId);

    if (response.success && response.data != null) {
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Failed to get receipt';
      notifyListeners();
      return null;
    }
  }

  // Check transaction status
  Future<Map<String, dynamic>?> checkTransactionStatus(String transactionId) async {
    final response = await _transactionService.checkTransactionStatus(transactionId);

    if (response.success && response.data != null) {
      // Update transaction in list if exists
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1 && response.data!.containsKey('status')) {
        // Update the transaction status
        _transactions[index] = TransactionModel.fromJson({
          ..._transactions[index].toJson(),
          'status': response.data!['status'],
        });
        notifyListeners();
      }
      return response.data;
    }
    return null;
  }

  // Set filters
  void setTypeFilter(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Apply filters and refresh
  Future<void> applyFilters() async {
    await fetchTransactions(refresh: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedType = null;
    _selectedStatus = null;
    _searchQuery = null;
    _startDate = null;
    _endDate = null;
    await fetchTransactions(refresh: true);
  }

  // Get transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Get transactions by status
  List<TransactionModel> getTransactionsByStatus(TransactionStatus status) {
    return _transactions.where((t) => t.status == status).toList();
  }

  // Get pending transactions
  List<TransactionModel> get pendingTransactions {
    return _transactions.where((t) => t.isPending).toList();
  }

  // Get completed transactions
  List<TransactionModel> get completedTransactions {
    return _transactions.where((t) => t.isCompleted).toList();
  }

  // Get failed transactions
  List<TransactionModel> get failedTransactions {
    return _transactions.where((t) => t.isFailed).toList();
  }

  // Calculate total amount by type
  double getTotalAmount(TransactionType type) {
    return _transactions
        .where((t) => t.type == type && t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calculate total income
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.topup && t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calculate total expenses
  double get totalExpenses {
    return _transactions
        .where((t) => 
            t.type != TransactionType.topup && 
            t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  // Get transactions for today
  List<TransactionModel> get todayTransactions {
    final today = DateTime.now();
    return _transactions.where((t) {
      final txDate = t.createdAt;
      return txDate.year == today.year &&
          txDate.month == today.month &&
          txDate.day == today.day;
    }).toList();
  }

  // Get transactions for this week
  List<TransactionModel> get weekTransactions {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _transactions
        .where((t) => t.createdAt.isAfter(weekAgo))
        .toList();
  }

  // Get transactions for this month
  List<TransactionModel> get monthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) {
      return t.createdAt.year == now.year &&
          t.createdAt.month == now.month;
    }).toList();
  }

  // Group transactions by date
  Map<String, List<TransactionModel>> get groupedByDate {
    final grouped = <String, List<TransactionModel>>{};
    
    for (var transaction in _transactions) {
      final dateKey = _getDateKey(transaction.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return '${now.difference(date).inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _transactions = [];
    _isLoading = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _selectedType = null;
    _selectedStatus = null;
    _searchQuery = null;
    _startDate = null;
    _endDate = null;
    _summary = null;
    notifyListeners();
  }

  // Add transaction to list (useful after creating new transaction)
  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  // Update transaction in list
  void updateTransaction(TransactionModel transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }
  }

  // Remove transaction from list
  void removeTransaction(String transactionId) {
    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }
}