import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> order; // Order details with orderId

  // Constructor to accept order details
  ReviewPage({required this.order});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0.0; // Store the rating
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // **Step 1: Check if the order is already reviewed**
  @override
  void initState() {
    super.initState();
    print('Received order: ${widget.order}'); // Debugging the received order
    if (widget.order['isReviewed'] == true) {
      // If already reviewed, notify the user and navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This order has already been reviewed.')),
        );
        Navigator.pop(context); // Go back
      });
    }
  }

  // **Step 2: Submit the review**
  Future<void> _submitReview() async {
    try {
      String comment = _commentController.text;
      final orderId = widget.order['orderId'];  // Check this value

      // Log the orderId to ensure it's not null
      print('Updating order with ID: $orderId');

      final reviewData = {
        'orderId' : widget.order['orderId'],
        'orderNumber': widget.order['orderNumber'],
        'total': widget.order['total'],
        'products': widget.order['products'],
        'rating': _rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add review to 'reviews' collection
      await _firestore.collection('reviews').add(reviewData);

      // Update the 'isReviewed' field
      await _firestore.collection('orders').doc(orderId).update({
        'isReviewed': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);  // Go back after submission
    } catch (e) {
      print('Error: $e');  // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }



  // **Step 6: Build the UI**
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final List<dynamic>? products = widget.order['products'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Review',
          style: GoogleFonts.poppins(
            color: Colors.indigo,
            fontSize: size.width * 0.065,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order details
            Row(
              children: [
                const Text(
                  'Order #',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                Text(
                  "${widget.order['orderNumber']}",
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                const Text(
                  'Price:',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                Text(
                  'Rs ${widget.order['total']}',
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(10),
            const Text(
              'Products',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Gap(10),
            // List of products
            Expanded(
              child: products != null
                  ? ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final productData = products[index] ?? {};
                  final product = productData['product'] ?? {};
                  final quantity = productData['quantity'] ?? 0;
                  final price = product['price'] ?? 0.0;
                  final imageUrl = product['image'] ?? '';

                  return _buildProductCard(
                    product: product,
                    quantity: quantity,
                    price: price,
                    imageUrl: imageUrl,
                    size: size,
                  );
                },
              )
                  : const Center(child: Text('No products available')),
            ),
            const Gap(10),
            const Text(
              'Product Review',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const Gap(10),
            // Rating bar
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.orange,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Tell us more (optional)',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Why this rating?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12.5),
                  backgroundColor: Colors.indigo,
                ),
                onPressed: _submitReview, // Submit review on button press
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Product card widget
  Widget _buildProductCard({
    required Map<String, dynamic> product,
    required int quantity,
    required double price,
    required String imageUrl,
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
            Image.network(
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
            SizedBox(width: size.width * 0.075),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Qty: $quantity",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "Rs$price",
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
