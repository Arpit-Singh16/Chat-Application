import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Chatprovider.dart';

class messagebubble extends StatelessWidget {
  const messagebubble({super.key});

  // -------- TIME FORMAT --------
  String formatTime(Timestamp? timestamp, BuildContext context) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }

  // -------- DATE LABEL --------
  String dateLabel(DateTime date) {
    DateTime now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) {
      return "Today";
    } else if (DateUtils.isSameDay(
        date, now.subtract(const Duration(days: 1)))) {
      return "Yesterday";
    } else {
      return "${date.day} ${_monthName(date.month)} ${date.year}";
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  // -------- DATE SEPARATOR UI --------
  Widget dateSeparator(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    return Consumer<Chatprovider>(
      builder: (context, chat, _) {
        if (chat.chatroomId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<QuerySnapshot>(
          stream: chat.messagesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No messages",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final messages = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['senderId'] == myId;

                final Timestamp? ts = msg['timestamp'];
                final DateTime? currentDate =
                ts != null ? ts.toDate() : null;

                bool showDate = false;

                if (index == 0 && currentDate != null) {
                  showDate = true;
                } else if (index > 0 && currentDate != null) {
                  final prevMsg = messages[index - 1];
                  final Timestamp? prevTs = prevMsg['timestamp'];

                  if (prevTs != null) {
                    final prevDate = prevTs.toDate();
                    if (!DateUtils.isSameDay(currentDate, prevDate)) {
                      showDate = true;
                    }
                  }
                }

                return Column(
                  children: [
                    // -------- DATE SEPARATOR --------
                    if (showDate && currentDate != null)
                      dateSeparator(dateLabel(currentDate)),

                    // -------- MESSAGE BUBBLE --------
                    Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.75,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade600
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft:
                            Radius.circular(isMe ? 14 : 0),
                            bottomRight:
                            Radius.circular(isMe ? 0 : 14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['text'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatTime(ts, context),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
