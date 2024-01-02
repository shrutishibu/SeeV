// ignore_for_file: avoid_print, unused_local_variable, use_super_parameters, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CV {
  final String name;
  final String phone;
  final String email;
  final String github;
  final String linkedin;
  final List<String> experiences;
  final List<String> skills;
  final List<String> courses;
  final List<String> projects;
  final List<String> education;

  CV({
    required this.name,
    required this.phone,
    required this.email,
    required this.github,
    required this.linkedin,
    required this.experiences,
    required this.skills,
    required this.courses,
    required this.projects,
    required this.education,
  });
}

class JobViewPage extends StatefulWidget {
  const JobViewPage({Key? key}) : super(key: key);

  @override
  _JobViewPageState createState() => _JobViewPageState();
}

class _JobViewPageState extends State<JobViewPage> {
  List<DocumentSnapshot>? jobs;

  @override
  void initState() {
    super.initState();
    // Fetch the list of jobs from Firestore
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    // Replace 'jobs' with your actual collection name
    QuerySnapshot jobSnapshot = await FirebaseFirestore.instance.collection('jobs').get();
    setState(() {
      jobs = jobSnapshot.docs;
    });
  }

  Future<String?> _getCompanyName(String companyId) async {
    DocumentSnapshot companySnapshot =
        await FirebaseFirestore.instance.collection('users').doc(companyId).get();
    if (companySnapshot.exists) {
      return companySnapshot.get('displayName');
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job View'),
      ),
      body: jobs != null
          ? ListView.builder(
              itemCount: jobs!.length,
              itemBuilder: (context, index) {
                return FutureBuilder<String?>(
                  future: _getCompanyName(jobs![index]['companyId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error loading company name');
                    } else {
                      String companyName = snapshot.data ?? 'Unknown Company';
                      return _buildJobTile(jobs![index], companyName);
                    }
                  },
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildJobTile(DocumentSnapshot job, String companyName) {
  return Card(
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      title: Text(job['jobTitle'] ?? 'No Title'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Company: $companyName'),
          Text('Duration: ${job['duration'] ?? ''}'),
          Text('Salary: ${job['salary'] ?? ''}'),
          Text('Job Field: ${job['field'] ?? ''}'),
          Text('Location: ${job['location'] ?? ''}'),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              // Implement the logic to apply for the job
              print('Applying for job: ${job.id}');
              _applyForJob(job.id);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
}


  Future<void> _applyForJob(String jobId) async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userSnapshot.exists) {
     String firstName = userSnapshot.get('first_name') ?? '';
    String lastName = userSnapshot.get('last_name') ?? '';
    String name = '$firstName $lastName';
    String phone = userSnapshot.get('phone') ?? '';
    String email = userSnapshot.get('email') ?? '';
    String github = userSnapshot.get('github') ?? '';
    String linkedin = userSnapshot.get('linkedin') ?? '';

    QuerySnapshot experienceSnapshot = await FirebaseFirestore.instance.collection('experience').where('userId', isEqualTo: userId).get();
    List<String> userExperiences = experienceSnapshot.docs.map((doc) => doc.get('jobPosition') as String).toList();

    QuerySnapshot skillsSnapshot = await FirebaseFirestore.instance.collection('skills').where('userId', isEqualTo: userId).get();
    List<String> userSkills = skillsSnapshot.docs.map((doc) => doc.get('name') as String).toList();

    QuerySnapshot coursesSnapshot = await FirebaseFirestore.instance.collection('courses').where('userId', isEqualTo: userId).get();
    List<String> userCourses = coursesSnapshot.docs.map((doc) => doc.get('courseName') as String).toList();

    QuerySnapshot projectsSnapshot = await FirebaseFirestore.instance.collection('projects').where('userId', isEqualTo: userId).get();
    List<String> userProjects = projectsSnapshot.docs.map((doc) => doc.get('projectName') as String).toList();

    QuerySnapshot educationSnapshot = await FirebaseFirestore.instance.collection('education').where('userId', isEqualTo: userId).get();
    List<String> userEducation = educationSnapshot.docs.map((doc) {
      final institution = doc.get('institution') as String;
      final educationLevel = doc.get('educationLevel') as String;
      final percentage = doc.get('percentage') as String;
      return '$institution, $educationLevel, $percentage';
    }).toList();


    DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();

    if (jobSnapshot.exists) {
      List<String> requiredSkills = List<String>.from(jobSnapshot.get('skills') ?? []);

     QuerySnapshot coursesSnapshot = await FirebaseFirestore.instance.collection('courses').where('userId', isEqualTo: userId).get();
    List<String> matchingCourses = coursesSnapshot.docs
        .where((doc) => (doc.get('skills') as List).any((skill) => requiredSkills.contains(skill)))
        .map((doc) => doc.get('courseName') as String)
        .toList();

    QuerySnapshot experienceSnapshot = await FirebaseFirestore.instance.collection('experience').where('userId', isEqualTo: userId).get();
    List<Map<String, String>> matchingExperiencesWithDetails = experienceSnapshot.docs
        .where((doc) => (doc.get('skills') as List).any((skill) => requiredSkills.contains(skill)))
        .map((doc) {
          final institution = doc.get('institution') as String;
          final jobPosition = doc.get('jobPosition') as String;
          return {
            'institution': institution,
            'jobPosition': jobPosition,
          };
        }).toList();

        List<String> matchingExperiences = matchingExperiencesWithDetails
        .map((experience) => '${experience['institution']}, ${experience['jobPosition']}')
        .toList();


      QuerySnapshot projectsSnapshot = await FirebaseFirestore.instance.collection('projects').where('userId', isEqualTo: userId).get();
      List<String> matchingProjects = projectsSnapshot.docs
        .where((doc) => (doc.get('skills') as List).any((skill) => requiredSkills.contains(skill)))
        .map((doc) => doc.get('projectName') as String)
        .toList();

      List<String> matchingSkills = userSkills.where((skill) => requiredSkills.contains(skill)).toList();

      CV cv = CV(
        name: name,
        phone: phone,
        email: email,
        github: github,
        linkedin: linkedin,
        experiences: matchingExperiences,
        skills: matchingSkills,
        courses: matchingCourses,
        projects: matchingProjects,
        education: userEducation,
      );

       Map<String, dynamic> cvData = {
        'userId': userId,
        'jobId': jobId,
      'name': name,
      'phone': phone,
      'email': email,
      'github': github,
      'linkedin': linkedin,
      'experiences': matchingExperiences,
      'skills': matchingSkills,
      'courses': matchingCourses,
      'projects': matchingProjects,
      'education': userEducation,
    };

      // Store the CV data in Firestore under 'resumes' collection
    await FirebaseFirestore.instance.collection('resumes').add(cvData);

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Generated CV'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCVSection('Name', cv.name),
                  _buildCVSection('Phone', cv.phone),
                  _buildCVSection('Email', cv.email),
                  _buildCVSection('GitHub', cv.github),
                  _buildCVSection('LinkedIn', cv.linkedin),
                  _buildCVSection('Experiences', cv.experiences.join('\n')),
                  _buildCVSection('Skills', cv.skills.join(', ')),
                  _buildCVSection('Courses', cv.courses.join(', ')),
                  _buildCVSection('Projects', cv.projects.join(', ')),
                  _buildCVSection('Education', cv.education.join('\n')),
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
  }
}

  Widget _buildCVSection(String title, String content) {
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
}

void main() {
  runApp(
    const MaterialApp(
      home: JobViewPage(),
    ),
  );
}
