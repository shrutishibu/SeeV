// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:see_v/blogs_page.dart';
import 'package:see_v/mycv_page.dart';
import 'package:see_v/pages/splash_screen.dart';
import 'package:see_v/updationpage.dart';
import 'package:see_v/view_jobs.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, String> getLoggedInUserInfo() {
    User? user = _auth.currentUser;
    if (user != null) {
      return {
        'first_name': user.displayName ?? '',
        'email': user.email ?? '',
      };
    } else {
      return {
        'first_name': '',
        'email': '',
      };
    }
  }
}

AuthService authService = AuthService();

class HomePage extends StatefulWidget {
  final void Function() signOut;

  const HomePage({Key? key, required this.signOut}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalResumes = 0;
  int totalUsers = 0;
  int userBlogs = 0;
  int userResumes = 0;

  @override
  void initState() {
    super.initState();
    fetchResumeCount();
    fetchUserCount();
    fetchUserBlogs();
    fetchUserResumes();
  }

  Future<void> fetchResumeCount() async {
    final QuerySnapshot<Map<String, dynamic>> resumeQuery =
        await FirebaseFirestore.instance.collection('resumes').get();

    setState(() {
      totalResumes = resumeQuery.size;
    });
  }

  Future<void> fetchUserCount() async {
    final QuerySnapshot<Map<String, dynamic>> userQuery =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      totalUsers = userQuery.size;
    });
  }

  Future<void> fetchUserBlogs() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot<Map<String, dynamic>> blogQuery = await FirebaseFirestore
          .instance
          .collection('blogs')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        userBlogs = blogQuery.size;
      });
    }
  }

  Future<void> fetchUserResumes() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot<Map<String, dynamic>> resumeQuery = await FirebaseFirestore
          .instance
          .collection('resumes')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        userResumes = resumeQuery.size;
      });
    }
  }

  String feedbackText = '';

  @override
  Widget build(BuildContext context) {
    Map<String, String> user = authService.getLoggedInUserInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color.fromARGB(255, 139, 202, 234),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user['first_name']!),
              accountEmail: Text(user['email']!),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Update'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My CV'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResumesPage())
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Jobs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  // ignore: prefer_const_constructors
                  MaterialPageRoute(builder: (context) => const JobViewPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Blogs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlogsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                  // Navigate to e_login.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashScreen())
                    );
                },
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6, // Set width to 60% of the screen width
          height: MediaQuery.of(context).size.height * 0.8, // Set height to 80% of the screen 
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                  const Text(
                    'SeeV: An innovative tool to step up your career game',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                     textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'A web application that allows you to generate a professional CV that is personalized according to job preferences and acts as a guiding light throughout the process of seeking a job. Take a look at the analytics of our website!',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 300.0,
                    child: Card(
                      color: const Color.fromARGB(255, 196, 209, 230),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildPieChart('Total Resumes', totalResumes),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 300.0,
                    child: Card(
                      color: const Color.fromARGB(255, 222, 210, 191),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildPieChart('Blogs Created', userBlogs),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 300.0,
                    child: Card(
                      color: const Color.fromARGB(255, 216, 241, 217),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildBarChart('Users and Resumes', totalUsers, userResumes),
                      ),
                    ),
                  ),
                  // Feedback Section
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 300.0,
                    child: Card(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text(
                              'Feedback',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              maxLines: 4,
                              onChanged: (value) {
                                setState(() {
                                  feedbackText = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter your feedback here',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                _submitFeedback();
                              },
                              child: const Text('Submit Feedback'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitFeedback() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && feedbackText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('feedback').add({
          'userId': user.uid,
          'email': user.email,
          'feedbackText': feedbackText,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Reset the feedback text after submission
        setState(() {
          feedbackText = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
          ),
        );
      } catch (e) {
        print('Error submitting feedback: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback before submitting.'),
        ),
      );
    }
  }
}
  Widget _buildPieChart(String title, int data) {
    List<ChartData> chartData = [ChartData('Total', data)];

    return charts.PieChart(
      _createPieChartData(chartData),
      animate: true,
      defaultRenderer: charts.ArcRendererConfig<String>(
        arcWidth: 100,
        arcRendererDecorators: [charts.ArcLabelDecorator<String>()],
      ),
    );
  }

  List<charts.Series<ChartData, String>> _createPieChartData(List<ChartData> chartData) {
    return [
      charts.Series<ChartData, String>(
        id: 'Data',
        domainFn: (ChartData sales, _) => sales.category,
        measureFn: (ChartData sales, _) => sales.value.toDouble(),
        data: chartData,
        labelAccessorFn: (ChartData sales, _) => '${sales.category}: ${sales.value}',
      )
    ];
  }

  Widget _buildBarChart(String title, int usersData, int resumesData) {
    List<ChartData> chartData = [
      ChartData('Users', usersData),
      ChartData('Resumes', resumesData),
    ];

    return charts.BarChart(
      _createBarChartData(chartData),
      animate: true,
      behaviors: [charts.SeriesLegend()],
    );
  }

  List<charts.Series<ChartData, String>> _createBarChartData(List<ChartData> chartData) {
    return [
      charts.Series<ChartData, String>(
        id: 'Data',
        domainFn: (ChartData sales, _) => sales.category,
        measureFn: (ChartData sales, _) => sales.value.toDouble(),
        data: chartData,
        labelAccessorFn: (ChartData sales, _) => '${sales.category}: ${sales.value}',
      )
    ];
  }


class ChartData {
  final String category;
  final int value;

  ChartData(this.category, this.value);
}
