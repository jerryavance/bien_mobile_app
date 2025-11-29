// ==========================================
// FILE: lib/services/bill_service.dart
// Bill payment API integration
// ==========================================
import '../models/bill_models.dart';
import '../models/api_response.dart';
import 'api_client.dart';

class BillService {
  final ApiClient _api = ApiClient();

  // ==========================================
  // GET ALL BILL CATEGORIES AND BILLERS
  // ==========================================

  /// Fetch all bill categories with their billers
  Future<ApiResponse<List<BillCategory>>> listBillers() async {
    try {
      print('BillService: Fetching all billers');

      final response = await _api.get<List<dynamic>>(
        '/bills/list-billers',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final categories = response.data!
            .map((cat) => BillCategory.fromJson(cat as Map<String, dynamic>))
            .toList();

        print('✅ Fetched ${categories.length} bill categories');
        return ApiResponse.success(data: categories);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch billers',
      );
    } catch (e) {
      print('❌ BillService.listBillers error: $e');
      return ApiResponse.error(message: 'Error fetching billers: $e');
    }
  }

  // ==========================================
  // VALIDATE BILL PAYMENT
  // ==========================================

  /// Validate bill payment before processing
  Future<ApiResponse<BillValidationResponse>> validateBill({
    required String billerId,
    required String itemId,
    required String customerId,
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final body = {
        'billerId': billerId,
        'itemId': itemId,
        'customerId': customerId,
        'amount': amount,
        'phoneNumber': phoneNumber,
      };

      print('BillService: Validating bill payment');
      print('Request body: $body');

      final response = await _api.post<Map<String, dynamic>>(
        '/bills/validate-biller',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final validation = BillValidationResponse.fromJson(response.data!);

        if (!validation.isSuccessful) {
          return ApiResponse.error(
            message: validation.responseMessage,
          );
        }

        print('✅ Bill validation successful');
        print('Retrieval Ref: ${validation.retrievalReference}');
        print('Customer: ${validation.customerName}');
        print('Total Amount: ${validation.totalAmount}');

        return ApiResponse.success(data: validation);
      }

      return ApiResponse.error(
        message: response.message ?? 'Bill validation failed',
      );
    } catch (e) {
      print('❌ BillService.validateBill error: $e');
      return ApiResponse.error(message: 'Validation error: $e');
    }
  }

  // ==========================================
  // PAY BILL (COMPLETE PAYMENT)
  // ==========================================

  /// Complete bill payment after validation
  Future<ApiResponse<BillPaymentResponse>> payBill({
    required String retrievalReference,
  }) async {
    try {
      final body = {
        'retrievalReference': retrievalReference,
      };

      print('BillService: Processing bill payment');
      print('Retrieval Ref: $retrievalReference');

      final response = await _api.post<Map<String, dynamic>>(
        '/bills/pay-biller',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final payment = BillPaymentResponse.fromJson(response.data!);

        if (!payment.isSuccessful) {
          return ApiResponse.error(
            message: payment.responseMessage,
          );
        }

        print('✅ Bill payment successful');
        print('Transaction Ref: ${payment.transactionReference}');
        if (payment.token != null) {
          print('Token: ${payment.token}');
        }
        if (payment.units != null) {
          print('Units: ${payment.units}');
        }

        return ApiResponse.success(data: payment);
      }

      return ApiResponse.error(
        message: response.message ?? 'Bill payment failed',
      );
    } catch (e) {
      print('❌ BillService.payBill error: $e');
      return ApiResponse.error(message: 'Payment error: $e');
    }
  }

  // ==========================================
  // CHECK PAYMENT STATUS
  // ==========================================

  /// Check bill payment status
  Future<ApiResponse<Map<String, dynamic>>> checkPaymentStatus({
    required String transactionId,
  }) async {
    try {
      print('BillService: Checking payment status for: $transactionId');

      final response = await _api.get<Map<String, dynamic>>(
        '/bills/pay-biller-status/$transactionId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        print('✅ Payment status retrieved');
        return ApiResponse.success(data: response.data!);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to check payment status',
      );
    } catch (e) {
      print('❌ BillService.checkPaymentStatus error: $e');
      return ApiResponse.error(message: 'Error checking status: $e');
    }
  }
}