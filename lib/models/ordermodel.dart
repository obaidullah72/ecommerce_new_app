import 'package:uuid/uuid.dart';

import 'cart_model.dart';

var uuid = const Uuid();

class OrderModel {
  final String orderId;
  final String shippingName;
  final String shippingAddress;
  final List<CartModel> cartItems;
  final double subTotal;
  final double shippingFee;
  final double discountAmount;
  final double totalPayment;
  final String paymentMethod;

  OrderModel({
    required this.shippingName,
    required this.shippingAddress,
    required this.cartItems,
    required this.subTotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.totalPayment,
    required this.paymentMethod,
  }) : orderId = uuid.v4(); // Generate a unique order ID

  // Convert OrderModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'shippingName': shippingName,
      'shippingAddress': shippingAddress,
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'subTotal': subTotal,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'totalPayment': totalPayment,
      'paymentMethod': paymentMethod,
    };
  }
}
