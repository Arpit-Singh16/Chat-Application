import 'package:chat/Customs/MessageBUbble.dart';
import 'package:chat/Providers/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Chatprovider.dart';

class Chatting extends StatefulWidget {
  final String receivername;
  final String receiverId;
  final String Number;

  const Chatting({
    super.key,
    required this.receivername,
    required this.receiverId,
    required this.Number,
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
        actions: [
          IconButton(onPressed: ()=>calling(widget.Number), icon: Icon(Icons.phone)),
          if (widget.receiverId != 'AI_ASSISTANT')
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                final summary = await Provider.of<Chatprovider>(context, listen: false).summarizeChat();
                Navigator.pop(context); // dismiss loading
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    title: const Text('Chat Summary', style: TextStyle(color: Colors.white)),
                    content: SingleChildScrollView(
                      child: Text(summary ?? 'No summary available.', style: const TextStyle(color: Colors.white70)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close', style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      // ---------------- BODY ----------------
      body: Consumer<Chatprovider>(
        builder: (context, chat, _) {
          return Column(
            children: [
              // -------- MESSAGES --------
              const Expanded(
                child: MessageBubble(),
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
                        if (widget.receiverId != 'AI_ASSISTANT')
                          IconButton(
                            onPressed: () async {
                              final text = textcontroller.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please type a message first')),
                                );
                                return;
                              }
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date == null) return;
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time == null) return;
                              final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              if (scheduled.isBefore(DateTime.now())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot schedule in the past')),
                                );
                                return;
                              }
                              Provider.of<Chatprovider>(context, listen: false).sendmessages(text, scheduledTime: scheduled);
                              textcontroller.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Message scheduled for ${time.format(context)}')),
                              );
                            },
                            icon: const Icon(
                              Icons.schedule,
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
