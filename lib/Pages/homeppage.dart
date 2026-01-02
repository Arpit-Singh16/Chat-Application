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
  /// receiverId -> chat document
  final Map<String, QueryDocumentSnapshot> chatMap = {};

  String formatTime(Timestamp? timestamp, BuildContext context) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }

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
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Add()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: contacts.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts.contacts[index];
                    final chatDoc = chatMap[contact['receiverId']];

                    final Timestamp? ts = chatDoc?['lastMessageTime'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              /// Avatar
                              Hero(
                                tag: 'avatar_$index',
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundImage: const AssetImage(
                                      "assets/images/gooku.jpg"),
                                ),
                              ),

                              const SizedBox(width: 14),

                              /// Name & Message
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact["name"] ?? "Name",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            chatDoc != null
                                                ? chatDoc['lastMessage']
                                                : "Tap to start the chat",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 40,),
                                        Text(
                                          formatTime(ts, context),
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
