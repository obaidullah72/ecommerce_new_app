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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'My Reviews',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.indigoAccent : Colors.indigo,
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
            return Center(child: Text('No reviews found.', style: TextStyle(color: textColor)));
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
                child: _buildReviewCard(review, cardColor, textColor),
              );
            },
          );
        },
      ),
    );
  }

  // Widget to build individual review cards
  Widget _buildReviewCard(Map<String, dynamic> review, Color cardColor, Color textColor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #${review['orderNumber']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rs ${review['total']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                ),
                _buildStarRating(review['rating']?.toDouble() ?? 0),
              ],
            ),
            const Gap(8),
            Text(
              'Comment: ${review['comment'] ?? 'No comment provided'}',
              style: TextStyle(fontSize: 14, color: textColor),
            ),
            const Gap(8),
            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildProductList(review['products'], textColor),
            const Gap(8),
            Text(
              'Reviewed on: ${_formatTimestamp(review['timestamp'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
  List<Widget> _buildProductList(List<dynamic>? products, Color textColor) {
    if (products == null || products.isEmpty) {
      return [Text('No products available.', style: TextStyle(color: textColor))];
    }

    return products.map((productData) {
      final product = productData['product'] ?? {};
      final quantity = productData['quantity'] ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product['name'] ?? 'Unknown', style: TextStyle(color: textColor)),
            Text('Qty: $quantity', style: TextStyle(color: textColor)),
          ],
        ),
      );
    }).toList();
  }
}
