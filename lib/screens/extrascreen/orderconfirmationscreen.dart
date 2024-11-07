import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_new_app/models/cart_model.dart';
import 'package:ecommerce_new_app/screens/extrascreen/detailed_pages/paymentprocessing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dart:math';
import '../../provider/cart_provider.dart';
import '../../widgets/cart_items.dart';
import 'add_address_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final double subTotal;
  final double shippingch;
  final List<CartModel> cartItems; // Cart items list

  const OrderConfirmationScreen({
    super.key,
    required this.subTotal,
    required this.shippingch,
    required this.cartItems,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {

  String selectedDeliveryMethod = "FedEx";
  String generateOrderNumber() {
    return (100000 + Random().nextInt(900000)).toString();
  }
  final TextEditingController couponController =
  TextEditingController(); // Coupon code controller
  double discountAmount = 0.0;
  String selectedPaymentMethod = "Credit Card";

  double totalPayment = 0.0; // Make totalPayment a state variable
  TextEditingController instructionController = TextEditingController();
  List<DocumentSnapshot> allAddresses = []; // To hold all addresses

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calculateTotalPayment();
    _fetchShippingAddress();

  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String shippingName = '';
  String shippingAddress = '';

  // Fetch the default shipping address and all addresses
  Future<void> _fetchShippingAddress() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      try {
        // Fetch the default shipping address
        QuerySnapshot defaultAddressSnapshot = await _firestore
            .collection('addresses')
            .where('userid', isEqualTo: userId)
            .where('isDefaultShipping', isEqualTo: true)
            .get();

        if (defaultAddressSnapshot.docs.isNotEmpty) {
          DocumentSnapshot defaultAddressDoc = defaultAddressSnapshot.docs.first;

          setState(() {
            shippingName = defaultAddressDoc['recipientName'] ?? 'No name provided';
            shippingAddress = '${defaultAddressDoc['region']}, ${defaultAddressDoc['address'] ?? 'No address provided'}';
          });
        } else {
          setState(() {
            shippingName = 'No default address found';
            shippingAddress = '';
          });
        }

        // Fetch all addresses to show in the bottom sheet
        QuerySnapshot allAddressesSnapshot = await _firestore
            .collection('addresses')
            .where('userid', isEqualTo: userId)
            .get();
        print('Fetched addresses: ${allAddressesSnapshot.docs.map((doc) => doc.data())}');

        setState(() {
          allAddresses = allAddressesSnapshot.docs; // Store all addresses
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch address: $e')),
        );
      }
    }
  }


  void _calculateTotalPayment() {
    double shippingFee = widget.shippingch;

    // Calculate COD charge based on selected payment method
    double codCharge = selectedPaymentMethod == "Cash on Delivery" ? 50.0 : 0.0;

    // Total Payment includes subtotal, shipping fee, COD charge, and subtracts any discount
    totalPayment = widget.subTotal + shippingFee + codCharge - discountAmount;

    // Call setState to refresh the UI if needed
    setState(() {});
  }
  // Additional COD charge
  double codCharge = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Size size = MediaQuery.of(context).size;

    String delieverydays = "2-7 Days";
    String homeDeliveryMethod = "Home Delivery";

    double shippingFee = widget.shippingch;

    // Calculate COD charge based on selected payment method
    if (selectedPaymentMethod == "Cash on Delivery") {
      codCharge = 50.0;
    } else {
      codCharge = 0.0;
    }

    // Total Payment includes subtotal, shipping fee, COD charge, and subtracts any discount
    double totalPayment = widget.subTotal + shippingFee + codCharge - discountAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirm Order",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
            fontSize: size.width * 0.05,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0, // Optional: Remove AppBar shadow
        iconTheme: const IconThemeData(color: Colors.indigo), // Optional: Icon color
      ),
      body: SingleChildScrollView(
        // Ensures the content is scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List of Cart Items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = widget.cartItems[index];
                  return CartItem(cartItem: cartItem);
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),

              // Shipping Address Section
              // Shipping Address Section
              Text(
                "Shipping Address",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                  fontSize: size.width * 0.05,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow positioning
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          shippingName,
                          style: GoogleFonts.poppins(
                            color: isDarkMode ? Colors.black : Colors.indigo,
                            fontWeight: FontWeight.w500,
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_location_alt, color: Colors.indigo),
                          onPressed: () {
                            // Show Bottom Sheet to change address
                            _showAddressSelectionSheet(context);
                          },
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.indigo, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shippingAddress,
                            style: GoogleFonts.poppins(
                              color: isDarkMode ? Colors.black : Colors.indigo,

                              fontSize: size.width * 0.04,
                              height: 1.5, // Line height for better readability
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Coupon Code Input Section
              Text(
                "Apply Coupon Code",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                  fontSize: size.width * 0.05,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: couponController,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle:
                        GoogleFonts.poppins(fontSize: size.width * 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Example: Check coupon and apply discount
                        if (couponController.text.toUpperCase() == "DISCOUNT10") {
                          discountAmount = widget.subTotal * 0.10; // 10% discount
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coupon Applied! 10% Discount')),
                          );
                        } else {
                          discountAmount = 0.0;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid Coupon Code')),
                          );
                        }
                        _updateTotalPayment(); // Update total payment after applying the coupon
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Apply",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Payment Method Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment Method",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                      fontSize: size.width * 0.05,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showPaymentMethodSheet(context); // Bottom sheet for payment methods
                    },
                    child: Text(
                      "Change",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                        fontSize: size.width * 0.03,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Display appropriate icon based on selected payment method
                  _getPaymentMethodIcon(selectedPaymentMethod),
                  const SizedBox(width: 15),
                  Text(
                    selectedPaymentMethod, // Display the updated payment method
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: size.width * 0.05,
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.015),

              // Delivery Method Section
              Text(
                "Delivery Method",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.indigo,
                  fontSize: size.width * 0.05,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDeliveryMethod = "FedEx";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedDeliveryMethod == "FedEx"
                            ? Colors.indigo.shade100
                            : Colors.blueGrey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/icon3.png'),
                          Text(
                            delieverydays,
                            style: GoogleFonts.poppins(
                              color: isDarkMode ? Colors.black : Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * 0.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDeliveryMethod = "Home Delivery";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedDeliveryMethod == "Home Delivery"
                            ? Colors.indigo.shade100
                            : Colors.blueGrey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homeDeliveryMethod,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.black : Colors.indigo,
                              fontSize: size.width * 0.05,
                            ),
                          ),
                          Text(
                            delieverydays,
                            style: GoogleFonts.poppins(
                              color: isDarkMode ? Colors.black : Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * 0.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
// Instruction Notes Section
              Text(
                "Special Instructions (Optional)",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                  fontSize: size.width * 0.05,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instructionController,
                decoration: InputDecoration(
                  hintText: 'Enter any special instructions for your order',
                  hintStyle: GoogleFonts.poppins(fontSize: size.width * 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3, // Allows multiple lines for longer instructions
              ),
              SizedBox(height: size.height * 0.02),

              // Order Summary Section
              Text(
                "Order Summary",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                  fontSize: size.width * 0.05,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sub-Total:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: size.width * 0.04,
                    ),
                  ),
                  Text(
                    "Rs ${widget.subTotal.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping Fee:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: size.width * 0.04,
                    ),
                  ),
                  Text(
                    "Rs ${shippingFee.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
              // Display COD Charge if applicable
              if (codCharge > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "COD Charge:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                    Text(
                      "Rs ${codCharge.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
                      ),
                    ),
                  ],
                ),
              if (codCharge > 0) const SizedBox(height: 10),
              // Display Discount if applicable
              if (discountAmount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discount:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.04,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "- Rs ${discountAmount.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              if (discountAmount > 0) const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Payment:",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Rs ${totalPayment.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Confirm Order Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    addOrderToFirestore(context); // Call the method to add order
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentProcessing()));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: Colors.green,content: Text("Order Confirmed!")));
                    Provider.of<CartProvider>(context, listen: false).clearCart();

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Confirm Order",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
  void _updateTotalPayment() {
    _calculateTotalPayment();
  }
  // Helper function to get payment method icon
  Widget _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Credit Card':
        return const Icon(Icons.credit_card, size: 40, color: Colors.indigo);
      case 'Google Pay':
        return Image.asset('assets/google_pay.png', height: 40);
      case 'PayPal':
        return Image.asset('assets/paypal.png', height: 40);
      case 'Cash on Delivery':
        return const Icon(Icons.money, size: 40, color: Colors.indigo);
      default:
        return const Icon(Icons.payment, size: 40, color: Colors.indigo);
    }
  }

  // Function to show Bottom Sheet for selecting payment method
  void _showPaymentMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Credit Card'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Credit Card";
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Google Pay'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Google Pay";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.paypal),
                title: const Text('PayPal'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "PayPal";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Cash on Delivery'),
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = "Cash on Delivery";
                  });
                  _updateTotalPayment(); // Update total payment after changing payment method
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressSelectionSheet(BuildContext context) {
    // Ensure that addresses are available before showing the bottom sheet
    if (allAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No addresses available to select.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make sure the sheet is only as tall as needed
            children: [
              // IconButton to add a new address
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Address',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddAddressScreen()),
                      );
                    },
                  ),
                ],
              ),
              const Divider(), // A divider for better UI separation
              // Wrap for address selection
              Wrap(
                children: allAddresses.map((addressDoc) {
                  return ListTile(
                    title: Text(
                      '${addressDoc['recipientName']}: ${addressDoc['region']}, ${addressDoc['address']}',
                    ),
                    onTap: () {
                      setState(() {
                        shippingName = addressDoc['recipientName'];
                        shippingAddress = '${addressDoc['region']}, ${addressDoc['address']}';
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> addOrderToFirestore(BuildContext context) async {
    String orderNumber = generateOrderNumber(); // Ensure you have this function

    // Get the current user ID
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is signed in
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please log in to place an order.')),
      );
      return;
    }

    // Create a map of order details
    final orderDetails = {
      'orderNumber': orderNumber,
      'subtotal': widget.subTotal,
      'shippingCharge': widget.shippingch,
      'discountAmount': discountAmount,
      'totalPayment': totalPayment,
      'selectedPaymentMethod': selectedPaymentMethod,
      'selectedDeliveryMethod': selectedDeliveryMethod,
      'shippingAddress': shippingAddress,
      'shippingName': shippingName,
      'instructions': instructionController.text,
      'cartItems': widget.cartItems.map((item) => item.toMap()).toList(),
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Pending', // Initial status is 'Pending'
      'userId': user.uid, // Store the user ID
      'isReviewed': false, // Set the review status to false initially
    };

    try {
      // **Add the order to Firestore and retrieve its reference**
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add(orderDetails);
      String orderId = orderRef.id; // Get the document ID

      print('Order added successfully with ID: $orderId');

      // **Update the same document to include the 'orderId' field**
      await orderRef.update({'orderId': orderId});

      // Start a timer to update the order status to 'Shipped'
      Timer(const Duration(seconds: 20), () async {
        await updateOrderStatus(orderRef, 'Shipped');
        // After 5 more minutes, update to 'Delivered'
        Timer(const Duration(seconds: 300), () async {
          await updateOrderStatus(orderRef, 'Delivered');
        });
      });

    } catch (e) {
      print('Error adding order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm order: $e')),
      );
    }
  }


// Function to update order status in Firestore
  Future<void> updateOrderStatus(DocumentReference orderRef, String status) async {
    try {
      await orderRef.update({'status': status});
      print('Order status updated to: $status');
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

}
