import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:the_admin_panal/auth/logi.dart';

import 'package:the_admin_panal/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyDfo9cqhRF8FufZE5jK4QYfvtSbUUJdNSU",
              authDomain: "thebrandsapp-fc8ae.firebaseapp.com",
              projectId: "thebrandsapp-fc8ae",
              storageBucket: "thebrandsapp-fc8ae.appspot.com",
              messagingSenderId: "375333230289",
              appId: "1:375333230289:web:1a0f67b686ba404eef97f0"));
    } catch (e) {
      print(e);
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
