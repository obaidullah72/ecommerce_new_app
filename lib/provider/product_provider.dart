import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _shirts = [];
  final List<Product> _pants = [];
  final List<Product> _shoes = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _favoriteProducts = [];
  List<Product> get favoriteProducts => _favoriteProducts;

  ProductProvider() {
    fetchProductsFromFirestore(); // Load products when the provider is initialized
  }

  // Function to toggle favorite status of a product
  Future<void> toggleFavorite(Product product) async {
    final favoritesRef = _firestore.collection('favorites');

    if (product.isFavorite) {
      // Remove from favorites
      await favoritesRef.doc(product.id).delete();
      product.isFavorite = false; // Update the product model
    } else {
      // Add to favorites
      await favoritesRef.doc(product.id).set({
        'id': product.id,
        'name': product.name,
        'image': product.image,
        'price': product.price,
        'stock': product.stock,
        'isFavorite': true,
        // Include other fields if necessary
      });
      product.isFavorite = true; // Update the product model
    }

    // Refresh the favorite products list
    await fetchFavoriteProducts();
    notifyListeners(); // Notify listeners about the changes
  }

  // Fetch favorite products from Firestore
  Future<void> fetchFavoriteProducts() async {
    final favoritesRef = _firestore.collection('favorites');
    final snapshot = await favoritesRef.get();

    _favoriteProducts = snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        stock: data['stock'] ?? 0,
        isFavorite: true,
        description: data['description'] ?? '',
        colors: List<String>.from(data['colors'] ?? []), // Safely convert to List<String>
        sizes: List<String>.from(data['sizes'] ?? []), // Safely convert to List<String>
        isAvailable: data['isAvailable'] ?? '',
      );
    }).toList();

    notifyListeners();
  }


  // Fetch products from Firestore
  Future<void> fetchProductsFromFirestore() async {
    try {
      await fetchCategoryProducts('Shirts', _shirts);
      await fetchCategoryProducts('Pants', _pants);
      await fetchCategoryProducts('Shoes', _shoes);
      await fetchFavoriteProducts(); // Fetch favorite products on initialization
      notifyListeners();
    } catch (e) {
      print("Error fetching products: $e"); // Handle error appropriately
    }
  }

  // Generic method to fetch products by category
  Future<void> fetchCategoryProducts(String category, List<Product> productList) async {
    QuerySnapshot productSnapshot = await _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .get();

    productList.clear();
    for (var doc in productSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add the document ID to the map data

      // Use the factory constructor to create the Product instance
      productList.add(Product.fromMap(data));
    }
  }

  // Getters to access the lists
  List<Product> get shirts => _shirts;
  List<Product> get pants => _pants;
  List<Product> get shoes => _shoes;

  // Optional: Get all products if needed
  List<Product> get allProducts {
    return [..._shirts, ..._pants, ..._shoes];
  }
}
