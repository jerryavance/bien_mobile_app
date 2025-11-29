// ==========================================
// FILE: lib/providers/wallet_provider.dart
// UPDATED: Separate validation and completion methods
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
  TransactionModel? _lastTransaction;
  
  // Processing states
  bool _isProcessingPayment = false;
  String? _paymentStatus;
  
  // Validation data
  Map<String, dynamic>? _validationData;
  
  // Available payment methods
  List<Map<String, dynamic>> _topUpMethods = [];
  List<Map<String, dynamic>> _cashOutMethods = [];

  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get balance => _wallet?.balance ?? 0;
  double get availableBalance => _wallet?.availableBalance ?? 0;
  TransactionModel? get lastTransaction => _lastTransaction;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentStatus => _paymentStatus;
  Map<String, dynamic>? get validationData => _validationData;
  List<Map<String, dynamic>> get topUpMethods => _topUpMethods;
  List<Map<String, dynamic>> get cashOutMethods => _cashOutMethods;

  // ==========================================
  // WALLET OPERATIONS
  // ==========================================

  Future<void> fetchWallet() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _walletService.getWallet();

    _isLoading = false;

    if (response.success && response.data != null) {
      _wallet = response.data;
      _errorMessage = null;
    } else {
      _errorMessage = response.message ?? 'Failed to fetch wallet';
    }
    
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getAccountDetails(String accountId) async {
    final response = await _walletService.getAccountDetails(accountId);
    
    if (response.success && response.data != null) {
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // PAYMENT METHODS
  // ==========================================

  Future<List<Map<String, dynamic>>?> getTopUpMethods() async {
    final response = await _walletService.getTopUpMethods();
    
    if (response.success && response.data != null) {
      _topUpMethods = response.data!;
      notifyListeners();
      return _topUpMethods;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCashOutMethods() async {
    final response = await _walletService.getCashOutMethods();
    
    if (response.success && response.data != null) {
      _cashOutMethods = response.data!;
      notifyListeners();
      return _cashOutMethods;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // TOP-UP (DEPOSIT) - Two-step process
  // ==========================================

  /// Step 1: Validate top-up transaction
  Future<Map<String, dynamic>?> validateTopUp({
    required String source,
    required String phoneNumber,
    required double amount,
    String? destinationAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Validating transaction...';
    _validationData = null;
    notifyListeners();

    final response = await _walletService.validateTopUp(
      source: source,
      phoneNumber: phoneNumber,
      amount: amount,
      destinationAccountId: destinationAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _validationData = response.data;
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

  /// Step 2: Complete top-up after user confirmation
  Future<TransactionModel?> completeTopUp({
    required String validationRef,
    required String source,
    String? note,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing payment...';
    notifyListeners();

    final response = await _walletService.completeTopUp(
      validationRef: validationRef,
      source: source,
      note: note,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Top-up successful';
      _validationData = null; // Clear validation data
      
      await fetchWallet();
      
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
  // CASH OUT (WITHDRAW) - Two-step process
  // ==========================================

  /// Step 1: Validate cash-out transaction
  Future<Map<String, dynamic>?> validateCashOut({
    required String method,
    required String destination,
    required double amount,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Validating transaction...';
    _validationData = null;
    notifyListeners();

    final response = await _walletService.validateCashOut(
      method: method,
      destination: destination,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _validationData = response.data;
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

  /// Step 2: Complete cash-out after user confirmation
  Future<TransactionModel?> completeCashOut({
    required String validationRef,
    required String method,
    String? note,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing payment...';
    notifyListeners();

    final response = await _walletService.completeCashOut(
      validationRef: validationRef,
      method: method,
      note: note,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Cash out successful';
      _validationData = null;
      
      await fetchWallet();
      
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
  // BIEN TO BIEN TRANSFER - Two-step process
  // ==========================================

  /// Step 1: Validate transfer transaction
  Future<Map<String, dynamic>?> validateTransfer({
    required String recipientId,
    required double amount,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Validating transaction...';
    _validationData = null;
    notifyListeners();

    final response = await _walletService.validateTransfer(
      recipientId: recipientId,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _validationData = response.data;
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

  /// Step 2: Complete transfer after user confirmation
  Future<TransactionModel?> completeTransfer({
    required String validationRef,
    String? note,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing payment...';
    notifyListeners();

    final response = await _walletService.completeTransfer(
      validationRef: validationRef,
      note: note,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Transfer successful';
      _validationData = null;
      
      await fetchWallet();
      
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
  // UTILITY SERVICES (PLACEHOLDERS)
  // ==========================================

  Future<TransactionModel?> buyAirtime({
    required String network,
    required String phoneNumber,
    required double amount,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Purchasing airtime...';
    notifyListeners();

    final response = await _walletService.buyAirtime(
      network: network,
      phoneNumber: phoneNumber,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Airtime purchased successfully';
      
      await fetchWallet();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Airtime purchase failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> buyDataBundle({
    required String network,
    required String phoneNumber,
    required String bundleId,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Purchasing data bundle...';
    notifyListeners();

    final response = await _walletService.buyDataBundle(
      network: network,
      phoneNumber: phoneNumber,
      bundleId: bundleId,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Data bundle purchased successfully';
      
      await fetchWallet();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Data bundle purchase failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> payUtility({
    required String provider,
    required String accountNumber,
    required double amount,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing utility payment...';
    notifyListeners();

    final response = await _walletService.payUtility(
      provider: provider,
      accountNumber: accountNumber,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Utility payment successful';
      
      await fetchWallet();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Utility payment failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> paySchoolFees({
    required String system,
    required String studentNumber,
    required String schoolCode,
    required double amount,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing school fees payment...';
    notifyListeners();

    final response = await _walletService.paySchoolFees(
      system: system,
      studentNumber: studentNumber,
      schoolCode: schoolCode,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'School fees payment successful';
      
      await fetchWallet();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'School fees payment failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> payMerchant({
    required String merchantId,
    required double amount,
    String? sourceAccountId,
  }) async {
    _isProcessingPayment = true;
    _errorMessage = null;
    _paymentStatus = 'Processing merchant payment...';
    notifyListeners();

    final response = await _walletService.payMerchant(
      merchantId: merchantId,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );

    _isProcessingPayment = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _paymentStatus = 'Merchant payment successful';
      
      await fetchWallet();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Merchant payment failed';
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  void clearError() {
    _errorMessage = null;
    _paymentStatus = null;
    notifyListeners();
  }

  void clearValidationData() {
    _validationData = null;
    notifyListeners();
  }

  void clearLastTransaction() {
    _lastTransaction = null;
    notifyListeners();
  }

  void reset() {
    _wallet = null;
    _isLoading = false;
    _errorMessage = null;
    _lastTransaction = null;
    _isProcessingPayment = false;
    _paymentStatus = null;
    _validationData = null;
    _topUpMethods = [];
    _cashOutMethods = [];
    notifyListeners();
  }
}












// // ==========================================
// // FILE: lib/providers/wallet_provider.dart
// // Complete wallet state management with real backend
// // ==========================================
// import 'package:flutter/material.dart';
// import '../models/wallet_model.dart';
// import '../models/transaction_model.dart';
// import '../services/wallet_service.dart';

// class WalletProvider with ChangeNotifier {
//   final WalletService _walletService = WalletService();

//   WalletModel? _wallet;
//   bool _isLoading = false;
//   String? _errorMessage;
//   TransactionModel? _lastTransaction;
  
//   // Processing states
//   bool _isProcessingPayment = false;
//   String? _paymentStatus;
  
//   // Available payment methods
//   List<Map<String, dynamic>> _topUpMethods = [];
//   List<Map<String, dynamic>> _cashOutMethods = [];

//   WalletModel? get wallet => _wallet;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   double get balance => _wallet?.balance ?? 0;
//   double get availableBalance => _wallet?.availableBalance ?? 0;
//   TransactionModel? get lastTransaction => _lastTransaction;
//   bool get isProcessingPayment => _isProcessingPayment;
//   String? get paymentStatus => _paymentStatus;
//   List<Map<String, dynamic>> get topUpMethods => _topUpMethods;
//   List<Map<String, dynamic>> get cashOutMethods => _cashOutMethods;

//   // ==========================================
//   // WALLET OPERATIONS
//   // ==========================================

//   /// Fetch wallet balance
//   Future<void> fetchWallet() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     final response = await _walletService.getWallet();

//     _isLoading = false;

//     if (response.success && response.data != null) {
//       _wallet = response.data;
//       _errorMessage = null;
//     } else {
//       _errorMessage = response.message ?? 'Failed to fetch wallet';
//     }
    
//     notifyListeners();
//   }

//   /// Get account details
//   Future<Map<String, dynamic>?> getAccountDetails(String accountId) async {
//     final response = await _walletService.getAccountDetails(accountId);
    
//     if (response.success && response.data != null) {
//       return response.data;
//     } else {
//       _errorMessage = response.message;
//       notifyListeners();
//       return null;
//     }
//   }

//   // ==========================================
//   // PAYMENT METHODS
//   // ==========================================

//   /// Get available top-up methods
//   Future<List<Map<String, dynamic>>?> getTopUpMethods() async {
//     final response = await _walletService.getTopUpMethods();
    
//     if (response.success && response.data != null) {
//       _topUpMethods = response.data!;
//       notifyListeners();
//       return _topUpMethods;
//     } else {
//       _errorMessage = response.message;
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Get available cash-out methods
//   Future<List<Map<String, dynamic>>?> getCashOutMethods() async {
//     final response = await _walletService.getCashOutMethods();
    
//     if (response.success && response.data != null) {
//       _cashOutMethods = response.data!;
//       notifyListeners();
//       return _cashOutMethods;
//     } else {
//       _errorMessage = response.message;
//       notifyListeners();
//       return null;
//     }
//   }

//   // ==========================================
//   // TOP-UP (DEPOSIT)
//   // ==========================================

//   /// Top-up wallet (deposit)
//   Future<TransactionModel?> topUp({
//     required String source,
//     required String phoneNumber,
//     required double amount,
//     String? destinationAccountId,
//     String? note,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Processing top-up...';
//     notifyListeners();

//     final response = await _walletService.topUp(
//       source: source,
//       phoneNumber: phoneNumber,
//       amount: amount,
//       destinationAccountId: destinationAccountId,
//       note: note,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Top-up successful';
      
//       // Refresh wallet balance
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Top-up failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   // ==========================================
//   // CASH OUT (WITHDRAW)
//   // ==========================================

//   /// Cash out (withdraw)
//   Future<TransactionModel?> cashOut({
//     required String method,
//     required String destination,
//     required double amount,
//     String? sourceAccountId,
//     String? note,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Processing cash out...';
//     notifyListeners();

//     final response = await _walletService.cashOut(
//       method: method,
//       destination: destination,
//       amount: amount,
//       sourceAccountId: sourceAccountId,
//       note: note,
//       additionalData: additionalData,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Cash out successful';
      
//       // Refresh wallet balance
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Cash out failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   // ==========================================
//   // BIEN TO BIEN TRANSFER
//   // ==========================================

//   /// Bien to Bien transfer
//   Future<TransactionModel?> transfer({
//     required String recipientId,
//     required double amount,
//     String? note,
//     String? sourceAccountId,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Processing transfer...';
//     notifyListeners();

//     final response = await _walletService.transfer(
//       recipientId: recipientId,
//       amount: amount,
//       note: note,
//       sourceAccountId: sourceAccountId,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Transfer successful';
      
//       // Refresh wallet balance
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Transfer failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   // ==========================================
//   // UTILITY SERVICES (PLACEHOLDERS)
//   // ==========================================

//   /// Buy airtime
//   Future<TransactionModel?> buyAirtime({
//     required String network,
//     required String phoneNumber,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Purchasing airtime...';
//     notifyListeners();

//     final response = await _walletService.buyAirtime(
//       network: network,
//       phoneNumber: phoneNumber,
//       amount: amount,
//       sourceAccountId: sourceAccountId,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Airtime purchased successfully';
      
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Airtime purchase failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Buy data bundle
//   Future<TransactionModel?> buyDataBundle({
//     required String network,
//     required String phoneNumber,
//     required String bundleId,
//     String? sourceAccountId,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Purchasing data bundle...';
//     notifyListeners();

//     final response = await _walletService.buyDataBundle(
//       network: network,
//       phoneNumber: phoneNumber,
//       bundleId: bundleId,
//       sourceAccountId: sourceAccountId,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Data bundle purchased successfully';
      
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Data bundle purchase failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Pay utility bill
//   Future<TransactionModel?> payUtility({
//     required String provider,
//     required String accountNumber,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Processing utility payment...';
//     notifyListeners();

//     final response = await _walletService.payUtility(
//       provider: provider,
//       accountNumber: accountNumber,
//       amount: amount,
//       sourceAccountId: sourceAccountId,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Utility payment successful';
      
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Utility payment failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Pay school fees
//   Future<TransactionModel?> paySchoolFees({
//     required String system,
//     required String studentNumber,
//     required String schoolCode,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Processing school fees payment...';
//     notifyListeners();

//     final response = await _walletService.paySchoolFees(
//       system: system,
//       studentNumber: studentNumber,
//       schoolCode: schoolCode,
//       amount: amount,
//       sourceAccountId: sourceAccountId,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'School fees payment successful';
      
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'School fees payment failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   /// Pay merchant
//   Future<TransactionModel?> payMerchant({
//     required String merchantId,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     _isProcessingPayment = true;
//     _errorMessage = null;
//     _paymentStatus = 'Processing merchant payment...';
//     notifyListeners();

//     final response = await _walletService.payMerchant(
//       merchantId: merchantId,
//       amount: amount,
//       sourceAccountId: sourceAccountId,
//     );

//     _isProcessingPayment = false;

//     if (response.success && response.data != null) {
//       _lastTransaction = response.data;
//       _errorMessage = null;
//       _paymentStatus = 'Merchant payment successful';
      
//       await fetchWallet();
      
//       notifyListeners();
//       return response.data;
//     } else {
//       _errorMessage = response.message ?? 'Merchant payment failed';
//       _paymentStatus = null;
//       notifyListeners();
//       return null;
//     }
//   }

//   // ==========================================
//   // UTILITY METHODS
//   // ==========================================

//   /// Clear error
//   void clearError() {
//     _errorMessage = null;
//     _paymentStatus = null;
//     notifyListeners();
//   }

//   /// Clear last transaction
//   void clearLastTransaction() {
//     _lastTransaction = null;
//     notifyListeners();
//   }

//   /// Reset provider state
//   void reset() {
//     _wallet = null;
//     _isLoading = false;
//     _errorMessage = null;
//     _lastTransaction = null;
//     _isProcessingPayment = false;
//     _paymentStatus = null;
//     _topUpMethods = [];
//     _cashOutMethods = [];
//     notifyListeners();
//   }
// }