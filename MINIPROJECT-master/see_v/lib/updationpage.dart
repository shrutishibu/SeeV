import 'package:flutter/material.dart';
import 'package:see_v/update_info.dart';
import 'package:see_v/update_info1.dart';
import 'package:see_v/update_info2.dart';
import 'package:see_v/update_info3.dart';
import 'package:see_v/update_info4.dart';
import 'package:see_v/update_info5.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdationPage(),
    );
  }
}

class UpdationPage extends StatelessWidget {
  const UpdationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updation Page'),
      ),
      body: Center(
        child: SizedBox(
          width: 80.0 * MediaQuery.of(context).size.width / 100.0,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: [
              HoverGridItem(
                title: 'Educational History',
                iconData: Icons.school,
                backgroundColor: const Color.fromARGB(255, 221, 153, 176),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateInfo1(),
                    ),
                  );
                },
              ),
              HoverGridItem(
                title: 'Skill',
                iconData: Icons.star,
                backgroundColor: const Color.fromARGB(255, 155, 200, 236),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateInfo(),
                    ),
                  );
                },
              ),
              HoverGridItem(
                title: 'Projects',
                iconData: Icons.work,
                backgroundColor: const Color.fromARGB(255, 171, 231, 173),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateInfo3(),
                    ),
                  );
                },
              ),
              HoverGridItem(
                title: 'Courses',
                iconData: Icons.book,
                backgroundColor: const Color.fromARGB(255, 220, 177, 228),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateInfo4(),
                    ),
                  );
                },
              ),
              HoverGridItem(
                title: 'Experience',
                iconData: Icons.work_outline,
                backgroundColor: const Color.fromARGB(255, 226, 204, 171),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateInfo2(),
                    ),
                  );
                },
              ),
              HoverGridItem(
                title: 'Personal Information',
                iconData: Icons.person,
                backgroundColor: const Color.fromARGB(255, 155, 216, 210),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileUpdatePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverGridItem extends StatefulWidget {
  final String title;
  final IconData iconData;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const HoverGridItem({super.key, 
    required this.title,
    required this.iconData,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  _HoverGridItemState createState() => _HoverGridItemState();
}

class _HoverGridItemState extends State<HoverGridItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      onHover: (hover) {
        setState(() {
          isHovered = hover;
        });
      },
      splashColor: Colors.white,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          color: isHovered ? const Color.fromARGB(255, 188, 176, 176) : widget.backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(240, 244, 244, 0).withOpacity(0.8),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.iconData,
              size: 48.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
