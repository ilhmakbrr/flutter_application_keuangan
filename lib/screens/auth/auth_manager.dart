import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimeKey = 'login_time';

  // Simpan status login
  static Future<void> setLoggedIn(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (isLoggedIn) {
        // Optional: Cek apakah login masih valid (misalnya tidak lebih dari 30 hari)
        final loginTimeString = prefs.getString(_loginTimeKey);
        if (loginTimeString != null) {
          final loginTime = DateTime.parse(loginTimeString);
          final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
          
          // Jika login lebih dari 30 hari, logout otomatis
          if (daysSinceLogin > 30) {
            await logout();
            return false;
          }
        }
      }
      
      return isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_loginTimeKey);
  }

  // Clear all data (for debugging)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}