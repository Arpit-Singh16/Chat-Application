import 'package:chat/Pages/homeppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final name = usernameController.text.trim();
        final phone = phoneController.text.trim();

        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = credential.user!.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'Uid': uid,
          'username': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });

        SharedPreferences prefs =
        await SharedPreferences.getInstance();
        prefs.setString("email", email);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => homepage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // -------- Reusable Field --------
  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white60),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Register",
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

                // -------- ICON --------
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_add,
                      size: 40, color: Colors.white),
                ),

                const SizedBox(height: 25),

                // -------- TITLE --------
                const Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Join and start chatting",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                inputField(
                  controller: usernameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your name';
                    }
                    if (value.length < 3) {
                      return 'Minimum 3 characters';
                    }
                    return null;
                  },
                ),

                inputField(
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter phone number';
                    }
                    if (value.length < 10) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                ),

                inputField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email';
                    }
                    if (!RegExp(
                        r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),

                inputField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 characters';
                    }
                    return null;
                  },
                ),

                inputField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_open_outlined,
                  obscure: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // -------- REGISTER BUTTON --------
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -------- LOGIN --------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white60),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
