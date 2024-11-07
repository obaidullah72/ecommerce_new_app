import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'package:ecommerce_new_app/provider/cart_provider.dart';
import 'package:ecommerce_new_app/widgets/cart_items.dart';
import 'extrascreen/orderconfirmationscreen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final cartProvider = context.watch<CartProvider>();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShippingMessage(size, cartProvider),
              Expanded(child: _buildCartItems(cartProvider, size)),
              SizedBox(height: size.height * 0.02),
              _buildOrderInfoAndCheckout(cartProvider, size, context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget: Shipping message
  Widget _buildShippingMessage(Size size, CartProvider cartProvider) {
    return cartProvider.shoppingCart.isNotEmpty &&
            cartProvider.cartSubTotal < 2500
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Shipping charges are free for orders over Rs 2500!",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  // Helper widget: Cart Items List
  Widget _buildCartItems(CartProvider cartProvider, Size size) {
    if (cartProvider.shoppingCart.isEmpty) {
      return _buildEmptyCart(size);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'My Cart',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w500,
                color: Colors.indigo,
              ),
            ),
          ),
          ...cartProvider.shoppingCart.map(
            (cartItem) => CartItem(cartItem: cartItem),
          ),
        ],
      ),
    );
  }

  // Helper widget: Empty Cart Message
  Widget _buildEmptyCart(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.bag,
            size: size.width * 0.20,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            "Your Cart is Empty!",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper widget: Order Info and Checkout Button
  Widget _buildOrderInfoAndCheckout(
      CartProvider cartProvider, Size size, BuildContext context) {
    if (cartProvider.shoppingCart.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Info",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: size.width * 0.040,
          ),
        ),
        const SizedBox(height: 10),
        _buildOrderRow("SubTotal:", cartProvider.cartSubTotal, size),
        _buildOrderRow("Shipping Fee:", cartProvider.shippingCharge, size),
        const SizedBox(height: 15),
        _buildOrderRow("Total:", cartProvider.cartTotal, size, isBold: true),
        const SizedBox(height: 30),
        _buildCheckoutButton(cartProvider, size, context),
      ],
    );
  }

  // Helper widget: Order Row
  Widget _buildOrderRow(String label, double amount, Size size,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          "Rs ${amount.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Helper widget: Checkout Button
  Widget _buildCheckoutButton(
      CartProvider cartProvider, Size size, BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height * 0.065,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(
                subTotal: cartProvider.cartSubTotal,
                shippingch: cartProvider.shippingCharge,
                cartItems: cartProvider.shoppingCart,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Center(
          child: Text(
            "Checkout Rs${cartProvider.cartTotal.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
