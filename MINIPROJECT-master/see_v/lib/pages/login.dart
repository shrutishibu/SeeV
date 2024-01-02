// ignore_for_file: use_super_parameters, use_build_context_synchronously, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:see_v/e_login.dart';
import 'package:see_v/forgot_password.dart';
import 'package:see_v/home_page.dart';
import 'package:see_v/pages/signup_page.dart';
import 'package:see_v/blogs_page.dart';

class Login extends StatefulWidget {
  final Future<void> Function() signOut;
  final Function() onLogout; // Add callback function

  const Login({Key? key, required this.signOut, required this.onLogout}) : super(key: key);

  @override
  State<Login> createState() => _InstaLoginState();
}

class _InstaLoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await _checkUserRole(userCredential.user?.uid);

        // Navigate to the home page or perform other actions after successful login
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed. Please check your credentials.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  Future<void> _checkUserRole(String? userId) async {
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        String userRole = userSnapshot.get('role');
        if (userRole != 'registered_user') {
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You do not have the required role to log in.'),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage(signOut: widget.signOut)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: _centerWidget(),
              ),
              Flexible(child: Container(), flex: 2),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the current page (Login)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BlogsPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 156, 156, 210),
                ),
                child: const Text(
                  'Want to try the website without signing up? Click here',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 37, 17, 220)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
              style: const TextStyle(color: Colors.blue),
              decoration: const InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              style: const TextStyle(color: Colors.blue),
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 235, 237, 239),
                  backgroundColor: const Color.fromARGB(255, 134, 149, 235),
                ),
                child: const Text('Log in', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Flexible(child: Divider(thickness: 2, color: Colors.transparent)),
                Text(
                  ' OR ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                ),
                Flexible(child: Divider(thickness: 2, color: Color.fromARGB(0, 236, 171, 171))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Small button "For Employers"
                TextButton(
                  onPressed: () {
                    // Navigate to e_login.dart
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ELogin()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 37, 17, 220),
                  ),
                  child: const Text(
                    'For Employers',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 235, 237, 239),
                      backgroundColor: const Color.fromARGB(255, 134, 149, 235),
                    ),
                    child: const Text('Sign up', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
