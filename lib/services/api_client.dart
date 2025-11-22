// ==========================================
// FILE: lib/services/api_client.dart
// Updated HTTP client for real backend integration
// ==========================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiClient {
  // UPDATED: Real backend URL
  static const String baseUrl = 'https://bienug.com/APIs/BienAPINew/api';
  final StorageService _storage = StorageService();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<Map<String, String>> _getHeaders({bool needsAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool needsAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final headers = await _getHeaders(needsAuth: needsAuth);

      print('GET Request: $uri'); // Debug logging

      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      print('Response Status: ${response.statusCode}'); // Debug logging
      print('Response Body: ${response.body}'); // Debug logging

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } on HttpException {
      return ApiResponse.error(message: 'Service unavailable');
    } on TimeoutException {
      return ApiResponse.error(message: 'Request timeout');
    } catch (e) {
      print('API Error: $e'); // Debug logging
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      print('POST Request: $uri'); // Debug logging
      print('Request Body: ${jsonEncode(body)}'); // Debug logging

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}'); // Debug logging
      print('Response Body: ${response.body}'); // Debug logging

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } on HttpException {
      return ApiResponse.error(message: 'Service unavailable');
    } on TimeoutException {
      return ApiResponse.error(message: 'Request timeout');
    } catch (e) {
      print('API Error: $e'); // Debug logging
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(message: 'No internet connection');
    } catch (e) {
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool needsAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      final response = await http.delete(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(message: 'An error occurred: ${e.toString()}');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final jsonData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(jsonData, fromJson);
      } else {
        return ApiResponse.error(
          message: jsonData['message'] ?? jsonData['error'] ?? 'Request failed',
          errors: jsonData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Response Parse Error: $e'); // Debug logging
      return ApiResponse.error(
        message: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }
}