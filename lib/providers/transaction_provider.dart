// ==========================================
// FILE: lib/providers/transaction_provider.dart
// Transaction state management
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

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Fetch transactions
  Future<void> fetchTransactions({
    bool refresh = false,
    TransactionType? type,
    TransactionStatus? status,
  }) async {
    if (refresh) {
      _transactions = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final response = await _transactionService.getTransactions(
      page: _currentPage,
      type: type,
      status: status,
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
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  // Buy airtime
  Future<TransactionModel?> buyAirtime({
    required String network,
    required String phoneNumber,
    required double amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _transactionService.buyAirtime(
      network: network,
      phoneNumber: phoneNumber,
      amount: amount,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _transactions.insert(0, response.data!);
      _errorMessage = null;
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  // Buy data bundle
  Future<TransactionModel?> buyDataBundle({
    required String network,
    required String phoneNumber,
    required String bundleId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _transactionService.buyDataBundle(
      network: network,
      phoneNumber: phoneNumber,
      bundleId: bundleId,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _transactions.insert(0, response.data!);
      _errorMessage = null;
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  // Pay utility
  Future<TransactionModel?> payUtility({
    required String provider,
    required String accountNumber,
    required double amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _transactionService.payUtility(
      provider: provider,
      accountNumber: accountNumber,
      amount: amount,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _transactions.insert(0, response.data!);
      _errorMessage = null;
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}