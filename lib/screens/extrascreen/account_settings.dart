import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/usermodel.dart';
import 'changepass.dart';
import 'editprofile.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_new_app/provider/themeprovider.dart'; // Import the theme provider

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? firstName;
  String? lastName;
  String? email;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    // No need to call _fetchUserData() here anymore.
  }

  Future<UserModel?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(); // Fetch user data from Firestore
      if (doc.exists) {
        return UserModel.fromDocument(doc); // Create UserModel instance
      }
    }
    return null; // Return null if no user found or document doesn't exist
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Account Settings",
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.primary,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<UserModel?>(
            future: _fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Icon(Icons.error, color: Colors.red));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No data available'));
              }

              var userModel = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
                          child: CircleAvatar(
                            backgroundImage: userModel.imageUrl != null &&
                                userModel.imageUrl.isNotEmpty
                                ? NetworkImage(userModel.imageUrl)
                                : const AssetImage('assets/profile3.jpg') as ImageProvider,
                            maxRadius: 50,
                          ),
                        ),
                        Text(
                          "${userModel.firstName ?? "Loading..."} ${userModel.lastName ?? ""}",
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userModel.email ?? 'Email',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.04,
                            color: Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Account Settings Options
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSettingsOption(
                          context,
                          Icons.person,
                          "Edit Profile",
                              () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen()));
                          },
                        ),
                        _buildSettingsOption(
                          context,
                          Icons.lock,
                          "Change Password",
                              () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChangePasswordScreen()));
                          },
                        ),
                        _buildSettingsOption(
                          context,
                          Icons.notifications,
                          "Notifications",
                          null,
                          isSwitch: true,
                          switchValue: true, // Static for example
                          onSwitchChanged: (value) {
                            // Add logic for notification toggle if needed
                          },
                        ),
                        _buildSettingsOption(
                          context,
                          Icons.palette,
                          "Dark Mode",
                          null,
                          isSwitch: true,
                          switchValue: themeProvider.isDarkMode,
                          onSwitchChanged: (value) {
                            themeProvider.toggleTheme(); // Toggle the theme
                          },
                        ),
                        _buildSettingsOption(
                          context,
                          Icons.language,
                          "Language",
                              () {
                            _showLanguageBottomSheet(context); // Show the bottom sheet
                          },
                        ),

                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback? onTap, {
        bool isSwitch = false,
        bool? switchValue,
        ValueChanged<bool>? onSwitchChanged,
      }) {
    Size size = MediaQuery.of(context).size;

    return ListTile(
      leading: Icon(icon,
          color: Theme.of(context).colorScheme.primary,
          size: size.width * 0.07),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isSwitch
          ? Switch(
        value: switchValue!,
        onChanged: onSwitchChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      )
          : Icon(Icons.arrow_forward_ios,
          color: Colors.grey, size: size.width * 0.05),
      onTap: onTap,
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Language",
                style: GoogleFonts.poppins(
                  color: Colors.indigo,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(context, "English"),
              _buildLanguageOption(context, "Spanish"),
              _buildLanguageOption(context, "Urdu"),
              _buildLanguageOption(context, "Arabic"),
              _buildLanguageOption(context, "German"),
              _buildLanguageOption(context, "French"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return ListTile(
      title: Text(
        language,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
      onTap: () {
        // Handle language selection logic here
        Navigator.pop(context); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$language selected!"),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

}
