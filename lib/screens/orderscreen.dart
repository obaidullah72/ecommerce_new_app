import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:ecommerce_new_app/screens/extrascreen/write_review_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'extrascreen/detailed_pages/orderdetailscreen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Change parameter type to Map<String, dynamic>
  void navigateToReviewPage(BuildContext context, Map<String, dynamic> orderDetails) {
    // Ensure orderId is available
    if (orderDetails['orderId'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(order: orderDetails),
        ),
      );
    } else {
      // Handle the case where orderId is null
      print('Order ID is null. Cannot navigate to Review Page.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID is missing. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Get the current user's UID
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    print("Current User ID: $currentUserId"); // Debugging statement

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "My Orders",
                  style: GoogleFonts.poppins(
                    color: Colors.indigo,
                    fontSize: size.width * 0.075,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "Order History",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Modify the query to filter by the current user's ID
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Debugging: Check the number of documents retrieved
                    print("Number of documents: ${snapshot.data?.docs.length}"); // Debugging statement

                    final orders = snapshot.data!.docs.map((doc) {
                      return {
                        'orderId': doc.id, // Get the order ID
                        'orderNumber': doc['orderNumber'],
                        'date': (doc['timestamp'] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 10),
                        // Convert timestamp to date string
                        'total': doc['totalPayment'],
                        'status': doc['status'],
                        'products': doc['cartItems'],
                        // Ensure you have this field
                        'instructions': doc['instructions'] ?? '',
                        'isReviewed': doc['isReviewed'] ?? false, // Add isReviewed field
                      };
                    }).toList();

                    // If there are no orders, show a message
                    if (orders.isEmpty) {
                      return const Center(child: Text('No orders found.'));
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(context, orders[index], size);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build each order card
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order, Size size) {
    return Card(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #${order['orderNumber']}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${order['date']}",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "Total: Rs${order['total']}",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderStatus(order['status'] ?? '', size),
                Column(
                  children: [
                    // Conditionally render the review button based on isReviewed field
                    if (!(order['isReviewed'] ?? false))
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to ReviewScreen with order data
                          navigateToReviewPage(context, order); // Pass the order directly
                        },
                        icon: const Icon(Icons.edit, color: Colors.indigo), // Edit icon
                        label: Text(
                          'Review',
                          style: GoogleFonts.poppins(
                            color: Colors.indigo,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        // Navigate to order details with actual order data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(order: {
                              'orderNumber': order['orderNumber'],
                              'date': order['date'],
                              'total': 'Rs${order['total']}',
                              'status': order['status'] ?? 'N/A',
                              'products': order['products'] ?? [],
                              'instructions': order['instructions'] ?? '',
                            }),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to show order status with color indicators
  Widget _buildOrderStatus(String status, Size size) {
    Color statusColor;
    switch (status) {
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'Shipped':
        statusColor = Colors.orange;
        break;
      case 'Pending':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Icon(Icons.circle, color: statusColor, size: size.width * 0.03),
        SizedBox(width: size.width * 0.02),
        Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w500,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
