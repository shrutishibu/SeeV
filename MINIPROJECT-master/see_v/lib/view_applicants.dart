// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants for Jobs'),
      ),
      body: FutureBuilder<String?>(
        future: _getCurrentUserCompanyId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No company ID found'));
          } else {
            String companyId = snapshot.data!;
            return _buildApplicantsList(companyId);
          }
        },
      ),
    );
  }

  Future<String?> _getCurrentUserCompanyId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }
    return null;
  }

  Widget _buildApplicantsList(String companyId) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .snapshots(),
    builder: (context, jobSnapshot) {
      if (jobSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (!jobSnapshot.hasData || jobSnapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No jobs available'));
      } else {
        final jobDocs = jobSnapshot.data!.docs;

        return ListView.builder(
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            final jobData = jobDocs[index].data() as Map<String, dynamic>;
            final jobId = jobDocs[index].id;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('resumes')
                  .where('jobId', isEqualTo: jobId) // Filter resumes by jobId
                  .snapshots(),
              builder: (context, resumeSnapshot) {
                if (resumeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!resumeSnapshot.hasData || resumeSnapshot.data!.docs.isEmpty) {
                  return const SizedBox(); // No applicants for this job
                } else {
                  final resumeDocs = resumeSnapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          jobData['jobTitle'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: resumeDocs.length,
                        itemBuilder: (context, index) {
                          final resumeData = resumeDocs[index].data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(resumeData['name'] ?? 'No Name'),
                            subtitle: Text(resumeData['email'] ?? 'No Email'),
                            onTap: () {
                              _viewApplicantResume(context, resumeData);
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            );
          },
        );
      }
    },
  );
}

  void _viewApplicantResume(BuildContext context, Map<String, dynamic> applicantData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a dialog to display applicant's resume details
        return AlertDialog(
          title: const Text('Applicant Resume'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResumeSection('Name', applicantData['name'] ?? 'Unknown'),
                _buildResumeSection('Phone', applicantData['phone'] ?? 'Unknown'),
                _buildResumeSection('Email', applicantData['email'] ?? 'Unknown'),
                _buildResumeSection('GitHub', applicantData['github'] ?? 'Unknown'),
                _buildResumeSection('LinkedIn', applicantData['linkedin'] ?? 'Unknown'),
                _buildResumeSection('Education', _getListAsString(applicantData['education'])),
                _buildResumeSection('Experiences', _getListAsString(applicantData['experiences'])),
                _buildResumeSection('Projects', _getListAsString(applicantData['projects'])),
                _buildResumeSection('Skills', _getListAsString(applicantData['skills'])),
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

  String _getListAsString(List<dynamic>? list) {
    if (list != null && list.isNotEmpty) {
      return list.join(', ');
    } else {
      return 'Unknown';
    }
  }
}

  Widget _buildResumeSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          content,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

void main() {
  runApp(MaterialApp(
    home: ApplicantsPage(),
  ));
}
