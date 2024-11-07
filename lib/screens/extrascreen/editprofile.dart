import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formEditProfileKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  PhoneNumber? phoneNumber;
  DateTime? dateOfBirth;
  String? gender;
  String? profileImageUrl;
  File? _image;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot doc = await userDoc.get();
      if (!doc.exists) {
        // Create a new document with default values
        await userDoc.set({
          'username': '',
          'email': user.email ?? '',
          'first_name': '',
          'last_name': '',
          'phone_number': '',
          'date_of_birth': null,
          'gender': '',
          'image_url': '',
        });
      } else {
        setState(() {
          usernameController.text = doc['username'] ?? '';
          emailController.text = doc['email'] ?? '';
          firstNameController.text = doc['first_name'] ?? '';
          lastNameController.text = doc['last_name'] ?? '';
          phoneNumber = PhoneNumber(
            isoCode: 'PK',
            dialCode: '+92',
            phoneNumber: doc['phone_number'] ?? '',
          );
          phoneController.text = phoneNumber?.phoneNumber ?? '';
          dateOfBirth = (doc['date_of_birth'] as Timestamp?)?.toDate();
          gender = doc['gender'] ?? '';
          profileImageUrl = doc['image_url'] ?? '';
        });
      }
    } else {
      _showSnackBar('No authenticated user found.');
    }
  }


  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _uploadImageToFirebase();
      } else {
        _showSnackBar('No image selected.');
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _uploadImageToFirebase() async {
    User? user = _auth.currentUser;
    if (user == null) {
      _showSnackBar('No authenticated user found.');
      return;
    }

    if (_image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String filePath = 'image_url/${user.uid}.jpeg';
    try {
      final ref = _storage.ref().child(filePath);

      await ref.putFile(_image!);

      String imageUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'image_url': imageUrl,
      });

      setState(() {
        profileImageUrl = imageUrl;
      });

      Navigator.of(context).pop();

      _showSnackBar('Profile image updated successfully');
    } catch (e, stackTrace) {
      Navigator.of(context).pop();
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      if (kDebugMode) {
        print('StackTrace: $stackTrace');
      }
      _showSnackBar('Failed to update profile image. Please try again.');
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dateOfBirth) {
      setState(() {
        dateOfBirth = picked;
      });
    }
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('MM-d-yy', 'en_US').format(date);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Image.asset('assets/bg1.png'),
        Scaffold(
          // backgroundColor: Colors.transparent, // Ensure background is transparent to show bg1.png
          appBar: AppBar(
            title: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                color: Colors.indigo,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent, // Make AppBar transparent if desired
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formEditProfileKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: _selectImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/profile3.jpg') as ImageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Username
                    TextFormField(
                      controller: usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // First Name
                    TextFormField(
                      controller: firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Last Name
                    TextFormField(
                      controller: lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Email
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20.0),

                    // Phone Number Input
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber num) {
                        phoneNumber = num;
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.DROPDOWN,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      initialValue: phoneNumber ?? PhoneNumber(isoCode: 'PK'),
                      textFieldController: phoneController,
                      inputDecoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20.0),

                    // Date of Birth
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateOfBirth != null
                              ? 'Date of Birth: ${getFormattedDate(dateOfBirth!)}'
                              : 'Select Date of Birth',
                          style: TextStyle(
                            color: dateOfBirth != null ? Colors.black : Colors.grey,
                            fontSize: 16,
                            fontWeight: dateOfBirth != null ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Gender Selection with Radio Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Male'),
                                value: 'Male',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Female'),
                                value: 'Female',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Save Changes Button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (_formEditProfileKey.currentState!.validate()) {
                            try {
                              await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
                                'username': usernameController.text,
                                'email': emailController.text,
                                'first_name': firstNameController.text,
                                'last_name': lastNameController.text,
                                'image_url': profileImageUrl ?? '', // Save image URL
                                'phone_number': phoneNumber?.phoneNumber ?? '',
                                'date_of_birth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
                                'gender': gender,
                              });

                              _showSnackBar('Profile updated successfully');
                            } catch (e) {
                              _showSnackBar('Failed to update profile: $e');
                            }
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
