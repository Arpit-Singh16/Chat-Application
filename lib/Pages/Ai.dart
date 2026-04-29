import 'package:chat/Customs/MessageBUbble.dart';
import 'package:chat/Providers/Chatprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Aipage extends StatelessWidget {
  const Aipage({super.key});

  @override
  Widget build(BuildContext context) {
    var messagecontroller=TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Ai Chat"),
        centerTitle: true,
      ),
      body:SafeArea(child: SingleChildScrollView(
        child: Consumer<Chatprovider>(
          builder: (ctx,chat,_){
          return Column(
            children: [
              Expanded(child: MessageBubble()),
              //input bar;
              TextField(
                controller: messagecontroller,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(
                      color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            ],
          );}
        ),
      )),
    );
  }
}
