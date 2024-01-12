import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:the_admin_panal/auth/logi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
        apiKey: 'AIzaSyA-N4HCPW-QSwTY6gAb-Oa_-VpcJ0fe_zc',
        appId: '1:985158664091:web:e57c3ee75b900762b42b3e',
        messagingSenderId: '985158664091',
        projectId: 'spotfinder-a7e90',
        authDomain: 'spotfinder-a7e90.firebaseapp.com',
        storageBucket: 'spotfinder-a7e90.appspot.com',
      ));
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
