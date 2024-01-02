import 'package:flutter/material.dart';
import 'package:see_v/pages/job_post.dart';
import 'package:see_v/view_applicants.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth * 0.6,
          child: GridView.count(
            crossAxisCount: 2, // Number of columns in the grid
            mainAxisSpacing: 16.0, // Vertical spacing between tiles
            crossAxisSpacing: 16.0, // Horizontal spacing between tiles
            padding: const EdgeInsets.all(16.0),
            childAspectRatio: 1.2, // Adjust the aspect ratio as needed
            children: [
              // Tile for "Post Jobs"
              _buildDashboardTile(
                'Post Jobs',
                Icons.work, // You can change the icon as needed
                () {
                  // Navigate to the page for posting jobs
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const JobPostingPage()),
                  );
                },
              ),
              // Tile for "View Applications"
              _buildDashboardTile(
                'View Applications',
                Icons.list, // You can change the icon as needed
                () {
                  // Navigate to the page for viewing applications
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ApplicantsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50.0,
              color: Colors.blue,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage in your main function
void main() {
  runApp(
    const MaterialApp(
      home: DashboardPage(),
    ),
  );
}
