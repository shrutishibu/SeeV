// ignore_for_file: avoid_print, use_super_parameters, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

User? getCurrentUser() {
  return _auth.currentUser;
}

String? getCurrentUserId() {
  final User? user = getCurrentUser();
  return user?.uid;
}

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({Key? key}) : super(key: key);

  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  late String _selectedGender = 'Male';
  late bool _isEditingEnabled = true;
  late String _profilePictureUrl = '';
  bool _isPasswordVisible = false;

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Switch(
          value: _isEditingEnabled,
          onChanged: (bool value) {
            setState(() {
              _isEditingEnabled = value;
            });
          },
        ),
        const Text('Enable Editing'),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore and populate the fields
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final String? userId = getCurrentUserId();

    if (userId != null) {
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
        final userData = await userDocRef.get();

        if (userData.exists) {
          setState(() {
            _firstNameController.text = userData.get('first_name');
            _middleNameController.text = userData.get('middle_name');
            _lastNameController.text = userData.get('last_name');
            _emailController.text = userData.get('email');
            _phoneController.text = userData.get('phone');
            _dobController.text = userData.get('dob');
            _selectedGender = userData.get('gender');
            _profilePictureUrl = userData.get('profile_picture_url');
            _githubController.text = userData.get('github');
            _linkedinController.text = userData.get('linkedin');
            _isEditingEnabled = true;
          });
        } else {
          print('User data not found in Firestore.');
          // Handle the case where user data is not found
        }
      } catch (e) {
        print('Error fetching user data: $e');
        // Handle the error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Update'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToggleButton(),
            const SizedBox(height: 20.0),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Handle changing profile picture
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(_profilePictureUrl),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.camera_alt,
                        size: 30.0,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Click on the camera to change the profile picture.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20.0),
            _buildTextField(_firstNameController, 'First Name', enabled: false),
            _buildTextField(_middleNameController, 'Middle Name', enabled: false),
            _buildTextField(_lastNameController, 'Last Name', enabled: false),
            _buildTextField(_phoneController, 'Phone', enabled: _isEditingEnabled),
            _buildTextField(_githubController, 'GitHub', enabled: _isEditingEnabled),
            _buildTextField(_linkedinController, 'LinkedIn', enabled: _isEditingEnabled),
            _buildTextField(_dobController, 'Date of Birth', enabled: false),
            _buildTextField(_emailController, 'Email', enabled: false),
            _buildDropdown(),
            _buildTextField(_passwordController, 'Password', enabled: _isEditingEnabled, isPassword: true),
            _buildTextField(_confirmPasswordController, 'Confirm Password', enabled: _isEditingEnabled, isPassword: true),
            const SizedBox(height: 20.0),
            SizedBox(
              width: 50, // Set the desired width
              child: ElevatedButton(
                onPressed: () {
                  // Handle updating user data in Firestore
                  _updateUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set the button color to blue
                ),
                 child: const Text(
                  'Update Profile',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                  ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true, bool isPassword = false}) {
  return TextField(
    controller: controller,
    obscureText: isPassword && !_isPasswordVisible,
    enabled: enabled,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    ),
  );
}

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('\nGender', style: TextStyle(fontSize: 16.0)),
        const SizedBox(height: 8.0),
        DropdownButton<String>(
          value: _selectedGender,
          onChanged: _isEditingEnabled
              ? (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                }
              : null,
          items: <String>['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          hint: const Text('Select Gender'),
        ),
      ],
    );
  }

  void _updateUserData() async {
    // Validate the data before updating
    if (_validateUserData()) {
      final String? userId = getCurrentUserId();

      if (userId != null) {
        try {
          // Replace 'users' with your Firestore collection name
          final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

          // Update the user data in Firestore
          await userDocRef.update({
            'first_name': _firstNameController.text,
            'middle_name': _middleNameController.text,
            'last_name': _lastNameController.text,
            'phone': _phoneController.text,
            'github': _githubController.text,
            'linkedin': _linkedinController.text,
            // Add other fields as needed
          });

           // Update the password in Firebase Authentication
            final User? user = getCurrentUser();
            if (user != null && _passwordController.text.isNotEmpty) {
              await user.updatePassword(_passwordController.text);
            }

          // Update successful, show a success message or navigate to a new screen
          _showSuccessDialog();
        } catch (e) {
          print('Error updating user data: $e');
          // Handle the error
        }
      }
    }
  }

  bool _validateUserData() {
    // Add your validation logic here
    // Return true if data is valid, otherwise return false

    // For example:
    if (_phoneController.text.length != 10) {
      _showErrorDialog('Phone number must be 10 characters long.');
      return false;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 8) {
      _showErrorDialog('Password must be 8 characters or more.');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match.');
      return false;
    }

    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Successful'),
          content: const Text('Profile updated successfully.'),
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
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ProfileUpdatePage(),
  ));
}
