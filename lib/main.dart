import 'package:chat/Pages/Login.dart';
import 'package:chat/Pages/Splash%20page.dart';
import 'package:chat/Pages/homeppage.dart';
import 'package:chat/Providers/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/Register.dart';
import 'package:provider/provider.dart';

import 'Providers/Chatprovider.dart';
import 'Providers/Nameprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 1
  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => profileprovider(),),
        ChangeNotifierProvider(create: (_) => dataprovider(),),
  ChangeNotifierProvider(create: (_) => Chatprovider(),)
      ],
      child:  MyApp()));
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashPage(),
    );
  }
}
