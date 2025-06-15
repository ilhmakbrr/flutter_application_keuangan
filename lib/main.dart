import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login.dart';
import '/screens/dashboard/dashboard.dart';
import '/screens/dashboard/beranda.dart'; 
import 'screens/auth/onboardingscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Periksa status dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    isFirstTime: isFirstTime,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isFirstTime;

  MyApp({
    required this.isLoggedIn,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoncosApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (isFirstTime) {
      return OnboardingScreen();
    } else if (isLoggedIn) {
      return TailorDashboard();
    } else {
      return LoginScreen();
    }
  }
}