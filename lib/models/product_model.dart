class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  int stock;
  final double price;
  List<String> colors;
  List<String> sizes;
  bool isFavorite;
  bool isAvailable; // Availability based on stock

  Product({
    required this.id,
    required this.name,
    this.description = '', // Default description
    required this.image,
    this.stock = 0,
    required this.price,
    this.colors = const [], // Default to empty list
    this.sizes = const [],  // Default to empty list
    this.isFavorite = false,
    bool? isAvailable, // Optional parameter, derived from stock
  }) : isAvailable = isAvailable ?? stock > 0; // Derived value

  // Factory method to create a Product from a map
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '', // Ensure 'id' is not null
      name: data['name'] ?? 'Unnamed Product', // Fallback if name is missing
      description: data['description'] ?? '',
      image: data['image'] ?? 'assets/default_image.png', // Default image
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0, // Convert to double
      stock: data['stock'] ?? 0,
      colors: (data['colors'] is List) ? List<String>.from(data['colors']) : [], // Ensure List<String>
      sizes: (data['sizes'] is List) ? List<String>.from(data['sizes']) : [],   // Ensure List<String>
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // Convert Product to map, useful for Firestore operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'stock': stock,
      'colors': colors,
      'sizes': sizes,
      'isFavorite': isFavorite,
      'isAvailable': stock > 0, // Availability logic
    };
  }
}
