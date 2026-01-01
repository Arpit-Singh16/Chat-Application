import 'package:chat/Pages/homeppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    var username = usernameController.text.trim();
    var password = passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final auth = FirebaseAuth.instance;
        await auth.signInWithEmailAndPassword(
          email: username,
          password: password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ---------------- BODY ----------------
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // -------- LOGO --------
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.chat, size: 45, color: Colors.white),
                ),

                const SizedBox(height: 25),

                // -------- TITLE --------
                const Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Login to continue chatting",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 35),

                // -------- EMAIL --------
                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Colors.white60),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Enter your email'
                      : null,
                ),

                const SizedBox(height: 18),

                // -------- PASSWORD --------
                TextFormField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Colors.white60),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),

                const SizedBox(height: 30),

                // -------- LOGIN BUTTON --------
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -------- SIGN UP --------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white60),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),

                // -------- FORGOT PASSWORD --------
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => homepage()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
