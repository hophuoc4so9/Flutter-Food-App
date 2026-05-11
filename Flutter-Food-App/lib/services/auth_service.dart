import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  /// Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      var reqBody = {
        "email": email,
        "password": password
      };

      var response = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'Registration failed',
        'data': jsonResponse['success'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      var reqBody = {
        "email": email,
        "password": password
      };

      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'Login failed',
        'token': jsonResponse['success']?['token'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'token': null,
      };
    }
  }

  /// Send OTP for password reset
  static Future<Map<String, dynamic>> sendOTP({
    required String email,
  }) async {
    try {
      var reqBody = {"email": email};

      var response = await http.post(
        Uri.parse(forgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'Failed to send OTP',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Reset password with OTP
  static Future<Map<String, dynamic>> performPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      var reqBody = {
        "email": email,
        "otp": otp,
        "newPassword": newPassword
      };

      var response = await http.post(
        Uri.parse(resetPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'Failed to reset password',
        'data': jsonResponse['success'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      var reqBody = {
        "email": email,
        "otp": otp,
      };

      var response = await http.post(
        Uri.parse('${Uri.parse(registration).replace(path: '')}/users/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'OTP verification failed',
        'data': jsonResponse['success'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Send OTP for email verification
  static Future<Map<String, dynamic>> sendEmailVerificationOTP({
    required String email,
  }) async {
    try {
      var reqBody = {"email": email};

      var response = await http.post(
        Uri.parse('${Uri.parse(registration).replace(path: '')}/users/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'Failed to send OTP',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Resend OTP
  static Future<Map<String, dynamic>> resendOTP({
    required String email,
  }) async {
    try {
      var reqBody = {"email": email};

      var response = await http.post(
        Uri.parse('${Uri.parse(registration).replace(path: '')}/users/resend-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      return {
        'status': jsonResponse['status'] ?? false,
        'message': jsonResponse['message'] ?? 'Failed to resend OTP',
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
