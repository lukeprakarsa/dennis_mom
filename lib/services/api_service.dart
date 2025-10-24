import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

/// Low-level API service for making HTTP requests to the backend
class ApiService {
  // Automatically detect platform and use appropriate base URL
  // For Android physical device: http://192.168.50.88:3000 (your PC's IP)
  // For Android emulator: http://10.0.2.2:3000
  // For Windows/Web/iOS: http://localhost:3000
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Use your PC's local IP address for physical Android devices
      return 'http://192.168.50.88:3000';
    }
    return 'http://localhost:3000';
  }

  /// Make a GET request
  static Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final headers = _buildHeaders(token);
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      return await http.get(uri, headers: headers);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Make a POST request
  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final headers = _buildHeaders(token);
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      return await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Make a PUT request
  static Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final headers = _buildHeaders(token);
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      return await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Make a DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    String? token,
  }) async {
    final headers = _buildHeaders(token);
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      return await http.delete(uri, headers: headers);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Build request headers
  static Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        error['error'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
