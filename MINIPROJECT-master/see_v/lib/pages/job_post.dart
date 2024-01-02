// ignore_for_file: avoid_print, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({Key? key}) : super(key: key);

  @override
  _JobPostingPageState createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<TextEditingController> _skillControllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Posting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Salary'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(labelText: 'Job Field'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              const Text('Required Skills:'),
              _buildSkillFields(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Implement job posting logic here
                  _postJob();
                },
                child: const Text('Post Job'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addSkillField,
                child: const Text('Add Skill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillFields() {
    return Column(
      children: _skillControllers
          .map(
            (controller) => Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Skill'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      _skillControllers.remove(controller);
                    });
                  },
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  void _addSkillField() {
    setState(() {
      _skillControllers.add(TextEditingController());
    });
  }

  void _postJob() async {
  try {
    // Access the entered values
    String jobTitle = _jobTitleController.text;
    String duration = _durationController.text;
    String salary = _salaryController.text;
    String field = _fieldController.text;
    String location = _locationController.text;
    List<String> skills = _skillControllers.map((controller) => controller.text).toList();

    // Get the current user (company) ID
    String companyId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Prepare data to be posted
    Map<String, dynamic> jobData = {
      'jobTitle': jobTitle,
      'duration': duration,
      'salary': salary,
      'field': field,
      'location': location,
      'skills': skills,
      'companyId': companyId,
    };

    // Post job data to Firestore
    await FirebaseFirestore.instance.collection('jobs').add(jobData);

    // Reset form after successful submission
    _resetForm();

    // Show success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Job posted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Error posting job: $e');
    // Handle error, show error message, etc.
  }
}

void _resetForm() {
  // Reset form fields to their initial state
  _jobTitleController.clear();
  _durationController.clear();
  _salaryController.clear();
  _fieldController.clear();
  _locationController.clear();
  for (var controller in _skillControllers) {
    controller.clear();
  }
}
}

void main() {
  runApp(
    const MaterialApp(
      home: JobPostingPage(),
    ),
  );
}
