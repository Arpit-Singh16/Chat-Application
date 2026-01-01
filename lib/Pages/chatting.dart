  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  import '../Providers/Chatprovider.dart';

  class Chatting extends StatefulWidget {
    final String receivername;
    final String receiverId;

    const Chatting( {super.key, required this.receivername, required this.receiverId});

    @override
    State<Chatting> createState() => _ChattingState();
  }

  class _ChattingState extends State<Chatting> {
    String? senderId;
    String? receiverId;
    final textcontroller=TextEditingController();

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
       appBar: AppBar(
         leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color:Colors.white,)),
         title: Row(
           children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
           SizedBox(width: 5,),
           Text("${widget.receivername}",style:TextStyle(fontSize: 20,color: Colors.white),),
           ],
         ),
         backgroundColor: Colors.black,
       ),

        body:  Consumer<Chatprovider>(
          builder:(context, chat , child){
            /// 🔥 SAFETY CHECK (VERY IMPORTANT)
            if (chat.chatroomId == null) {
              return const Center(child: CircularProgressIndicator());
            }
          return Column(
              children: [
              // takes all remaining space
                Expanded(
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
                        return const Center(child: Text("No messages"));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final msg = snapshot.data!.docs[index];
                          final isMe = msg['senderId'] == myId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Text(
                                msg['text'],
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ),

              // bottom textfield
              SafeArea(
              child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
          controller: textcontroller,
              decoration: InputDecoration(
          prefixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions_outlined),
          ),
              hintText: "Type message",
              suffixIcon:IconButton(
              onPressed: () {
                final text = textcontroller.text.trim();
                if (text.isEmpty) return;

                chat.sendmessages(text);
                textcontroller.clear();
              },
              icon: const Icon(Icons.send),
              ),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              ),
              ),
              ),

              ),
              ),

              ],
              );}
        ),

      );
    }
  }
