import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final spService = SpService();
  final authLocalRepository = AuthLocalRepository();

  // this is to sign up the users
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      final data = jsonDecode(res.body);
      final user = UserModel.fromLoginResponse(data);
      await spService.saveToken(user.token);
      await authLocalRepository.saveUser(user);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // this is to login the users with the credentials
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final data = jsonDecode(res.body);
      final user = UserModel.fromLoginResponse(data);
      await spService.saveToken(user.token);
      await authLocalRepository.saveUser(user);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // This is to update user profile
  Future<UserModel?> updateProfile({
    required String token,
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      final url = Uri.parse('${Constants.backendUri}/auth/update-profile');

      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          if (password != null && password.isNotEmpty) "password": password,
        }),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'] ?? "Failed to update profile";
      }

      final data = jsonDecode(res.body);
      return UserModel.fromMap(data);
    } catch (e) {
      throw e.toString();
    }
  }


// this is to get the users data
  Future<UserModel?> getUserData({required String token}) async {
    try {
      if (token.isEmpty) {
        return null;
      }

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/tokenIsValid'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse('${Constants.backendUri}/auth'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['error'];
      }

      final data = jsonDecode(userResponse.body);
      return UserModel.fromMap(data);
    } catch (e) {
      final user = await authLocalRepository.getUser();
      print(user);
      return user;
    }
  }

  //this is to get the otp when the users forget the password and wants to change it
  Future<void> sendForgotPasswordOtp(String email) async {
    final url = Uri.parse("${Constants.backendUri}/auth/forgot-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body["error"] ?? "Failed to send OTP");
    }
  }

  //tbis is to actually reset the password with the otp sent
  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('${Constants.backendUri}/auth/reset-password');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Reset failed');
    }
  }

}
