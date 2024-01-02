// ignore_for_file: unused_field, avoid_print, use_super_parameters, use_build_context_synchronously

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:see_v/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _selectedGender;
  XFile? _profilePicture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            color: Colors.blue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'LET\'S GET YOU SET UP',
                        speed: const Duration(milliseconds: 100),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'It should only take a couple of minutes to create your account',
                        speed: const Duration(milliseconds: 50),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _middleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name (Optional)',
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email (Username)',
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _dobController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null && pickedDate != DateTime.now()) {
                          _dobController.text = pickedDate.toLocal().toString().split(' ')[0];
                        }
                      },
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                       
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Profile Picture
                      ElevatedButton(
                      onPressed: _selectProfilePicture,
                      child: const Text('Select Profile Picture'),
                    ),
                    if (_profilePicture != null)
                      SizedBox(
                        height: 150,
                        child: _profilePictureWidget(), // Use a new function
                      ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Form is valid, proceed with sign-up
                          _signUp();
                        }
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePictureWidget() {
  if (_profilePicture != null) {
    if (kIsWeb) {
      // For web, use Image.network
      return Image.network(_profilePicture!.path);
    } else {
      // For other platforms, check if the file exists before trying to display it
      File file = File(_profilePicture!.path);
      if (file.existsSync()) {
        return Image.file(file);
      } else {
        return const Text('Image not found');
      }
    }
  } else {
    return Container(); // or some default widget when there's no profile picture
  }
}

  void _selectProfilePicture() async {
  try {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Read image data as bytes
      List<int> imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _profilePicture = XFile.fromData(Uint8List.fromList(imageBytes), name: 'profile_picture.jpg');
      });
    }
  } catch (e) {
    print('Error selecting profile picture: $e');
  }
}

  void _signUp() async {
    try {
      // Create a user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Get the user ID
      String userId = userCredential.user!.uid;

      // Combine first name and last name for display name
      String displayName = '${_firstNameController.text} ${_lastNameController.text}';

      // Set the displayName using the combined name
      await userCredential.user?.updateDisplayName(displayName);

      // Upload profile picture to Firebase Storage if it's not null
      String profilePictureUrl = '';
      if (_profilePicture != null) {
        profilePictureUrl = await _uploadProfilePicture(userId);
      }

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'first_name': _firstNameController.text,
        'middle_name': _middleNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'profile_picture_url': profilePictureUrl,
        'github': '', // Initialize with an empty string
        'linkedin': '', // Initialize with an empty string
        'role': 'registered_user',
        // Add more fields as needed
      });

      // Navigate to the welcome page or perform other actions after successful sign-up
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(signOut: () {})),
      );

    } catch (e) {
      // Handle errors (e.g., email already in use)
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          // Handle email already in use error
          _showSnackBar('Email is already in use. Please use a different email.');
        }
      } else {
        // Handle other exceptions
        _showSnackBar('Error during sign up. Please try again.');
      }
    }
  }

  Future<String> _uploadProfilePicture(String userId) async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('profilePictures/$userId.jpg');

      // Upload the file
      await ref.putFile(File(_profilePicture!.path));

      // Get the download URL
      final downloadURL = await ref.getDownloadURL();

      // Log information for debugging
      print('File path: ${_profilePicture!.path}');
      print('Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      // Log error for debugging
      print('Error uploading profile picture: $e');

      // Show error message
      _showSnackBar('Error uploading profile picture. Please try again.');

      return ''; // Return an empty string or handle error as needed
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}