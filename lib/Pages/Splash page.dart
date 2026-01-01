import 'dart:async';
import 'package:chat/Pages/homeppage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const homepage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // -------- Gradient Background --------
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xFF121212),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // -------- Logo with Glow --------
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 90,
                backgroundImage:
                const AssetImage("assets/images/e_logo.jpg"),
              ),
            ),

            const SizedBox(height: 30),

            // -------- App Name --------
            const Text(
              "Welcome to My App",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 10),

            // -------- Tagline --------
            const Text(
              "Connect • Chat • Enjoy",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 40),

            // -------- Loader --------
            const CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
