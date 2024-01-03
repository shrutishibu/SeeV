// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:see_v/add_blog.dart';

class BlogsPage extends StatelessWidget {
  const BlogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeeV'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ADD YOUR BLOGS!'),
                      content: const Text('Only registered users'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddBlogPage(),
                              ),
                            );
                          },
                          child: const Text('Create'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final blogData = document.data() as Map<String, dynamic>;
              final userId = blogData['userId'];

              return FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const Text('Error');
                  }

                  final userEmail = userSnapshot.data!['email'];

                  return Card(
                    child: ListTile(
                      title: Text(blogData['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(blogData['subtitle']),
                          ElevatedButton(
                            onPressed: () {
                              _showReadMoreDialog(context, blogData, userEmail);
                            },
                            child: const Text('Read More'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showReadMoreDialog(BuildContext context, Map<String, dynamic> blogData, String userEmail) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          blogData['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blogData['subtitle'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(blogData['content']),
              Text('By $userEmail'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void main() {
  runApp(const MaterialApp(
    home: BlogsPage(),
  ));
}
}