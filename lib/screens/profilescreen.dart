import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usermodel.dart';
import '../widgets/custom_alertdialog.dart';
import 'extrascreen/account_settings.dart';
import 'extrascreen/help_center.dart';
import 'extrascreen/payment_screen.dart';
import 'extrascreen/review_screen.dart';
import 'extrascreen/shippingscreen.dart';
import 'loginscreen.dart';
import 'orderscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? firstName;
  String? lastName;
  String? email;
  String? profileImageUrl;

  bool isLoading = true; // Loading flag
  String? errorMessage; // To display error messages

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndFetchData();
  }

  Future<void> _checkAuthenticationAndFetchData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Redirect to login screen if user is not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      });
    } else {
      await _fetchUserData(user);
    }
  }

  Future<void> _fetchUserData(User user) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        UserModel userModel = UserModel.fromDocument(doc);
        setState(() {
          firstName = userModel.firstName;
          lastName = userModel.lastName;
          email = userModel.email;
          profileImageUrl = userModel.imageUrl;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "User data not found.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load user data.";
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Profile",
                    style: GoogleFonts.poppins(
                      color: Colors.indigo,
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildProfileHeader(size),
                _buildProfileOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Size size) {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get(), // Fetch user document
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.red);
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No data available'));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
                  child: CircleAvatar(
                    backgroundImage: userData['image_url'] != null &&
                            userData['image_url'].isNotEmpty
                        ? NetworkImage(userData['image_url'])
                        : const AssetImage('assets/profile3.jpg'),
                    maxRadius: 50,
                  ),
                ),
                Text(
                  "${userData['first_name'] ?? "First"} ${userData['last_name'] ?? "Last Name"}",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userData['email'] ?? 'Email',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOptions() {
    return ListView(
      shrinkWrap: true, // Important for scrollable ListView
      physics: const NeverScrollableScrollPhysics(), // Disable outer scroll
      children: [
        _buildProfileOption(context, Icons.settings, "Account Settings", () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen()));
        }),
        _buildProfileOption(context, Icons.shopping_bag, "My Orders", () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OrderScreen()),
            (route) => true,
          );
        }),
        _buildProfileOption(context, Icons.payment, "Payment", () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PaymentMethodScreen()));
        }),
        _buildProfileOption(context, Icons.location_on, "Shipping Address", () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ShippingAddressScreen()));
        }),
        _buildProfileOption(context, Icons.help, "Help Center", () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen()));
        }),
        _buildProfileOption(context, Icons.reviews, "My Reviews", () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReviewListPage()));
        }),
        _buildProfileOption(context, Icons.logout, "Logout", () {
          _showLogoutDialog(context);
        }),
      ],
    );
  }

  // Helper function to create profile options
  Widget _buildProfileOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    Size size = MediaQuery.of(context).size;

    return ListTile(
      leading: Icon(icon, color: Colors.indigo, size: size.width * 0.07),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Colors.grey, size: size.width * 0.05),
      onTap: onTap,
    );
  }

  // Show confirmation dialog for logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomDialogWidget(); // Call CustomDialogWidget properly here
      },
    );
  }
}
