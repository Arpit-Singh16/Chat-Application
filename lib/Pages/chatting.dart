import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Chatprovider.dart';

class Chatting extends StatefulWidget {
  final String receivername;
  final String receiverId;

  const Chatting({
    super.key,
    required this.receivername,
    required this.receiverId,
  });

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  final textcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Chatprovider>(context, listen: false)
          .initChat(widget.receiverId);
    });
  }

  @override
  void dispose() {
    textcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              widget.receivername,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      // ---------------- BODY ----------------
      body: Consumer<Chatprovider>(
        builder: (context, chat, _) {
          if (chat.chatroomId == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ---------------- MESSAGES ----------------
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/chat 1.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: chat.messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No messages",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final msg = snapshot.data!.docs[index];
                          final isMe = msg['senderId'] == myId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width *
                                    0.75,
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.green.shade600
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                  const Radius.circular(14),
                                  topRight:
                                  const Radius.circular(14),
                                  bottomLeft: Radius.circular(
                                      isMe ? 14 : 0),
                                  bottomRight: Radius.circular(
                                      isMe ? 0 : 14),
                                ),
                              ),
                              child: Text(
                                msg['text'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // ---------------- INPUT BAR ----------------
              SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.white70,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textcontroller,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type a message",
                              hintStyle:
                              TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.black),
                            onPressed: () {
                              final text =
                              textcontroller.text.trim();
                              if (text.isEmpty) return;

                              chat.sendmessages(text);
                              textcontroller.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
