import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailedReviewScreen extends StatelessWidget {
  final Map<String, dynamic> review;

  const DetailedReviewScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? (Colors.grey[800] ?? Colors.grey) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          "Order Review Details",
          style: GoogleFonts.poppins(
            color: Colors.indigo,
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
              "Order #${review['orderNumber']}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Order Date: ${_formatTimestamp(review['timestamp'])}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const Gap(10),
            Text(
              "Total Amount: Rs ${review['total']}",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            const Gap(10),
            _buildStarRating(review['rating']?.toDouble() ?? 0, size, textColor),
            const Gap(20),
            Text(
              "Products:",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: review['products']?.length ?? 0,
                itemBuilder: (context, index) {
                  final productData = review['products']?[index];
                  final product = productData['product'];
                  final quantity = productData['quantity'];
                  final price = product['price'];
                  final imageUrl = product['image'];

                  return _buildProductCard(
                    product: product,
                    quantity: quantity,
                    price: price,
                    imageUrl: imageUrl,
                    size: size,
                    cardColor: cardColor,
                    textColor: textColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (review['comment']?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                child: Card(
                  elevation: 3,
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Comment:",
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review['comment'] ?? 'No comment provided.',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required Map<String, dynamic> product,
    required int quantity,
    required double price,
    required String imageUrl,
    required Size size,
    required Color cardColor,
    required Color textColor,
  }) {
    return Card(
      color: cardColor,
      margin: EdgeInsets.only(bottom: size.height * 0.01),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Qty: $quantity",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rs $price",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                      color: textColor,
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd, yyyy - h:mm:ss a').format(dateTime);
  }

  Widget _buildStarRating(double rating, Size size, Color textColor) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.orange,
          ),
          itemCount: 5,
          itemSize: size.width * 0.06,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 10),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
