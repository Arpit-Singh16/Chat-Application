import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

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

Future<void> sendmessages(String text) async{
  await FirebaseFirestore.instance.collection('chats').doc(chatroomId).collection('messages').add({
    'senderId': senderId,
    'receiverId':receiverId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp()
  });
  await FirebaseFirestore.instance.collection('chats').doc(chatroomId).set({
    'lastMessage': text,
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastSenderId': senderId,
    'participants':[senderId,receiverId]
  },SetOptions(merge: true))                  ;
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