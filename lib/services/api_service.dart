// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://808c-112-215-241-107.ngrok-free.app/mobile_banking_api/api';
  static const String tokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  
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
        
        // Simpan token dan data user
        final prefs = await SharedPreferences.getInstance();
        if (responseData['token'] != null) {
          await prefs.setString(tokenKey, responseData['token']);
        }
        
        // Simpan data user
        await prefs.setString(userDataKey, json.encode(responseData));
        
        return {
          'status': 'success',
          'message': responseData['message'] ?? 'Login berhasil',
          'data': UserData.fromJson(responseData)
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
    final userDataString = prefs.getString(userDataKey);
    
    if (userDataString == null) {
      throw Exception('Data pengguna tidak ditemukan');
    }

    try {
      final userData = json.decode(userDataString);
      return UserData.fromJson(userData);
    } catch (e) {
      logger.e('Error getting user data', error: e);
      throw Exception('Terjadi kesalahan saat memuat data pengguna');
    }
  }

  // Validate Account
  Future<UserData> validateAccount(String accountNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      final response = await http.post(
        Uri.parse('$baseUrl/validate_account.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'account_number': accountNumber,
        }),
      );

      final responseData = jsonDecode(response.body);
      logger.i('Validate account response: $responseData');

      if (response.statusCode == 200) {
        return UserData.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memvalidasi rekening');
      }
    } catch (e) {
      logger.e('Validate account error', error: e);
      throw Exception('Terjadi kesalahan saat memvalidasi rekening');
    }
  }

  // Transfer
  Future<void> transfer({
    required String recipientAccount,
    required int amount,
    String? note,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      final response = await http.post(
        Uri.parse('$baseUrl/transfer.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipient_account': recipientAccount,
          'amount': amount,
          'note': note,
        }),
      );

      final responseData = jsonDecode(response.body);
      logger.i('Transfer response: $responseData');

      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Transfer gagal');
      }
    } catch (e) {
      logger.e('Transfer error', error: e);
      throw Exception('Terjadi kesalahan saat melakukan transfer');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userDataKey);
    } catch (e) {
      logger.e('Logout error', error: e);
      throw Exception('Gagal logout: $e');
    }
  }

  // Top Up
  Future<Map<String, dynamic>> topUp({required int amount}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);

      final response = await http.post(
        Uri.parse('$baseUrl/topup.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

      final responseData = jsonDecode(response.body);
      logger.i('Top up response: $responseData');

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': responseData['message'] ?? 'Top up berhasil',
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Top up gagal',
        };
      }
    } catch (e) {
      logger.e('Top up error', error: e);
      return {
        'status': 'error',
        'message': 'Terjadi kesalahan saat top up',
      };
    }
  }
}