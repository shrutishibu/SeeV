// ignore_for_file: unused_import, non_constant_identifier_names, avoid_types_as_parameter_names

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:see_v/firebase_options.dart';
import 'package:see_v/home_page.dart';
import 'package:see_v/pages/login.dart';
import 'package:see_v/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    if (kDebugMode) {
      print('User signed out');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error signing out: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page', signOut: signOut),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Future<void> Function() signOut;

  const MyHomePage({Key? key, required this.title, required this.signOut}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSplash) {
      return const SplashScreen();
    }
    return Login(
      signOut: widget.signOut,
      onLogout: () {
        // Handle logout logic here using the provided context if needed
      },
    );
  }
}

