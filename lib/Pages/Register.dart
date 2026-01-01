// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class PhoneAuthPage extends StatefulWidget {
//   const PhoneAuthPage({super.key});
//
//   @override
//   State<PhoneAuthPage> createState() => _PhoneAuthPageState();
// }
//
// class _PhoneAuthPageState extends State<PhoneAuthPage> {
//   final TextEditingController phoneController = TextEditingController(); // 1
//   final TextEditingController otpController = TextEditingController();   // 2
//
//   String verificationId = "";    // 3
//   bool otpSent = false;          // 4
//   bool loading = false;          // 5
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Phone Login')),
//       body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // PHONE NUMBER TEXTFIELD
//             TextField(
//               controller: phoneController,          // 6
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(
//                 labelText: 'Phone Number',
//                 hintText: '+91XXXXXXXXXX',
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // OTP TEXTFIELD (only visible after OTP sent)
//             if (otpSent)                           // 7
//               TextField(
//                 controller: otpController,         // 8
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Enter OTP',
//                 ),
//               ),
//
//             const SizedBox(height: 24),
//
//             // BUTTON
//             ElevatedButton(
//               onPressed: loading
//                   ? null
//                   : () {
//                 if (!otpSent) {
//                   _sendOtp();               // 9
//                 } else {
//                   _verifyOtp();             // 10
//                 }
//               },
//               child: Text(otpSent ? 'Verify OTP' : 'Send OTP'),
//             ),
//
//             if (loading) const SizedBox(height: 16),
//             if (loading) const CircularProgressIndicator(), // 11
//           ],
//         ),
//
//     );
//   }
//
//   // STEP 1: SEND OTP
//   Future<void> _sendOtp() async {
//     setState(() {
//       loading = true;
//     });
//
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: phoneController.text.trim(),    // 12
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // Auto sign-in on some devices
//         await FirebaseAuth.instance.signInWithCredential(credential);     // 13
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() {
//           loading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.message}')),                // 14
//         );
//       },
//       codeSent: (String verId, int? resendToken) {
//         setState(() {
//           loading = false;
//           otpSent = true;             // 15
//           verificationId = verId;     // 16
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('OTP sent!')),                    // 17
//         );
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         verificationId = verId;                                         // 18
//       },
//     );
//   }
//
//   // STEP 2: VERIFY OTP
//   Future<void> _verifyOtp() async {
//     setState(() {
//       loading = true;
//     });
//
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(     // 19
//         verificationId: verificationId,
//         smsCode: otpController.text.trim(),
//       );
//
//       UserCredential userCredential =
//       await FirebaseAuth.instance.signInWithCredential(credential);  // 20
//
//       setState(() {
//         loading = false;
//       });
//
//       User? user = userCredential.user;                                  // 21
//
//       if (user != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Logged in as: ${user.phoneNumber}')),  // 22
//         );
//
//         // TODO: Navigate to home/chat page
//         // Navigator.pushReplacement(...)
//       }
//     } catch (e) {
//       setState(() {
//         loading = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid OTP')),                          // 23
//       );
//     }
//   }
// }
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();
        final String name = usernameController.text.trim();
        final String phonenumber = phoneController.text.trim();

        // Create user with FirebaseAuth
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = credential.user!.uid;
        // Save user info to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'Uid':uid,
          'username': name,
          'email': email,
          'phone':phonenumber,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Save to SharedPreferences (excluding password for security)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", email);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to BottomNavigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homepage()),
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30.0),

                /// Name
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Choose a name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    if (value.length < 3) return 'Username must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Ph.no',
                    hintText: 'Phone Numbe',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter the Phonenumber';
                    if (value.length < 10) return 'Phonenumber must be 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                /// Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                /// Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                /// Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_open_outlined),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),

                /// Register Button or Loading
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    textStyle: const TextStyle(fontSize: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Register',style: TextStyle(color: Colors.white),),
                ),
                const SizedBox(height: 20.0),

                /// Already have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Back to login
                      },
                      child: const Text('Login'),
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
