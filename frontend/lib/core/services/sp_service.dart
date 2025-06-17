import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
class SpService {
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user-data';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
    await prefs.setString(_tokenKey, user.token); // Keep token synced
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromMap(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

// import 'package:shared_preferences/shared_preferences.dart';
//
// class SpService {
//   final String _tokenKey = 'auth_token';
//
//   Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }
//
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }
//
//   Future<void> clearToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
// }
//
// // import 'dart:convert';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:frontend/models/user_model.dart';
// //
// // class SpService {
// //   static const String _tokenKey = 'x-auth-token';
// //   static const String _userKey = 'user-data';
// //
// //   Future<void> setToken(String token) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     prefs.setString(_tokenKey, token);
// //   }
// //
// //   Future<String?> getToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getString(_tokenKey);
// //   }
// //
// //   Future<void> saveUser(UserModel user) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     prefs.setString(_userKey, jsonEncode(user.toJson()));
// //     prefs.setString(_tokenKey, user.token); // Ensure token is always set
// //   }
// //
// //   Future<UserModel?> getUser() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final userJson = prefs.getString(_userKey);
// //     if (userJson != null) {
// //       return UserModel.fromJson(jsonDecode(userJson));
// //     }
// //     return null;
// //   }
// //
// //   Future<void> clear() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.remove(_tokenKey);
// //     await prefs.remove(_userKey);
// //   }
// // }
// //
// //
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // class SpService {
// // //   Future<void> setToken(String token) async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     prefs.setString('x-auth-token', token);
// // //   }
// // //
// // //   Future<String?> getToken() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     return prefs.getString('x-auth-token');
// // //   }
// // // }
