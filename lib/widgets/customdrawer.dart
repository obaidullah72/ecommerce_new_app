import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_new_app/provider/themeprovider.dart';

import '../screens/extrascreen/editprofile.dart';
import '../screens/favouritescreen.dart';
import '../screens/loginscreen.dart';
import '../screens/orderscreen.dart';
import '../screens/profilescreen.dart'; // Adjust path as necessary

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _selectedTile = -1; // To store the index of the selected tile
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
        child: user == null
            ? Center(
                child: Text(
                  'No user logged in.',
                  style: GoogleFonts.poppins(fontSize: size.width * 0.05),
                ),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: size.width * 0.1,
                      ),
                    );
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Text(
                        'User data not found.',
                        style: GoogleFonts.poppins(fontSize: size.width * 0.05),
                      ),
                    );
                  }

                  // Extract user data
                  var userData = snapshot.data!.data() as Map<String, dynamic>?;

                  String firstName = userData?['first_name'] ?? 'First';
                  String lastName = userData?['last_name'] ?? 'Last Name';
                  String email = userData?['email'] ?? 'Email';
                  String? profileImageUrl = userData?['image_url'];

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      // User Profile Section with fixed background image
                      Container(
                        height: size.height * 0.225,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/bg1.png'),
                            // Path to your fixed background image
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: UserAccountsDrawerHeader(
                          margin: const EdgeInsets.only(bottom: 0),
                          accountName: Text(
                            "$firstName $lastName",
                            // Display first name and last name
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors
                                  .white, // Set text color to white for contrast
                            ),
                          ),
                          accountEmail: Text(
                            email, // Display email
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w400,
                              color:
                                  Colors.white70, // Slightly transparent white
                            ),
                          ),
                          currentAccountPicture: CircleAvatar(
                            radius: size.width * 0.15,
                            backgroundImage: profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage("assets/profile3.jpg"),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors
                                .transparent, // Make sure the header itself is transparent
                          ),
                        ),
                      ),
                      // Drawer Items
                      // ListTile(
                      //   leading: Icon(Icons.home,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'Profile',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      //     );                    },
                      // ),
                      // ListTile(
                      //   leading: Icon(Icons.settings,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'Edit Profile',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      //     );                    },
                      // ),
                      // ListTile(
                      //   leading: Icon(Icons.home,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'Wishlist',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const FavouriteScreen()),
                      //     );                    },
                      // ),
                      // ListTile(
                      //   leading: Icon(Icons.settings,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'My Orders',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const OrderScreen()),
                      //     );                    },
                      // ),
                      // ListTile(
                      //   leading: Icon(Icons.home,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'Privacy Policy',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     _showPrivacyPolicyDialog(context);
                      //   },
                      // ),
                      // ListTile(
                      //   leading: Icon(Icons.settings,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'Terms & Conditions',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     _showTermsConditionsDialog(context);
                      //   },
                      // ),
                      // // More drawer items...
                      // ListTile(
                      //   leading: Icon(Icons.exit_to_app,
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black),
                      //   title: Text(
                      //     'Logout',
                      //     style: TextStyle(
                      //       color: themeProvider.isDarkMode ? Colors.white : Colors
                      //           .black,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     _showSignOutDialog(context);
                      //     // Add logout logic here
                      //   },
                      // ),

                      SizedBox(height: size.height * 0.009,),
                      buildListTile(
                          Iconsax.profile_circle, 'Profile', 0, context),
                      buildListTile(Iconsax.edit, 'Edit Profile', 1, context),
                      buildListTile(Iconsax.heart, 'Wishlist', 2, context),
                      buildListTile(
                          Iconsax.shopping_bag, 'My Orders', 3, context),
                      buildListTile(
                          Iconsax.shield, 'Privacy Policy', 4, context),
                      buildListTile(Iconsax.document_text, 'Terms & Conditions',
                          5, context),
                      const Divider(),
                      // Divider to separate menu from sign-out

                      // Sign-Out Button
                      ListTile(
                        leading: const Icon(Iconsax.logout, color: Colors.red),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          // Sign out logic here
                          _showSignOutDialog(context);
                        },
                      ),
                    ],
                  );
                }));
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally, navigate to the sign-in screen or perform other actions
      // Already handled in the dialog's onPressed
    } catch (e) {
      // Handle sign-out error if necessary
      _showSnackBar('Error signing out: $e');
    }
  }

//   // Helper method to build ListTiles with active states and navigation
  Widget buildListTile(
      IconData icon, String title, int index, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isSelected =
        _selectedTile == index; // Check if the current tile is selected

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Colors.blue
            : Colors.grey, // Change icon color based on selection
      ),
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          // Change text color based on selection
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: MediaQuery.of(context).size.width * 0.045,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedTile = index; // Update the selected tile
        });

        Navigator.pop(context); // Close the drawer

        // Navigate or show dialog based on the index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditProfileScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavouriteScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderScreen()),
            );
            break;
          case 4:
            _showPrivacyPolicyDialog(context); // Show Privacy Policy dialog
            break;
          case 5:
            _showTermsConditionsDialog(
                context); // Show Terms & Conditions dialog
            break;
          default:
            // Handle unknown index if necessary
            break;
        }
      },
    );
  }

  // Method to display Privacy Policy in a dialog
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Policy',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              _privacyPolicyContent,
              // Replace with your actual Privacy Policy content
              style: GoogleFonts.poppins(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.indigo,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Method to display Terms & Conditions in a dialog
  void _showTermsConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms & Conditions',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              _termsConditionsContent,
              // Replace with your actual Terms & Conditions content
              style: GoogleFonts.poppins(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.indigo,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Sample Privacy Policy content
  final String _privacyPolicyContent = '''
**Privacy Policy**

Your privacy is important to us. This privacy statement explains the personal data our app processes, how we process it, and for what purposes.

...

''';

  // Sample Terms & Conditions content
  final String _termsConditionsContent = '''
**Terms & Conditions**

Welcome to our app! By using our app, you agree to the following terms and conditions.

...

''';

  // Sign-out method with confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              color: Colors.grey[700],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  color: Colors.grey[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                await _signOut(); // Call sign out function
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false, // Removes all previous routes
                );
              },
            ),
          ],
        );
      },
    );
  }
}
