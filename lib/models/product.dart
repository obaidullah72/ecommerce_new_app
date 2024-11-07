class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final List<String> colors;
  final List<String> sizes;
  bool isFavorite;
  bool isAvailable; // Add this line

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.colors,
    required this.sizes,
    this.isFavorite = false,
    this.isAvailable = true, // Initialize default value
  });

  // Factory method to create a Product from a map
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      image: data['image'],
      price: (data['price'] as num).toDouble(),
      colors: List<String>.from(data['colors'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      isAvailable: data['isAvailable'] ?? true, // Add this line
    );
  }

  // Method to convert Product to map if needed for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'colors': colors,
      'sizes': sizes,
      'isFavorite': isFavorite,
      'isAvailable': isAvailable, // Add this line
    };
  }
}
