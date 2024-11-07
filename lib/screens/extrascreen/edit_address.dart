import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAddressScreen extends StatefulWidget {
  final String addressId;
  final String region;
  final String address;
  final String landmark;
  final String recipientName;
  final String phoneNumber;
  final bool isHome;
  final bool isDefaultShipping;
  final bool isDefaultBilling;

  EditAddressScreen({
    super.key,
    required this.addressId,
    required this.region,
    required this.address,
    required this.landmark,
    required this.recipientName,
    required this.phoneNumber,
    required this.isHome,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
  });

  @override
  EditAddressScreenState createState() => EditAddressScreenState();
}

class EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late String region;
  late String address;
  late String landmark;
  late String recipientName;
  late String phoneNumber;
  bool isHome = true;
  bool isDefaultShipping = true;
  bool isDefaultBilling = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize fields with the passed data
    region = widget.region;
    address = widget.address;
    landmark = widget.landmark;
    recipientName = widget.recipientName;
    phoneNumber = widget.phoneNumber;
    isHome = widget.isHome;
    isDefaultShipping = widget.isDefaultShipping;
    isDefaultBilling = widget.isDefaultBilling;
  }

  Future<void> deleteAddress() async {
    try {
      // Use the address ID to delete the document
      await _firestore.collection('addresses').doc(widget.addressId).delete();
      Navigator.pop(context); // Go back after deletion
      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address deleted successfully")),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete address: $e")),
      );
    }
  }

  Future<void> updateAddress() async {
    try {
      // Prepare the updated data
      final updatedAddressData = {
        'region': region,
        'address': address,
        'landmark': landmark,
        'recipientName': recipientName,
        'phoneNumber': phoneNumber,
        'isHome': isHome,
        'isDefaultShipping': isDefaultShipping,
        'isDefaultBilling': isDefaultBilling,
      };

      // Use the address ID to update the document
      await _firestore.collection('addresses').doc(widget.addressId).update(updatedAddressData);
      Navigator.pop(context); // Go back after saving
      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address updated successfully")),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update address: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit My Address",
          style: GoogleFonts.poppins(fontSize: size.width * 0.05),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField("Region/City/District", region, true),
              const SizedBox(height: 15),
              _buildTextFormField("Address", address, true),
              const SizedBox(height: 15),
              _buildTextFormField("Landmark (Optional)", landmark, false),
              const SizedBox(height: 15),
              _buildTextFormField("Recipient's Name", recipientName, true),
              const SizedBox(height: 15),
              _buildTextFormField("Phone Number", phoneNumber, true),
              const SizedBox(height: 15),
              _buildAddressCategory(),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateAddress(); // Call updateAddress method
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: () {
                  // Call the delete function
                  deleteAddress();
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: Text(
                  "Delete Address",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: size.width * 0.04,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      onChanged: (value) {
        // Update the respective field
        if (label == "Region/City/District") {
          region = value;
        } else if (label == "Address") {
          address = value;
        } else if (label == "Landmark (Optional)") {
          landmark = value;
        } else if (label == "Recipient's Name") {
          recipientName = value;
        } else if (label == "Phone Number") {
          phoneNumber = value;
        }
      },
    );
  }

  Widget _buildAddressCategory() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Address Category",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
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
}
