import 'dart:async';

import 'package:chat/Providers/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final profile =
      Provider.of<profileprovider>(context, listen: false);
      await profile.loadProfile();

      if (profile.username != null) {
        usernameController.text = profile.username ?? '';
        phoneController.text = profile.phone ?? '';
        taglineController.text = profile.tagline ?? '';
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    taglineController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // -------- Reusable Input Field --------
  Widget profileField(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) =>
        value!.isEmpty ? '$label is required' : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
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
    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
          const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 20),

          // -------- PROFILE AVATAR --------
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person,
                    size: 50, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit,
                    size: 16, color: Colors.black),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // -------- FORM --------
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Consumer<profileprovider>(
                  builder: (context, profile, _) {
                    return ListView(
                      children: [
                        profileField(
                          "Full Name",
                          usernameController,
                        ),
                        profileField(
                          "Phone Number",
                          phoneController,
                          keyboardType:
                          TextInputType.phone,
                        ),
                        profileField(
                          "About",
                          taglineController,
                        ),

                        const SizedBox(height: 30),

                        // -------- SAVE BUTTON --------
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!
                                  .validate()) {
                                setState(
                                        () => isLoading = true);

                                await profile.updateProfile(
                                  usernameController.text
                                      .trim(),
                                  phoneController.text.trim(),
                                  taglineController.text.trim(),
                                );

                                setState(
                                        () => isLoading = false);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Profile saved ✅"),
                                  ),
                                );
                              }
                            },
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.green,
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    14),
                              ),
                            ),
                            child: const Text(
                              "Save Profile",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
