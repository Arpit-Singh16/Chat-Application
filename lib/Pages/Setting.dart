import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settingspage extends StatelessWidget {
  const Settingspage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          /// -------- PROFILE CARD --------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Name",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Hey there! I am using Chat App",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// -------- AI KEY --------
          settingsTile(
            icon: Icons.key,
            title: "AI Assistant",
            subtitle: "Configure Gemini API Key",
            onTap: () => _showApiKeyDialog(context),
          ),

          /// -------- SETTINGS OPTIONS --------
          settingsTile(
            icon: Icons.lock_outline,
            title: "Privacy",
            subtitle: "Blocked contacts, last seen",
          ),
          settingsTile(
            icon: Icons.notifications_none,
            title: "Notifications",
            subtitle: "Message, group & call tones",
          ),
          settingsTile(
            icon: Icons.chat_bubble_outline,
            title: "Chats",
            subtitle: "Theme, wallpapers, chat history",
          ),
          settingsTile(
            icon: Icons.storage_outlined,
            title: "Storage & Data",
            subtitle: "Network usage, storage",
          ),
          settingsTile(
            icon: Icons.help_outline,
            title: "Help",
            subtitle: "FAQ, contact us",
          ),
          settingsTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "App info, version",
          ),

          const SizedBox(height: 30),

          /// -------- LOGOUT --------
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                // logout logic later
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('gemini_api_key') ?? '';
    final TextEditingController controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Gemini API Key', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter API Key',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                await prefs.setString('gemini_api_key', controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key saved ✅')),
                );
              },
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  /// -------- REUSABLE TILE --------
  Widget settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white38,
            size: 16,
          ),
          onTap: onTap ?? () {
            // navigate later
          },
        ),
      ),
    );
  }
}
