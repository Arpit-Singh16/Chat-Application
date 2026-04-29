import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/Chatprovider.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key});

  // -------- TIME FORMAT --------
  String formatTime(Timestamp? timestamp, BuildContext context) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate().toLocal();
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }

  // -------- DATE LABEL --------
  String dateLabel(DateTime date) {
    final now = DateTime.now();

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

  // -------- DATE SEPARATOR --------
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
          stream: chat.messagesStream, // must be orderBy timestamp ASC
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final messages = snapshot.data!.docs;

            if (messages.isEmpty) {
              return const Center(
                child: Text(
                  "No messages",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final actualIndex = messages.length - 1 - index;
                final msg = messages[actualIndex];
                final msgData = msg.data() as Map<String, dynamic>;

                final isMe = msgData['senderId'] == myId;

                final isScheduled = msgData.containsKey('scheduledFor');
                bool isPending = false;
                if (isScheduled) {
                  final scheduledFor = (msgData['scheduledFor'] as Timestamp).toDate();
                  if (scheduledFor.isAfter(DateTime.now())) {
                    if (!isMe) {
                      return const SizedBox.shrink(); // hide from receiver
                    }
                    isPending = true;
                  }
                }

                final Timestamp? ts = msgData['timestamp'];
                final DateTime? currentDate =
                ts != null ? ts.toDate().toLocal() : null;

                if (currentDate == null) {
                  return const SizedBox.shrink();
                }

                bool showDate = false;

                if (actualIndex == 0) {
                  showDate = true;
                } else {
                  final prevMsg = messages[actualIndex - 1];
                  final prevMsgData = prevMsg.data() as Map<String, dynamic>;
                  final Timestamp? prevTs = prevMsgData['timestamp'];

                  if (prevTs != null) {
                    final prevDate = prevTs.toDate().toLocal();
                    showDate =
                    !DateUtils.isSameDay(currentDate, prevDate);
                  }
                }

                return Column(
                  children: [
                    if (showDate)
                      dateSeparator(dateLabel(currentDate)),

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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPending)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4.0),
                                    child: Icon(Icons.schedule, color: Colors.white54, size: 12),
                                  ),
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
