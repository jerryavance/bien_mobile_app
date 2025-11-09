// ==========================================
// FILE: lib/providers/wallet_provider.dart
// Wallet state management
// ==========================================
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();

  WalletModel? _wallet;
  bool _isLoading = false;
  String? _errorMessage;

  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get balance => _wallet?.balance ?? 0;

  // Fetch wallet balance
  Future<void> fetchWallet() async {
    _isLoading = true;
    notifyListeners();

    final response = await _walletService.getWallet();

    _isLoading = false;
    if (response.success && response.data != null) {
      _wallet = response.data;
      _errorMessage = null;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  // Top-up wallet
  Future<TransactionModel?> topUp({
    required String source,
    required String phoneNumber,
    required double amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _walletService.topUp(
      source: source,
      phoneNumber: phoneNumber,
      amount: amount,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      await fetchWallet(); // Refresh balance
      _errorMessage = null;
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  // Cash out
  Future<TransactionModel?> cashOut({
    required String method,
    required String destination,
    required double amount,
    Map<String, dynamic>? additionalData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _walletService.cashOut(
      method: method,
      destination: destination,
      amount: amount,
      additionalData: additionalData,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      await fetchWallet(); // Refresh balance
      _errorMessage = null;
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  // Bien to Bien transfer
  Future<TransactionModel?> transfer({
    required String recipientId,
    required double amount,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _walletService.transfer(
      recipientId: recipientId,
      amount: amount,
      note: note,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      await fetchWallet(); // Refresh balance
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