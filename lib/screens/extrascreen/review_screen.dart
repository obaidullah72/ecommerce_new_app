import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'detailed_pages/detailreview.dart';

class ReviewListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReviewListPage({super.key});

  // Fetch reviews from Firestore
  Stream<QuerySnapshot> getReviews() {
    return _firestore.collection('reviews').orderBy('timestamp', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Reviews',
          style: GoogleFonts.poppins(
            color: Colors.indigo,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews found.'));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  // Navigate to the detailed review screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedReviewScreen(review: review),
                    ),
                  );
                },
                child: _buildReviewCard(review),
              );
            },
          );
        },
      ),
    );
  }

  // Widget to build individual review cards
  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #${review['orderNumber']}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rs ${review['total']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                _buildStarRating(review['rating']?.toDouble() ?? 0),
              ],
            ),
            const Gap(8),
            Text(
              'Comment: ${review['comment'] ?? 'No comment provided'}',
              style: const TextStyle(fontSize: 14),
            ),
            const Gap(8),
            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildProductList(review['products']),
            const Gap(8),
            Text(
              'Reviewed on: ${_formatTimestamp(review['timestamp'])}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Function to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm:ss a').format(dateTime); // Format to "h:mm:ss a"
  }

  // Widget to display rating with half-stars
  Widget _buildStarRating(double rating) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.orange,
      ),
      itemCount: 5,
      itemSize: 24.0,
      direction: Axis.horizontal,
    );
  }

  // Generate a list of product details from the review data
  List<Widget> _buildProductList(List<dynamic>? products) {
    if (products == null || products.isEmpty) {
      return [const Text('No products available.')];
    }

    return products.map((productData) {
      final product = productData['product'] ?? {};
      final quantity = productData['quantity'] ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product['name'] ?? 'Unknown'),
            Text('Qty: $quantity'),
          ],
        ),
      );
    }).toList();
  }
}
