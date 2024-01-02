// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResumesPage extends StatefulWidget {
  const ResumesPage({Key? key}) : super(key: key);

  @override
  _ResumesPageState createState() => _ResumesPageState();
}

class _ResumesPageState extends State<ResumesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;
  List<DocumentSnapshot>? _userResumes;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _fetchUserResumes();
      });
    }
  }

  Future<void> _fetchUserResumes() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('resumes')
        .where('userId', isEqualTo: _currentUser!.uid)
        .get();

    setState(() {
      _userResumes = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Resumes'),
      ),
      body: _userResumes != null
          ? ListView.builder(
              itemCount: _userResumes!.length,
              itemBuilder: (context, index) {
                final resumeData = _userResumes![index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(resumeData['name'] ?? 'Resume ${index + 1}'),
                  onTap: () {
                    _viewResume(resumeData);
                  },
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void _viewResume(Map<String, dynamic> resumeData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selected Resume'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResumeSection('Name', resumeData['name'] ?? 'Unknown'),
                _buildResumeSection('Phone', resumeData['phone'] ?? 'Unknown'),
                _buildResumeSection('Email', resumeData['email'] ?? 'Unknown'),
                _buildResumeSection('GitHub', resumeData['github'] ?? 'Unknown'),
                _buildResumeSection('LinkedIn', resumeData['linkedin'] ?? 'Unknown'),
                _buildResumeSection('Education', _getListAsString(resumeData['education'])),
                _buildResumeSection('Experiences', _getListAsString(resumeData['experiences'])),
                _buildResumeSection('Projects', _getListAsString(resumeData['projects'])),
                _buildResumeSection('Skills', _getListAsString(resumeData['skills'])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResumeSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Text(content),
        const SizedBox(height: 16.0),
      ],
    );
  }

  String _getListAsString(List<dynamic>? list) {
    if (list != null && list.isNotEmpty) {
      return list.join(', ');
    } else {
      return 'Unknown';
    }
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: ResumesPage(),
    ),
  );
}
