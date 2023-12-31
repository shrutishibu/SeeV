import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const UpdateInfo3());
}

class UpdateInfo3 extends StatelessWidget {
  const UpdateInfo3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdateInfoPage(),
    );
  }
}

class ProjectDetailsWidget extends StatefulWidget {
  final TextEditingController projectNameController;
  final TextEditingController descriptionController;
  final List<TextEditingController> skillsControllers;

  const ProjectDetailsWidget({
    Key? key,
    required this.projectNameController,
    required this.descriptionController,
    required this.skillsControllers,
  }) : super(key: key);

  @override
  _ProjectDetailsWidgetState createState() => _ProjectDetailsWidgetState();
}

class _ProjectDetailsWidgetState extends State<ProjectDetailsWidget> {
  void _addSkillField() {
    // Create a new TextEditingController for the new skill field
    final TextEditingController newSkillController = TextEditingController();

    // Add the new controller to the list
    widget.skillsControllers.add(newSkillController);

    // Rebuild the widget to reflect the changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter Details',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: widget.projectNameController,
          decoration: const InputDecoration(labelText: 'Project Name'),
        ),
        TextField(
          controller: widget.descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        for (int i = 0; i < widget.skillsControllers.length; i++)
          TextField(
            controller: widget.skillsControllers[i],
            decoration: InputDecoration(labelText: 'Skill ${i + 1}'),
          ),
        const SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: _addSkillField,
          child: const Text('Add Skill'),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }
}

class UpdateInfoPage extends StatefulWidget {
  const UpdateInfoPage({Key? key}) : super(key: key);

  @override
  _UpdateInfoPageState createState() => _UpdateInfoPageState();
}

class _UpdateInfoPageState extends State<UpdateInfoPage> {
  late String loggedInUserId;

  // Stream controller for live updates
  final StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();

  List<ProjectDetailsWidget> projectDetailsWidgets = [
    ProjectDetailsWidget(
      projectNameController: TextEditingController(),
      descriptionController: TextEditingController(),
      skillsControllers: [TextEditingController()],
    )
  ];

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

    // Fetch and update the project data in the stream
    _fetchProjectData();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Update Info'),
      backgroundColor: Colors.lightBlue,
      elevation: 0, // Remove elevation
    ),
    body: Center(
      child: Container(
        width: 80.0 * MediaQuery.of(context).size.width / 100.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROJECTS:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    for (var projectWidget in projectDetailsWidgets)
                      ProjectDetailsWidget(
                        projectNameController: projectWidget.projectNameController,
                        descriptionController: projectWidget.descriptionController,
                        skillsControllers: projectWidget.skillsControllers,
                      ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Add project details to Firestore
                        await addProjectsToFirestore();

                        // Show success dialog
                        _showDialog('Update Successful', 'Information updated successfully.');

                        // Clear the text controllers
                        for (var projectWidget in projectDetailsWidgets) {
                          projectWidget.projectNameController.clear();
                          projectWidget.descriptionController.clear();
                          for (var skillController in projectWidget.skillsControllers) {
                            skillController.clear();
                          }
                        }

                        // Re-fetch and update the project data in the stream
                        _fetchProjectData();
                      },
                      child: const Text('Update Information'),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
              _buildProjectDataTable(), // Move this outside the inner Column
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildProjectDataTable() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final projectData = snapshot.data ?? [];
          if (projectData.isEmpty) {
            return const Text('No project details added yet.');
          } else {
            return DataTable(
              columns: const [
                DataColumn(label: Text('Project Name')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Skills')),
              ],
              rows: List<DataRow>.generate(
                projectData.length,
                (index) {
                  final project = projectData[index].data() as Map<String, dynamic>;
                  final projectName = project['projectName'];
                  final description = project['description'];
                  final skills = (project['skills'] as List<dynamic>).join(', ');

                  return DataRow(
                    cells: [
                      DataCell(Text(projectName ?? '')),
                      DataCell(Text(description ?? '')),
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

  Future<void> _fetchProjectData() async {
    // Fetch project data from Firestore and add it to the stream
    final projectData = await FirebaseFirestore.instance
        .collection('projects')
        .where('userId', isEqualTo: loggedInUserId)
        .get();

    _controller.add(projectData.docs);
  }

  Future<void> addProjectsToFirestore() async {
    // Assuming you have a Firestore collection named 'projects'
    // Replace with your actual Firestore implementation
    final CollectionReference projectsCollection = FirebaseFirestore.instance.collection('projects');

    for (var projectWidget in projectDetailsWidgets) {
      // Add project details to Firestore
      final skills = projectWidget.skillsControllers.map((controller) => controller.text).toList();

      // Update skills in Firestore (add only if not present)
      await _updateSkillsInFirestore(skills);

      // Add project details to Firestore
      await projectsCollection.add({
        'userId': loggedInUserId,
        'projectName': projectWidget.projectNameController.text,
        'description': projectWidget.descriptionController.text,
        'skills': skills,
      });
    }
  }

  Future<void> _updateSkillsInFirestore(List<String> skills) async {
    for (var skill in skills) {
      final QuerySnapshot skillQuery = await FirebaseFirestore.instance
          .collection('skills')
          .where('userId', isEqualTo: loggedInUserId)
          .where('name', isEqualTo: skill)
          .get();

      if (skillQuery.docs.isEmpty) {
        // Skill not present, add to Firestore
        await FirebaseFirestore.instance.collection('skills').add({
          'userId': loggedInUserId,
          'name': skill,
          'level': 'Intermediate',
        });
      }
    }
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
