import 'package:chat/Pages/Login.dart';
import 'package:chat/Pages/profile%20page.dart';
import 'package:chat/Pages/chatting.dart';
import 'package:chat/Pages/Setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Chatprovider.dart';
import '../Providers/Nameprovider.dart';
import 'Add contact.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  /// map: receiverId -> chat document
  final Map<String, QueryDocumentSnapshot> chatMap = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<dataprovider>(context, listen: false).fetchcontact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Profile()),
                );
              } else if (value == 'setting') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Settingspage()),
                );
              } else {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'setting', child: Text('Setting')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          )
        ],
      ),

      // ---------------- FAB ----------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Add()),
          );
        },
        child: const Icon(Icons.add),
      ),

      // ---------------- BODY ----------------
      body: Consumer2<Chatprovider, dataprovider>(
        builder: (context, chat, contacts, _) {
          return StreamBuilder<QuerySnapshot>(
            stream: chat.lastmessage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              /// rebuild mapping every snapshot
              chatMap.clear();

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final participants =
                  List<String>.from(doc['participants']);

                  final otherUserId = participants.firstWhere(
                        (id) => id != chat.senderId,
                  );

                  chatMap[otherUserId] = doc;
                }
              }

              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/chat 1.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ListView.builder(
                  itemCount: contacts.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts.contacts[index];
                    final chatDoc = chatMap[contact['receiverId']];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        border: Border(
                          bottom:
                          BorderSide(color: Colors.grey.shade600),
                        ),
                      ),
                      child: ListTile(
                        leading: Hero(
                          tag: 'avatar_$index',
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: const AssetImage(
                              "assets/images/gooku.jpg",
                            ),
                          ),
                        ),

                        title: Text(
                          contact["name"] ?? "Name",
                          style:
                          const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          chatDoc != null
                              ? chatDoc['lastMessage']
                              : "Tap to start the chat",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        onTap: () {
                          chat.initChat(contact["receiverId"]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Chatting(
                                receivername: contact["name"],
                                receiverId: contact["receiverId"],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- FULL SCREEN IMAGE ----------------
class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final String tag;

  const FullScreenImage({
    super.key,
    required this.imagePath,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: tag,
            child: Image.asset(imagePath),
          ),
        ),
      ),
    );
  }
}
