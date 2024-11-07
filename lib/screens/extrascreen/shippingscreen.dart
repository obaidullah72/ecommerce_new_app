import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_new_app/screens/extrascreen/edit_address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_address_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  // Firestore instance to access the 'addresses' collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Addresses",
            style: GoogleFonts.poppins(
              color: Colors.indigo,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAddressScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('addresses')
              .where('userid', isEqualTo: _auth.currentUser?.uid) // Match current user ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No addresses found. Add a new address."),
              );
            }

            // Display the list of addresses
            final addresses = snapshot.data!.docs;

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index].data() as Map<String, dynamic>;
                return _buildAddressTile(size, address);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressTile(Size size, Map<String, dynamic> address) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.only(
            bottom: 10.0, left: 10.0, right: 10.0, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${address['recipientName']} - ${address['phoneNumber']}",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevents text overflow
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                address['address'],
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: Colors.grey[600],
                ),
                maxLines: 2, // Limits the address to 2 lines
                overflow: TextOverflow
                    .ellipsis, // Ensures address text is truncated if too long
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAddressScreen(
                          region: address['region'] ?? '',
                          address: address['address'] ?? '',
                          landmark: address['landmark'] ?? '',
                          recipientName: address['recipientName'] ?? '',
                          phoneNumber: address['phoneNumber'] ?? '',
                          isHome: address['isHome'] ?? true,
                          isDefaultShipping: address['isDefaultShipping'] ?? false,
                          isDefaultBilling: address['isDefaultBilling'] ?? false,
                          addressId: address['addressid'] ?? '', // Use Firestore document ID
                        ),
                      ),
                    );
                  },
                ),
                if (address['isDefaultShipping'] == true)
                  const Chip(
                    label: Text(
                      "Default Shipping Address",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
