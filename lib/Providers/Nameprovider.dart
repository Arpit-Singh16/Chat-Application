import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class dataprovider extends ChangeNotifier {
  var name;
  var phone;
  List<Map<String,dynamic>> contacts=[];

//  // void data(userid) async{
//  //    await FirebaseFirestore.instance.collection('Data').doc(userid).set({
//  //      'Name' = name,
//  //      'Phone' = phone,
//  //    } as Map<String, dynamic>);
//  //  }


Future<String?> getId(String phone) async{
  QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').where('phone',isEqualTo: phone).get();

  if(snap.docs.isEmpty)return null ;

  return snap.docs.first['Uid'];
}

Future<void> addcontact(String name , String phonenumber) async {
  User? user= FirebaseAuth.instance.currentUser;
   var receiverId= await getId(phonenumber);
     var cont= await FirebaseFirestore.instance.collection('Contacts').doc(user!.uid).collection('contacts').add({
       'name': name,
       'phone': phonenumber,
       'receiverId': receiverId,
     });

   await  fetchcontact();
    }


Future<void> fetchcontact() async{
  User? user= FirebaseAuth.instance.currentUser;
  var cont= await FirebaseFirestore.instance.collection('Contacts').doc(user!.uid).collection('contacts').get();
  contacts.clear();
 for( var con in cont.docs){
   contacts.add(con.data() as Map<String, dynamic>);

 }
 notifyListeners();
}
//
//   void addchat(userid,reciverid) async{
//     var add= await FirebaseFirestore.instance.collection('chat').doc(userid).collection('pchat').doc(reciverid).set({
//       'user'=[
//         3
//       ]
//     } as Map<String, dynamic>);
//   }
//
 }
