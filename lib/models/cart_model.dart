
import 'package:uuid/uuid.dart';

import 'product_model.dart';

var uuid = const Uuid();

class CartModel {
  final String id;
  final Product product;

  int quantity;

  CartModel({
    required this.product,
    required this.quantity,
  }) : id = uuid.v4();

  // Convert CartModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(), // Assuming Product also has a toMap() method
      'quantity': quantity,
    };
  }
}
