import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> order;

  ReviewPage({required this.order});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.order['isReviewed'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This order has already been reviewed.')),
        );
        Navigator.pop(context);
      });
    }
  }

  Future<void> _submitReview() async {
    try {
      String comment = _commentController.text;
      final orderId = widget.order['orderId'];
      final reviewData = {
        'orderId' : widget.order['orderId'],
        'orderNumber': widget.order['orderNumber'],
        'total': widget.order['total'],
        'products': widget.order['products'],
        'rating': _rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('reviews').add(reviewData);
      await _firestore.collection('orders').doc(orderId).update({
        'isReviewed': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final List<dynamic>? products = widget.order['products'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Review',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.indigo,
            fontSize: size.width * 0.065,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.indigo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: isDark ? Colors.indigoAccent : Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                Text(
                  "${widget.order['orderNumber']}",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                Text(
                  'Price:',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: isDark ? Colors.indigoAccent : Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                Text(
                  'Rs ${widget.order['total']}',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            const Gap(10),
            Text(
              'Products',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor),
            ),
            const Gap(10),
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
                    isDark: isDark,
                  );
                },
              )
                  : Center(child: Text('No products available', style: TextStyle(color: textColor))),
            ),
            const Gap(10),
            Text(
              'Product Review',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor),
            ),
            const Gap(10),
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
            Text(
              'Tell us more (optional)',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Why this rating?',
                hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
              ),
              style: TextStyle(color: textColor),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12.5),
                  backgroundColor:  isDark ? Colors.indigoAccent : Colors.indigo,

                ),
                onPressed: _submitReview,
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

  Widget _buildProductCard({
    required Map<String, dynamic> product,
    required int quantity,
    required double price,
    required String imageUrl,
    required Size size,
    required bool isDark,
  }) {
    return Card(
      color: isDark ? Colors.grey[850] : Colors.white,
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
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Qty: $quantity",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.grey[300] : Colors.black,
                    ),
                  ),
                  Text(
                    "Rs$price",
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
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
