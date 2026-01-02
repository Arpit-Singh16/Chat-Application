import 'package:chat/Customs/MessageBUbble.dart';
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
  final TextEditingController textcontroller = TextEditingController();

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
          return Column(
            children: [
              // -------- MESSAGES --------
              const Expanded(
                child: messagebubble(),
              ),

              // -------- INPUT BAR --------
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
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
                            style:
                            const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type a message",
                              hintStyle: TextStyle(
                                  color: Colors.white54),
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
