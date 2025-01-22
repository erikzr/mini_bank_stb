import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://808c-112-215-241-107.ngrok-free.app/mobile_banking_api/api';
  
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
          await prefs.setString('user_token', responseData['token']);
        }
        
        // Simpan data user
        await prefs.setString('user_data', json.encode(responseData));
        
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
    final userDataString = prefs.getString('user_data');
    
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

  // Transfer
  Future<void> transfer({
    required String fromAccountNumber,
    required String recipientAccount,
    required int amount,
    String? note,
  }) async {
    try {
      // Log request untuk debugging
      logger.i('Transfer request:', error: {
        'from_account_number': fromAccountNumber,
        'recipient_account': recipientAccount,
        'amount': amount,
        'description': note ?? 'Transfer'
      });

      final response = await http.post(
        Uri.parse('$baseUrl/transfer.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'from_account_number': fromAccountNumber,
          'recipient_account': recipientAccount,
          'amount': amount,
          'description': note ?? 'Transfer'
        }),
      );

      // Log response untuk debugging
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Transfer gagal');
      }

      // Parse response jika sukses
      final responseData = jsonDecode(response.body);
      logger.i('Transfer successful: ${responseData['message']}');
    } catch (e) {
      logger.e('Transfer error', error: e);
      rethrow; // Lempar error asli untuk ditangani di UI
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
      await prefs.remove('user_data');
    } catch (e) {
      logger.e('Logout error', error: e);
      throw Exception('Gagal logout: $e');
    }
  }

  // Top Up
  Future<Map<String, dynamic>> topUp({
    required int amount,
    required String accountNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/topup.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'account_number': accountNumber,
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
