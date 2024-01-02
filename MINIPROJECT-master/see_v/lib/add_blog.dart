// ignore_for_file: use_super_parameters, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddBlogPage extends StatelessWidget {
  const AddBlogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _subtitleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();

    Future<void> _addBlog() async {
      final User? user = _auth.currentUser;
      if (user != null) {
        final String userId = user.uid;
        final DateTime now = DateTime.now();

        await FirebaseFirestore.instance.collection('blogs').add({
          'userId': userId,
          'title': _titleController.text,
          'subtitle': _subtitleController.text,
          'content': _contentController.text,
          'timestamp': now, // Include a timestamp for sorting or other uses
        });

        // Clear the input fields after adding the blog
        _titleController.clear();
        _subtitleController.clear();
        _contentController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
        backgroundColor: Colors.blue, // Set the app bar color to blue
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Input Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Subtitle Input Field
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Blog Content Input Field
            TextFormField(
              controller: _contentController,
              maxLines: null, // Allows for multiline input
              decoration: const InputDecoration(
                labelText: 'Type your blog content...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Upload Button
            ElevatedButton(
              onPressed: _addBlog,
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AddBlogPage(),
  ));
}
