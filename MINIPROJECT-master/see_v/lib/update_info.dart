// ignore_for_file: avoid_print, use_super_parameters, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth auth = FirebaseAuth.instance;

void main() {
  runApp(const UpdateInfo());
}

class UpdateInfo extends StatelessWidget {
  const UpdateInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdateInfoPage(),
    );
  }
}

class UpdateInfoPage extends StatefulWidget {
  const UpdateInfoPage({Key? key}) : super(key: key);

  @override
  _UpdateInfoPageState createState() => _UpdateInfoPageState();
}

class _UpdateInfoPageState extends State<UpdateInfoPage> {
  List<TextEditingController> skillControllers = [TextEditingController()];
  List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];
  List<String?> selectedLevels = ['Beginner'];
  String? loggedInUserId; // Add a variable to store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    // Fetch the logged-in user's ID when the widget initializes
    User? user = auth.currentUser;
    if (user != null) {
      loggedInUserId = user.uid;
    } else {
      _showErrorDialog('Error. Cannot update information.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skills:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Column(
                  children: List.generate(
                    skillControllers.length,
                    (index) => Column(
                      children: [
                        TextField(
                          controller: skillControllers[index],
                          decoration: const InputDecoration(
                            hintText: 'Skill',
                            labelText: 'Skill',
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        DropdownButton<String>(
                          value: selectedLevels[index],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedLevels[index] = newValue!;
                            });
                          },
                          items: skillLevels.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSkills();
                    _showSuccessDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Update Information',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: UserSkillsTable(loggedInUserId: loggedInUserId), // Pass the user identifier
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateSkills() async {
    bool skillAdded = false;

    try {
      final CollectionReference skillsCollection = FirebaseFirestore.instance.collection('skills');

      for (int i = 0; i < skillControllers.length; i++) {
        final String skillName = skillControllers[i].text.trim();
        final String skillLevel = selectedLevels[i] ?? 'Beginner';

        if (skillName.isNotEmpty) {
          await skillsCollection.add({
            'userId': loggedInUserId, // Include the user identifier
            'name': skillName,
            'level': skillLevel,
          });
          skillAdded = true;
        }
      }

      if (!skillAdded) {
        _showErrorDialog('Please add at least one skill.');
      }
    } catch (e) {
      print('Error updating skills: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Successful'),
          content: const Text('Information updated successfully.'),
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

class UserSkillsTable extends StatelessWidget {
  final String? loggedInUserId; // Add a variable to receive the user identifier

  const UserSkillsTable({Key? key, required this.loggedInUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Fetch user skills from Firestore for the specific user in real-time
      stream: FirebaseFirestore.instance
          .collection('skills')
          .where('userId', isEqualTo: loggedInUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final skills = snapshot.data?.docs;
          if (skills == null || skills.isEmpty) {
            return const Text('No skills added yet.');
          } else {
            return DataTable(
              columns: const [
                DataColumn(label: Text('Sno')),
                DataColumn(label: Text('Skill')),
                DataColumn(label: Text('Level')),
              ],
              rows: List<DataRow>.generate(
                skills.length,
                (index) {
                  final skill = skills[index].data() as Map<String, dynamic>;
                  final skillName = skill['name'];
                  final skillLevel = skill['level'];

                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(skillName)),
                      DataCell(Text(skillLevel)),
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
}
