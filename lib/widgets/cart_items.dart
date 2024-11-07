import 'package:ecommerce_new_app/provider/cart_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';

class CartItem extends StatefulWidget {
  final CartModel cartItem;

  const CartItem({super.key, required this.cartItem});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Product Image with improved Firebase handling
          Container(
            width: size.width * 0.15,
            height: size.width * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                widget.cartItem.product.image, // Firebase image URL
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 24,
                  );
                },
              ),
            ),
          ),

          // Product Details and Quantity Controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.cartItem.product.name,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),

                  // Product Price
                  Text(
                    "Rs ${widget.cartItem.product.price}",
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  // Quantity Controls
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context
                              .read<CartProvider>()
                              .incrementQty(widget.cartItem.id);
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Iconsax.add,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Text(
                        widget.cartItem.quantity.toString(),
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(width: 13),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<CartProvider>()
                              .decrimentQty(widget.cartItem.id);
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Iconsax.minus,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Delete Button
          GestureDetector(
            onTap: () {
              context.read<CartProvider>().removeItem(widget.cartItem.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 247, 247, 247),
                  content: Text(
                    "Item Removed",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.redAccent.withOpacity(0.07),
              radius: 18,
              child: const Icon(
                CupertinoIcons.delete_solid,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
