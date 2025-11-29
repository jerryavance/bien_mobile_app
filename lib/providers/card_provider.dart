// ==========================================
// FILE: lib/providers/card_provider.dart
// Card state management
// ==========================================
import 'package:flutter/material.dart';
import '../models/card_models.dart';
import '../models/transaction_model.dart';
import '../services/card_service.dart';

class CardProvider with ChangeNotifier {
  final CardService _cardService = CardService();

  // Cards state
  List<CardModel> _cards = [];
  CardModel? _selectedCard;
  bool _isLoading = false;
  String? _errorMessage;

  // Transaction state
  bool _isProcessing = false;
  String? _processingStatus;
  Map<String, dynamic>? _validationData;
  TransactionModel? _lastTransaction;

  // Getters
  List<CardModel> get cards => _cards;
  CardModel? get selectedCard => _selectedCard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _isProcessing;
  String? get processingStatus => _processingStatus;
  Map<String, dynamic>? get validationData => _validationData;
  TransactionModel? get lastTransaction => _lastTransaction;

  CardModel? get defaultCard {
    try {
      return _cards.firstWhere((card) => card.isDefault);
    } catch (e) {
      return _cards.isNotEmpty ? _cards.first : null;
    }
  }

  // ==========================================
  // CARD MANAGEMENT
  // ==========================================

  Future<void> fetchCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _cardService.getCards();

    _isLoading = false;

    if (response.success && response.data != null) {
      _cards = response.data!;
      _errorMessage = null;
      
      // Set default card as selected if none selected
      if (_selectedCard == null && _cards.isNotEmpty) {
        _selectedCard = defaultCard ?? _cards.first;
      }
      
      print('✅ Loaded ${_cards.length} cards');
    } else {
      _errorMessage = response.message ?? 'Failed to load cards';
      print('❌ Error loading cards: $_errorMessage');
    }

    notifyListeners();
  }

  void selectCard(CardModel card) {
    _selectedCard = card;
    notifyListeners();
  }

  // ==========================================
  // CARD STATUS MANAGEMENT
  // ==========================================

  Future<bool> freezeCard(String cardId) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Freezing card...';
    notifyListeners();

    final response = await _cardService.freezeCard(cardId);

    _isProcessing = false;

    if (response.success && response.data != null) {
      // Update card in list
      final index = _cards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        _cards[index] = response.data!;
        if (_selectedCard?.id == cardId) {
          _selectedCard = response.data!;
        }
      }
      
      _errorMessage = null;
      _processingStatus = 'Card frozen successfully';
      notifyListeners();
      
      // Clear status after delay
      Future.delayed(const Duration(seconds: 2), () {
        _processingStatus = null;
        notifyListeners();
      });
      
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to freeze card';
      _processingStatus = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfreezeCard(String cardId) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Unfreezing card...';
    notifyListeners();

    final response = await _cardService.unfreezeCard(cardId);

    _isProcessing = false;

    if (response.success && response.data != null) {
      final index = _cards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        _cards[index] = response.data!;
        if (_selectedCard?.id == cardId) {
          _selectedCard = response.data!;
        }
      }
      
      _errorMessage = null;
      _processingStatus = 'Card unfrozen successfully';
      notifyListeners();
      
      Future.delayed(const Duration(seconds: 2), () {
        _processingStatus = null;
        notifyListeners();
      });
      
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to unfreeze card';
      _processingStatus = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> blockCard(String cardId) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Blocking card...';
    notifyListeners();

    final response = await _cardService.blockCard(cardId);

    _isProcessing = false;

    if (response.success && response.data != null) {
      final index = _cards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        _cards[index] = response.data!;
        if (_selectedCard?.id == cardId) {
          _selectedCard = response.data!;
        }
      }
      
      _errorMessage = null;
      _processingStatus = 'Card blocked successfully';
      notifyListeners();
      
      Future.delayed(const Duration(seconds: 2), () {
        _processingStatus = null;
        notifyListeners();
      });
      
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to block card';
      _processingStatus = null;
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // CARD TOP-UP
  // ==========================================

  Future<Map<String, dynamic>?> validateCardTopUp({
    required String cardId,
    required double amount,
    required String source,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Validating top-up...';
    _validationData = null;
    notifyListeners();

    final response = await _cardService.validateCardTopUp(
      cardId: cardId,
      amount: amount,
      source: source,
    );

    _isProcessing = false;

    if (response.success && response.data != null) {
      _validationData = response.data;
      _errorMessage = null;
      _processingStatus = 'Validation successful';
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Validation failed';
      _processingStatus = null;
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> completeCardTopUp({
    required String validationRef,
    String? note,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Processing top-up...';
    notifyListeners();

    final response = await _cardService.completeCardTopUp(
      validationRef: validationRef,
      note: note,
    );

    _isProcessing = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _processingStatus = 'Top-up successful';
      _validationData = null;
      
      // Refresh cards to update balance
      await fetchCards();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Top-up failed';
      _processingStatus = null;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // CARD TRANSFER
  // ==========================================

  Future<Map<String, dynamic>?> validateCardTransfer({
    required String cardId,
    required double amount,
    required String destination,
    required String destinationType,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Validating transfer...';
    _validationData = null;
    notifyListeners();

    final response = await _cardService.validateCardTransfer(
      cardId: cardId,
      amount: amount,
      destination: destination,
      destinationType: destinationType,
    );

    _isProcessing = false;

    if (response.success && response.data != null) {
      _validationData = response.data;
      _errorMessage = null;
      _processingStatus = 'Validation successful';
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Validation failed';
      _processingStatus = null;
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> completeCardTransfer({
    required String validationRef,
    String? note,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _processingStatus = 'Processing transfer...';
    notifyListeners();

    final response = await _cardService.completeCardTransfer(
      validationRef: validationRef,
      note: note,
    );

    _isProcessing = false;

    if (response.success && response.data != null) {
      _lastTransaction = response.data;
      _errorMessage = null;
      _processingStatus = 'Transfer successful';
      _validationData = null;
      
      // Refresh cards to update balance
      await fetchCards();
      
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Transfer failed';
      _processingStatus = null;
      notifyListeners();
      return null;
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  void clearError() {
    _errorMessage = null;
    _processingStatus = null;
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
    _cards = [];
    _selectedCard = null;
    _isLoading = false;
    _errorMessage = null;
    _isProcessing = false;
    _processingStatus = null;
    _validationData = null;
    _lastTransaction = null;
    notifyListeners();
  }
}