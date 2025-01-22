// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://808c-112-215-241-107.ngrok-free.app/mobile_banking_api/api';
  static const String tokenKey = 'user_token';
  
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart
    ),
  );

  // Login
  Future<Map<String, dynamic>> login(String username, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.i('Login response: $responseData');
        
        // Simpan token
        if (responseData['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey, responseData['token']);
        }
        
        return {
          'status': 'success',
          'message': responseData['message'] ?? 'Login berhasil',
          'data': responseData
        };
      } else {
        final responseData = jsonDecode(response.body);
        logger.w('Login failed: $responseData');
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      logger.e('Login error', error: e);
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat login',
      };
    }
  }

  // Get User Data
  Future<UserData> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return UserData.fromJson(responseData);
      } else {
        throw Exception('Gagal memuat data pengguna');
      }
    } catch (e) {
      logger.e('Error getting user data', error: e);
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout.php'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
      }

      await prefs.remove(tokenKey);
    } catch (e) {
      logger.e('Logout error', error: e);
      throw Exception('Gagal logout: $e');
    }
  }

  // Debug helper
  void logResponse(http.Response response) {
    logger.d('Response Log', error: {
      'Status Code': response.statusCode,
      'Headers': response.headers,
      'Body': response.body
    });
  }
}