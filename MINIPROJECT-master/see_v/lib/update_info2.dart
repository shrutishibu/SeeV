// ignore_for_file: avoid_print, use_key_in_widget_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const UpdateInfo2());
}

class UpdateInfo2 extends StatelessWidget {
  const UpdateInfo2({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdateInfoPage(),
    );
  }
}

class ExperienceDetailsWidget extends StatelessWidget {
  final TextEditingController institutionController;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final TextEditingController courseController;
  final List<TextEditingController> skillsControllers;

  const ExperienceDetailsWidget({
    required this.institutionController,
    required this.fromDateController,
    required this.toDateController,
    required this.courseController,
    required this.skillsControllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter Details',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        TextField(
          controller: institutionController,
          decoration: const InputDecoration(labelText: 'Name of Institution'),
        ),
        TextField(
          controller: fromDateController,
          decoration: const InputDecoration(labelText: '(From) Date'),
        ),
        TextField(
          controller: toDateController,
          decoration: const InputDecoration(labelText: '(To) Date'),
        ),
        TextField(
          controller: courseController,
          decoration: const InputDecoration(labelText: 'Job position'),
        ),
        const SizedBox(height: 10.0),
        for (int i = 0; i < skillsControllers.length; i++)
          TextField(
            controller: skillsControllers[i],
            decoration: InputDecoration(labelText: 'Skill ${i + 1}'),
          ),
        const SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: () {
            _addSkillField(context);
          },
          child: const Text('Add Skill'),
        ),
      ],
    );
  }

  void _addSkillField(BuildContext context) {
    // Create a new TextEditingController for the new skill field
    final TextEditingController newSkillController = TextEditingController();

    // Add the new controller to the list
    skillsControllers.add(newSkillController);

    // Rebuild the widget to reflect the changes
    // This is necessary to update the UI with the new skill field
    (context as Element).markNeedsBuild();
  }
}

class UpdateInfoPage extends StatefulWidget {
  const UpdateInfoPage({Key? key}) : super(key: key);

  @override
  _UpdateInfoPageState createState() => _UpdateInfoPageState();
}

class _UpdateInfoPageState extends State<UpdateInfoPage> {
  List<ExperienceDetailsWidget> experienceWidgets = [
    ExperienceDetailsWidget(
      institutionController: TextEditingController(),
      fromDateController: TextEditingController(),
      toDateController: TextEditingController(),
      courseController: TextEditingController(),
      skillsControllers: [TextEditingController()],
    )
  ];

  late String loggedInUserId;

  // Stream controller for live updates
  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    // Fetch the logged-in user's ID when the widget initializes
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      loggedInUserId = user.uid;
    } else {
      // Handle the case when the user is not logged in
      loggedInUserId = '';
    }

    // Initialize the stream with the initial data
    _controller.add([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Info'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                const Text(
                  'EXPERIENCE:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Column(
                  children: experienceWidgets,
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    _updateExperienceDetails();
                  },
                  child: const Text('Update Information'),
                ),
                const SizedBox(height: 20.0),
                _buildExperienceDataTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateExperienceDetails() async {
    try {
      for (int i = 0; i < experienceWidgets.length; i++) {
        final String institution = experienceWidgets[i].institutionController.text.trim();
        final String fromDate = experienceWidgets[i].fromDateController.text.trim();
        final String toDate = experienceWidgets[i].toDateController.text.trim();
        final String jobPosition = experienceWidgets[i].courseController.text.trim();
        final List<String> skills = [];

        for (int j = 0; j < experienceWidgets[i].skillsControllers.length; j++) {
          final String skill = experienceWidgets[i].skillsControllers[j].text.trim();
          if (skill.isNotEmpty) {
            skills.add(skill);
          }
        }

        // Add the experience details to Firestore
        await FirebaseFirestore.instance.collection('experience').add({
          'userId': loggedInUserId,
          'institution': institution,
          'fromDate': fromDate,
          'toDate': toDate,
          'jobPosition': jobPosition,
          'skills': skills,
        });

        // Update the skills data in Firestore
        for (String skill in skills) {
          final QuerySnapshot skillQuery = await FirebaseFirestore.instance
              .collection('skills')
              .where('userId', isEqualTo: loggedInUserId)
              .where('name', isEqualTo: skill)
              .get();

          if (skillQuery.docs.isEmpty) {
            await FirebaseFirestore.instance.collection('skills').add({
              'userId': loggedInUserId,
              'name': skill,
              'level': 'Intermediate',
            });
          }
        }
      }

      // Fetch and update the experience data in the stream
      _fetchExperienceData();

      _showDialog('Update Successful', 'Information updated successfully.');
    } catch (e) {
      print('Error updating experience details: $e');
      _showDialog('Error', 'Failed to update information. Please try again.');
    }
  }

  Future<void> _fetchExperienceData() async {
    // Fetch experience data from Firestore and add it to the stream
    final experienceData = await FirebaseFirestore.instance
        .collection('experience')
        .where('userId', isEqualTo: loggedInUserId)
        .get();

    _controller.add(experienceData.docs);
  }

  Widget _buildExperienceDataTable() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final experienceData = snapshot.data ?? [];
          if (experienceData.isEmpty) {
            return const Text('No experience details added yet.');
          } else {
            return DataTable(
              columns: const [
                DataColumn(label: Text('Sno')),
                DataColumn(label: Text('Institution')),
                DataColumn(label: Text('From Date')),
                DataColumn(label: Text('To Date')),
                DataColumn(label: Text('Job Position')),
                DataColumn(label: Text('Skills')),
              ],
              rows: List<DataRow>.generate(
                experienceData.length,
                (index) {
                  final experience = experienceData[index].data() as Map<String, dynamic>;
                  final institution = experience['institution'];
                  final fromDate = experience['fromDate'];
                  final toDate = experience['toDate'];
                  final jobPosition = experience['jobPosition'];
                  final skills = (experience['skills'] as List<dynamic>).join(', ');

                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(institution ?? '')),
                      DataCell(Text(fromDate ?? '')),
                      DataCell(Text(toDate ?? '')),
                      DataCell(Text(jobPosition ?? '')),
                      DataCell(Text(skills)),
                    ],
                  );
                },
              ),
            );
          }
        }
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
