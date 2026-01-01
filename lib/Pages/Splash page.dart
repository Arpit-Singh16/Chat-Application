import 'dart:async';
import 'package:chat/Pages/homeppage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
        // Regular user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const homepage()),
        );

    } else {
      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: Image.asset("assets/images/e_logo.jpg").image,
              radius: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to My App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
