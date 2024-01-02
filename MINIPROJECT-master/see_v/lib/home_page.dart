// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:see_v/blogs_page.dart';
import 'package:see_v/mycv_page.dart';
import 'package:see_v/pages/signup_page.dart';
import 'package:see_v/updationpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:see_v/view_jobs.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, String> getLoggedInUserInfo() {
    User? user = _auth.currentUser;
    if (user != null) {
      return {
        'first_name': user.displayName ?? '',
        'email': user.email ?? '',
      };
    } else {
      return {
        'first_name': '',
        'email': '',
      };
    }
  }
}

AuthService authService = AuthService();

class HomePage extends StatelessWidget {
  final void Function() signOut;

  const HomePage({Key? key, required this.signOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String> user = authService.getLoggedInUserInfo();

    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user['first_name']!),
              accountEmail: Text(user['email']!),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Update'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My CV'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResumesPage())
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Jobs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  // ignore: prefer_const_constructors
                  MaterialPageRoute(builder: (context) => const JobViewPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Blogs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlogsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                  // Navigate to e_login.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage())
                    );
                },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.0),
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'SEEV',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'An innovative AI tool to step up your career game.',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'A web application that allows you to generate a professional CV that is personalized according to job preferences and acts as a guiding light throughout the process of seeking a job',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 800.0,
                      child: Image.asset(
                        'assets/homeimage.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
