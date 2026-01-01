import 'dart:async';

import 'package:chat/Providers/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  void initState() {
    super.initState();

    // Load profile data once when screen opens
    Future.microtask(() async {
      final profile =
      Provider.of<profileprovider>(context, listen: false);
      await profile.loadProfile();

      // After loading, fill controllers
      if (profile.username != null) {
        usernameController.text = profile.username ?? '';
        phoneController.text = profile.phone ?? '';
        taglineController.text = profile.tagline ?? '';
      }
    });
  }


  @override
  Widget addressField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    taglineController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user= FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.black,
        leading:
        IconButton(onPressed: () => Navigator.of(context).pop(),icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text("🧑 Profile & Address", style: TextStyle(color: Colors.white)),

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: CircleAvatar(radius: 50,backgroundColor: Colors.grey,child: Icon(Icons.person),)),
              ),
              Expanded(
                child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                key: _formKey,
                child: Consumer<profileprovider>(
                  builder: (context, profile, child) {
                    return ListView(
                      children: [
                        addressField("Full Name", usernameController),
                        addressField("Phone Number", phoneController,
                            keyboardType: TextInputType.phone),
                        addressField("tagline", taglineController),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:() async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => isLoading = true);

                              await profile.updateProfile(
                                usernameController.text.trim(),
                                phoneController.text.trim(),
                                taglineController.text.trim(),
                              );

                              setState(() => isLoading = false);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile saved ✅"),
                                ),
                              );

                              // Optionally go to another page:
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("💾 Save Profile ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  } ),
                        ),
                      ),
              ),
            ],
          ),
    );
  }
}
