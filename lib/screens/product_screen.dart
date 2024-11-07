import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import '../provider/cart_provider.dart';
import '../provider/product_provider.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Color selectedColor = Colors.redAccent; // Default selected color
  String selectedSize = ''; // Updated to String to match the Product model
  late Future<DocumentSnapshot> productFuture;
  Product? productModel;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    // Fetch the product details from Firestore based on the productId
    productFuture = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  if (productModel != null) {
                    // Toggle the favorite state
                    context.read<ProductProvider>().toggleFavorite(
                        productModel!);
                    setState(() {
                      productModel!.isFavorite = !productModel!.isFavorite;
                    });
                  }
                },
                child: Icon(
                  productModel != null && productModel!.isFavorite
                      ? Icons.favorite // Filled heart icon
                      : Icons.favorite_border, // Bordered heart icon
                  size: size.width * 0.07,
                  color: productModel != null && productModel!.isFavorite
                      ? Colors.red // Red color if favorite
                      : Colors.black, // Black if not favorite
                ),
              ),
            ),
          ],
        ),

        body: FutureBuilder<DocumentSnapshot>(
          future: productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Product not found"));
            }

            // Create a Product instance using the fromMap factory
            productModel =
                Product.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        productModel!.image,
                        height: size.height / 3,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 100);
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.020),
                    Text(
                      "New Arrivals",
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: size.width * 0.04),
                    ),
                    Text(
                      productModel!.name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: size.width * 0.07),
                    ),
                    SizedBox(height: size.height * 0.020),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Save Color Button
                        Container(
                          width: size.width / 4,
                          height: size.height * 0.04,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "Save Product",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: size.height * 0.015,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Ratings and Reviews
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 25),
                            Text(
                              "5",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: size.height * 0.03),
                            ),
                            Text(
                              " 48 Reviews",
                              style: GoogleFonts.poppins(
                                color: Colors.black45,
                                fontWeight: FontWeight.w600,
                                fontSize: size.height * 0.015,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      "Information",
                      style: GoogleFonts.poppins(
                          fontSize: size.height * 0.023,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      productModel!.description,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: size.width * 0.037),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Colors Section
                    buildColorSection(productModel!),
                    SizedBox(height: size.height * 0.02),
                    // Sizes Section
                    buildSizeSection(productModel!),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: productModel != null
            ? buildBottomNavBar(productModel!, size, context)
            : const SizedBox(),
      ),
    );
  }


  /// Builds the color selection section.
  Widget buildColorSection(Product productModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Color:",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 30,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: productModel.colors.length,
            itemBuilder: (context, index) {
              String colorString = productModel.colors[index];
              Color color = Color(int.parse(colorString));
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: selectedColor == color ? Colors.black54 : Colors
                          .transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the size selection section.
  Widget buildSizeSection(Product productModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Size:",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 30,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: productModel.sizes.length,
            itemBuilder: (context, index) {
              String size = productModel.sizes[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSize = size; // Store selected size as String
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    border: Border.all(
                      color: selectedSize == size ? Colors.black54 : Colors
                          .transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(child: Text(size,
                    style: const TextStyle(fontSize: 12),)), // Display the size
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the bottom navigation bar with price and Add to Cart button.
  Widget buildBottomNavBar(Product productModel, Size size,
      BuildContext context) {
    return Container(
      height: size.height * 0.08,
      margin: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Display
          Column(
            children: [
              Text(
                "Price: ",
                style: GoogleFonts.poppins(
                    color: Colors.black54, fontSize: size.width * 0.04),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "Rs ${productModel.price.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          // Add to Cart Button or Out of Stock Indicator
          productModel.isAvailable
              ? Center(
            child: SizedBox(
              width: size.width / 2,
              height: size.height * 0.06,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(productModel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                child: Text(
                  "Add to cart",
                  style: GoogleFonts.poppins(
                      fontSize: size.height * 0.018,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          )
              : Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Out of stock",
              style: GoogleFonts.poppins(
                  color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
