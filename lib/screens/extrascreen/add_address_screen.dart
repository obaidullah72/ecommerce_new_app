import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form fields
  String region = '';
  String address = '';
  String landmark = '';
  String recipientName = '';
  String phoneNumber = '';
  bool isHome = true;
  bool isDefaultShipping = false;
  bool isDefaultBilling = false;

  // List of cities in Pakistan
  final List<String> cities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Peshawar',
    'Quetta',
    'Multan',
    'Sialkot',
    'Gujranwala',
    'Bahawalpur',
    'Hyderabad',
    'Abbottabad',
    'Sukkur',
    'Mardan',
    'Dera Ghazi Khan',
    'Chitral',
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Add New Address",
            style: GoogleFonts.poppins(fontSize: size.width * 0.05),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildCityDropdown(), // Dropdown for cities
                const SizedBox(height: 15),
                _buildTextFormField("Address *", address, true),
                const SizedBox(height: 15),
                _buildTextFormField("Landmark (Optional)", landmark, false),
                const SizedBox(height: 15),
                _buildTextFormField("Recipient's Name *", recipientName, true),
                const SizedBox(height: 15),
                _buildTextFormField("Phone Number *", phoneNumber, true),
                const SizedBox(height: 15),
                _buildAddressCategory(),
                const SizedBox(height: 15),
                _buildSwitchListTile("Default Shipping Address", isDefaultShipping, (value) {
                  setState(() {
                    isDefaultShipping = value;
                  });
                }),
                _buildSwitchListTile("Default Billing Address", isDefaultBilling, (value) {
                  setState(() {
                    isDefaultBilling = value;
                  });
                }),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _saveAddress(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    "Save Address",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown for cities
  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: region.isNotEmpty ? region : null, // Initial value
      decoration: const InputDecoration(
        labelText: 'Region/City/District *',
        border: OutlineInputBorder(),
      ),
      items: cities.map((city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          region = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a city";
        }
        return null;
      },
    );
  }

  Widget _buildTextFormField(String label, String initialValue, bool isRequired) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          if (label.contains("Address")) {
            address = value!;
          } else if (label.contains("Landmark")) {
            landmark = value!;
          } else if (label.contains("Recipient")) {
            recipientName = value!;
          } else if (label.contains("Phone")) {
            phoneNumber = value!;
          }
        });
      },
    );
  }

  Widget _buildAddressCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address Category",
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text("Home"),
                value: true,
                groupValue: isHome,
                onChanged: (value) {
                  setState(() {
                    isHome = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text("Office"),
                value: false,
                groupValue: isHome,
                onChanged: (value) {
                  setState(() {
                    isHome = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchListTile(String title, bool currentValue, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      onChanged: onChanged,
    );
  }

  // Save Address to Firestore
  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Create a unique document ID (optional)
        String documentId = '${recipientName.replaceAll(" ", "_")}_$phoneNumber';
        String? userId = _auth.currentUser?.uid;

        // Create the address data map
        Map<String, dynamic> addressData = {
          'userid': userId,
          'addressid': documentId,
          'region': region,
          'address': address,
          'landmark': landmark,
          'recipientName': recipientName,
          'phoneNumber': phoneNumber,
          'isHome': isHome,
          'isDefaultShipping': isDefaultShipping,
          'isDefaultBilling': isDefaultBilling,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Save the address to Firestore with a unique ID
        await _firestore.collection('addresses').doc(documentId).set(addressData);

        // Navigate back after saving
        Navigator.pop(context);
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e')),
        );
      }
    }
  }
}
