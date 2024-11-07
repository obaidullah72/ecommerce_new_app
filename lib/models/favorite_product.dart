class FavoriteModel {
  String id; // Document ID
  String image; // Image URL
  String name;  // Product name
  double price; // Product price
  int stock;    // Available stock
  bool isFavorite; // Is the product marked as favorite

  FavoriteModel({
    required this.id, // Include the ID in the constructor
    required this.image,
    required this.name,
    required this.price,
    required this.stock,
    required this.isFavorite,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> data, String id) {
    return FavoriteModel(
      id: id, // Assign the ID
      image: data['image'] ?? '', // Default to empty string if null
      name: data['name'] ?? 'Unnamed Product', // Default value if null
      price: (data['price'] as num?)?.toDouble() ?? 0.0, // Default to 0 if null
      stock: data['stock'] ?? 0, // Default to 0 if null
      isFavorite: data['isFavorite'] ?? false, // Default to false if null
    );
  }
}
