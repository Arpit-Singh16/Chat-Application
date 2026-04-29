import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chatprovider extends ChangeNotifier{


 final senderId=FirebaseAuth.instance.currentUser!.uid;
 String? receiverId;
 String? chatroomId;

void initChat(String receiverUid){

  receiverId= receiverUid;

  chatroomId = senderId!.compareTo(receiverId!)<0
  ?'$senderId\_$receiverId':
      '$receiverId\_$senderId';

print(chatroomId);
  notifyListeners();
}

Future<void> sendmessages(String text, {DateTime? scheduledTime}) async {
  final isScheduled = scheduledTime != null;
  final docRef = FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').doc();

  await docRef.set({
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'timestamp': isScheduled ? Timestamp.fromDate(scheduledTime) : FieldValue.serverTimestamp(),
    if (isScheduled) 'scheduledFor': Timestamp.fromDate(scheduledTime),
  });

  await FirebaseFirestore.instance.collection('chats').doc(chatroomId).set({
    'lastMessage': text,
    'lastMessageTime': isScheduled ? Timestamp.fromDate(scheduledTime) : FieldValue.serverTimestamp(),
    'lastSenderId': senderId,
    'participants': [senderId, receiverId]
  }, SetOptions(merge: true));

  if (receiverId == 'AI_ASSISTANT' && !isScheduled) {
    _handleAIResponse(text);
  }
}

Future<void> _handleAIResponse(String userText) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    
    if (apiKey.isEmpty) {
      await _sendAIMessage("Please configure your Gemini API Key in Settings.");
      return;
    }
    
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final response = await model.generateContent([Content.text(userText)]);
    
    if (response.text != null) {
      await _sendAIMessage(response.text!);
    }
  } catch (e) {
    await _sendAIMessage("Error: ${e.toString()}");
  }
}

Future<void> _sendAIMessage(String text) async {
  await FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').add({
    'senderId': 'AI_ASSISTANT',
    'receiverId': senderId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
  });
  
  await FirebaseFirestore.instance.collection('chats').doc(chatroomId).set({
    'lastMessage': text,
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastSenderId': 'AI_ASSISTANT',
    'participants': [senderId, 'AI_ASSISTANT']
  }, SetOptions(merge: true));
}

Future<String?> summarizeChat() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    if (apiKey.isEmpty) return "Please configure your Gemini API Key in Settings.";

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();

    if (snapshot.docs.isEmpty) return "No messages to summarize.";

    final List<String> lines = [];
    for (var doc in snapshot.docs.reversed) {
      final text = doc.data().containsKey('text') ? doc['text'] : '';
      if (text.toString().isEmpty) continue;
      final isMe = doc['senderId'] == senderId;
      lines.add("${isMe ? 'Me' : 'Other'}: $text");
    }

    final prompt = "Please summarize this conversation snippet in a few short concise bullet points:\n\n${lines.join('\n')}";
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  } catch (e) {
    return "Error generating summary: $e";
  }
}

Stream<QuerySnapshot> get lastmessage{
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants',arrayContains:senderId)
      .snapshots();
}

Stream<QuerySnapshot> get messagesStream {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatroomId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots();
}


}