// ignore_for_file: unused_local_variable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const UpdateInfo4());
}

class UpdateInfo4 extends StatelessWidget {
  const UpdateInfo4({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdateInfoPage(),
    );
  }
}

class CourseDetailsWidget extends StatefulWidget {
  final TextEditingController courseNameController;
  final List<TextEditingController> skillsControllers;

  const CourseDetailsWidget({
    super.key,
    required this.courseNameController,
    required this.skillsControllers, required TextEditingController institutionController,
  });

  @override
  _CourseDetailsWidgetState createState() => _CourseDetailsWidgetState();
}

class _CourseDetailsWidgetState extends State<CourseDetailsWidget> {
  void _addSkillField() {
    final TextEditingController newSkillController = TextEditingController();
    widget.skillsControllers.add(newSkillController);
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
          controller: widget.courseNameController,
          decoration: const InputDecoration(labelText: 'Course Name'),
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
  const UpdateInfoPage({super.key});

  @override
  _UpdateInfoPageState createState() => _UpdateInfoPageState();
}

class _UpdateInfoPageState extends State<UpdateInfoPage> {
  String loggedInUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<CourseDetailsWidget> courses = [
    CourseDetailsWidget(
      courseNameController: TextEditingController(),
      institutionController: TextEditingController(),
      skillsControllers: [TextEditingController()],
    ),
  ];

  // Declare the uniqueSkills set
  Set<String> uniqueSkills = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Info'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: SizedBox(
          width: 80.0 * MediaQuery.of(context).size.width / 100.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'COURSES',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Column(
                      children: courses,
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        await addCoursesToFirestore();
                        _showDialog('Update Successful', 'Information updated successfully.');
                        clearTextControllers();
                        _fetchCourseData();
                        _updateSkills();
                      },
                      child: const Text('Update Information'),
                    ),
                    const SizedBox(height: 30.0),
                    const Text(
                      'COURSES LIST',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _buildCoursesTable(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('userId', isEqualTo: loggedInUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final coursesData = snapshot.data!.docs;
          if (coursesData.isNotEmpty) {
            return DataTable(
              columns: const [
                DataColumn(label: Text('Course Name')),
                DataColumn(label: Text('Skills')),
              ],
              rows: coursesData.map((course) {
                final courseData = course.data() as Map<String, dynamic>;
                final courseName = courseData['courseName'];
                final skills = (courseData['skills'] as List<dynamic>).join(', ');

                return DataRow(
                  cells: [
                    DataCell(Text(courseName ?? '')),
                    DataCell(Text(skills)),
                  ],
                );
              }).toList(),
            );
          } else {
            return const Text('No courses added yet.');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> addCoursesToFirestore() async {
    final CollectionReference coursesCollection = FirebaseFirestore.instance.collection('courses');

    for (var courseWidget in courses) {
      final skills = courseWidget.skillsControllers.map((controller) => controller.text).toList();

      await _updateSkillsInFirestore(skills);

      await coursesCollection.add({
        'userId': loggedInUserId,
        'courseName': courseWidget.courseNameController.text,
        'skills': skills,
      });
    }
  }

  Future<void> _updateSkillsInFirestore(List<String> skills) async {
  for (String skill in skills) {
    // Check if the skill is already encountered and not an empty string
    if (skill.isNotEmpty && !uniqueSkills.contains(skill)) {
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

      // Add the skill to the uniqueSkills set
      uniqueSkills.add(skill);
    }
  }
}

  Future<void> _fetchCourseData() async {
    // Fetch course data from Firestore and update the state
    setState(() {});
  }

  Future<void> _updateSkills() async {
    for (var courseWidget in courses) {
      final skills = courseWidget.skillsControllers.map((controller) => controller.text).toList();
      await _updateSkillsInFirestore(skills);
    }

    // Clear the uniqueSkills set after processing all skills for the current update
    uniqueSkills.clear();
  }

  void clearTextControllers() {
    for (var courseWidget in courses) {
      courseWidget.courseNameController.clear();
      for (var skillController in courseWidget.skillsControllers) {
        skillController.clear();
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
