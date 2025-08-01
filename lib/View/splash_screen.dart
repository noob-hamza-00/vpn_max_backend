import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'Widgets/navbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  void preserve({required WidgetsBinding widgetsBinding}) {}
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  void _initializeSplash() {
    try {
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const BottomNavigator()));
        }
      });
    } catch (e) {
      log('Splash screen error: $e');
      // Show error dialog or fallback UI
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Initialization failed: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset("assets/images/splashlogo.jpg"),
      ),
    );
  }
}
