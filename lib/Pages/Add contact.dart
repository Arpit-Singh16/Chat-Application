import 'package:chat/Providers/Nameprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<dataprovider>(
          builder: (context, contact, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        label: const Text(
                          "Enter the name",
                          style: TextStyle(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        label: const Text(
                          "Enter the phone number",
                          style: TextStyle(color: Colors.white),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 20),

                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);

                          await contact.addcontact(
                            nameController.text.trim(),
                            phoneController.text.trim(),

                          );
                          Navigator.pop(context);

                          setState(() => isLoading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Contact saved ✅"),
                            ),
                          );

                          // Clear fields if you want
                          nameController.clear();
                          phoneController.clear();

                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
