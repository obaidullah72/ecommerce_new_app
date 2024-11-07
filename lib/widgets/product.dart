import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../provider/cart_provider.dart';
import '../provider/product_provider.dart';
import '../screens/product_screen.dart';

class ProductWidget extends StatefulWidget {
  final String name;
  final String price;
  final bool availability;
  final String imageUrl;
  final Product? product;
  int stock;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  ProductWidget({
    super.key,
    required this.name,
    required this.price,
    required this.availability,
    required this.imageUrl,
    this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.stock = 0,
  });

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  late bool isFavorited;
  double _cartIconScale = 1.0; // Initial scale for the cart icon

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFavorite; // Initialize favorite state
  }

  void _animateCartIcon() {
    setState(() {
      _cartIconScale = 1.5; // Scale up
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _cartIconScale = 1.0; // Scale back to original
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SizedBox(
        width: size.width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.product != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(
                            productId: widget.product!.id,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product not available")),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, size: 100, color: Colors.redAccent),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorited = !isFavorited; // Toggle favorite state
                    });
                    Provider.of<ProductProvider>(context, listen: false)
                        .toggleFavorite(widget.product!);
                  },
                ),
              ],
            ),
            SizedBox(height: size.height * 0.020),
            Text(
              widget.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: size.width * 0.033,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.availability ? const Color(0xFF03B680) : Colors.redAccent,
                  radius: 4,
                ),
                SizedBox(width: size.width * 0.020),
                Text(
                  widget.availability ? "Available" : "Out of Stock",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: size.width * 0.033,
                    color: widget.availability
                        ? const Color(0xFF03B680)
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.005),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rs ${widget.price}",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: size.width * 0.040,
                  ),
                ),
                if (widget.availability && widget.product != null)
                  GestureDetector(
                    onTap: () {
                      _animateCartIcon(); // Call animation method
                      context.read<CartProvider>().addToCart(widget.product!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "Item Added!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    child: AnimatedScale(
                      scale: _cartIconScale,
                      duration: const Duration(milliseconds: 100),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 13,
                        child: Icon(
                          CupertinoIcons.cart_fill_badge_plus,
                          size: size.width * 0.065,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (!widget.availability)
              const Text(
                'Out of stock',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
