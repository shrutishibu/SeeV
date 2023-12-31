// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EducationDetailsWidget extends StatefulWidget {
  const EducationDetailsWidget({Key? key, required this.loggedInUserId}) : super(key: key);

  final String loggedInUserId;

  @override
  _EducationDetailsWidgetState createState() => _EducationDetailsWidgetState();

  updateEducationDetails(BuildContext context) {}
}

class _EducationDetailsWidgetState extends State<EducationDetailsWidget> {
  final TextEditingController _institutionController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _percentageController = TextEditingController();
  String _educationLevel = 'Primary school'; // Default value
  final TextEditingController _courseController = TextEditingController();

  late Stream<List<DocumentSnapshot>> _educationDataStream;

  @override
  void initState() {
    super.initState();
    // Fetch education data for the logged-in user
    _educationDataStream = FirebaseFirestore.instance
        .collection('education')
        .where('userId', isEqualTo: widget.loggedInUserId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  Future<void> updateEducationDetails(BuildContext context) async {
    final String institution = _institutionController.text;
    final String fromDateValue = _fromDate?.toString() ?? '';
    final String toDateValue = _toDate?.toString() ?? '';
    final String percentage = _percentageController.text;
    final String educationLevel = _educationLevel;
    final String course = _courseController.text;

    try {
      final CollectionReference educationCollection =
          FirebaseFirestore.instance.collection('education');

      await educationCollection.add({
        'userId': widget.loggedInUserId,
        'institution': institution,
        'fromDate': fromDateValue,
        'toDate': toDateValue,
        'percentage': percentage,
        'educationLevel': educationLevel,
        'course': course,
      });

      _showDialog(context, 'Update Successful', 'Information updated successfully.');
    } catch (e) {
      print('Error updating education details: $e');
      _showDialog(context, 'Error', 'Failed to update information. Please try again.');
    }
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = selectedDate;
        } else {
          _toDate = selectedDate;
        }
      });
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _institutionController,
            decoration: const InputDecoration(labelText: 'Institution'),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(true),
                child: const Text('From Date'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _selectDate(false),
                child: const Text('To Date'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _percentageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Percentage'),
          ),
          const SizedBox(height: 10.0),
          DropdownButton<String>(
            value: _educationLevel,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _educationLevel = newValue;
                });
              }
            },
            items: <String>[
              'Primary school',
              'High school',
              'Undergraduate',
              'Post graduate'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            isExpanded: true,
            hint: const Text('Education Level'),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(labelText: 'Course Taken'),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              await updateEducationDetails(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Update Information'),
          ),
          const SizedBox(height: 20.0),
          // Display existing education data in a table
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _educationDataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final educationData = snapshot.data;

                if (educationData == null || educationData.isEmpty) {
                  return const Text('No educational history provided yet.');
                }

                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Sno')),
                    DataColumn(label: Text('Institution')),
                    DataColumn(label: Text('From Date')),
                    DataColumn(label: Text('To Date')),
                    DataColumn(label: Text('Percentage')),
                    DataColumn(label: Text('Education Level')),
                    DataColumn(label: Text('Course Taken')),
                  ],
                  rows: educationData.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text('${educationData.indexOf(doc) + 1}')),
                        DataCell(Text(data['institution'] ?? '')),
                        DataCell(Text(data['fromDate'] ?? '')),
                        DataCell(Text(data['toDate'] ?? '')),
                        DataCell(Text(data['percentage'] ?? '')),
                        DataCell(Text(data['educationLevel'] ?? '')),
                        DataCell(Text(data['course'] ?? '')),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateInfo1 extends StatelessWidget {
  const UpdateInfo1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Info'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'EDUCATION DETAILS:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    EducationDetailsWidget(loggedInUserId: _getLoggedInUserId()),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch the logged-in user's ID when the widget initializes
  String _getLoggedInUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return '';
    }
  }
}

void main() {
  runApp(const UpdateInfo1());
}
