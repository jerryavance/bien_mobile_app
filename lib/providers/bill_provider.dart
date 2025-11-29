// ==========================================
// FILE: lib/providers/bill_provider.dart
// Bill payment state management
// ==========================================
import 'package:flutter/material.dart';
import '../models/bill_models.dart';
import '../services/bill_service.dart';

class BillProvider with ChangeNotifier {
  final BillService _billService = BillService();

  // Bill categories and billers
  List<BillCategory> _categories = [];
  bool _isLoadingBillers = false;
  String? _errorMessage;

  // Validation and payment state
  bool _isProcessingPayment = false;
  String? _paymentStatus;
  BillValidationResponse? _validationData;
  BillPaymentResponse? _lastPayment;

  // Getters
  List<BillCategory> get categories => _categories;
  bool get isLoadingBillers => _isLoadingBillers;
  String? get errorMessage => _errorMessage;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentStatus => _paymentStatus;
  BillValidationResponse? get validationData => _validationData;
  BillPaymentResponse? get lastPayment => _lastPayment;

  // ==========================================
  // FETCH BILL CATEGORIES AND BILLERS
  // ==========================================

  Future<void> fetchBillers() async {
    _isLoadingBillers = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _billService.listBillers();

    _isLoadingBillers = false;

    if (response.success && response.data != null) {
      _categories = response.data!;
      _errorMessage = null;
      print('✅ Loaded ${_categories.length} bill categories');
    } else {
      _errorMessage = response.message ?? 'Failed to load billers';
      print('❌ Error loading billers: $_errorMessage');
    }

    notifyListeners();
  }

  // ==========================================
  // VALIDATE BILL PAYMENT (Step 1)
  // ==========================================

  Future<BillValidationResponse?> validateBillPayment({
    required String billerId,
    required String itemId,
    required String customerId,
    required double amount,
    required String phoneNumber,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Validating bill payment...';
    _validationData = null;
    notifyListeners();

    final response = await _billService.validateBill(
      billerId: billerId,
      itemId: itemId,
      customerId: customerId,
      amount: amount,
      phoneNumber: phoneNumber,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _validationData = response.data!;
      _errorMessage = null;
      _paymentStatus = 'Validation successful';
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Validation failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // COMPLETE BILL PAYMENT (Step 2)
  // ==========================================

  Future<BillPaymentResponse?> completeBillPayment({
    required String retrievalReference,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing bill payment...';
    notifyListeners();

    final response = await _billService.payBill(
      retrievalReference: retrievalReference,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastPayment = response.data!;
      _errorMessage = null;
      _paymentStatus = 'Bill payment successful';
      _validationData = null; // Clear validation data
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Payment failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // CHECK PAYMENT STATUS
  // ==========================================

  Future<Map<String, dynamic>?> checkPaymentStatus(String transactionId) async {
    try {
      final response = await _billService.checkPaymentStatus(
        transactionId: transactionId,
      );

      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('BillProvider.checkPaymentStatus error: $e');
      return null;
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Get category by ID
  BillCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get biller by ID across all categories
  Biller? getBillerById(String billerId) {
    for (var category in _categories) {
      try {
        return category.billers.firstWhere((b) => b.billId == billerId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _paymentStatus = null;
    notifyListeners();
  }

  /// Clear validation data
  void clearValidationData() {
    _validationData = null;
    notifyListeners();
  }

  /// Clear last payment
  void clearLastPayment() {
    _lastPayment = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _categories = [];
    _isLoadingBillers = false;
    _errorMessage = null;
    _isProcessingPayment = false;
    _paymentStatus = null;
    _validationData = null;
    _lastPayment = null;
    notifyListeners();
  }
}