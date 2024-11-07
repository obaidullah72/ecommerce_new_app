import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Debugging: Print the order data
    print('Order Details: $order');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #${order['orderNumber']}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Order Date: ${order['date']}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Total Amount: ${order['total']}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tracking ID: ${order['status'] ?? 'N/A'}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Products:",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: order['products']?.length ?? 0,
                itemBuilder: (context, index) {
                  // Debugging: Print the product details
                  final productData = order['products']?[index];
                  print('Product $index: $productData');

                  // Get the product map and the necessary attributes
                  final product = productData['product']; // Accessing product details
                  final quantity = productData['quantity'];
                  final price = product['price'];
                  final imageUrl = product['image']; // Assuming there's an image URL

                  return _buildProductCard(
                    product: product,
                    quantity: quantity,
                    price: price,
                    imageUrl: imageUrl, // Pass the image URL
                    size: size,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (order['instructions']?.isNotEmpty ?? false) ...[
              Text(
                "Notes:",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                order['instructions'],
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper function to build product card
  Widget _buildProductCard({
    required Map<String, dynamic> product,
    required int quantity,
    required double price,
    required String imageUrl, // New parameter for image URL
    required Size size,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: size.height * 0.01),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // Image widget
            Image.network(
              imageUrl,
              width: 120, // Set desired width
              height: 120, // Set desired height
              fit: BoxFit.cover, // Adjust the fit as necessary
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300], // Placeholder color
                  child: const Icon(Icons.error), // Placeholder icon
                );
              },
            ),
            SizedBox(width: size.width * 0.075,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown', // Use product name directly
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5), // Space between product name and quantity/price
                  Text(
                    "Qty: $quantity", // Use quantity directly
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "Rs$price", // Use price directly
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
