import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_new_app/screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../productdata/addproduct.dart';
import '../provider/product_provider.dart';
import '../widgets/customdrawer.dart';
import '../widgets/category_header.dart';
import '../widgets/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.product});

  final Product? product; // Nullable to handle null case

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentPage = 0;

  late List<AnimationController> _categoryAnimationControllers;

  @override
  void initState() {
    super.initState();

    // Number of categories should be defined
    _categoryAnimationControllers = List.generate(
      3, // Adjust based on actual number of categories
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    for (int i = 0; i < _categoryAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 2000), () {
        _categoryAnimationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _categoryAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Error fetching user data")),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        // Check for user's first name and assign a default value if not available
        String firstName = userData?['first_name'] ?? "First";
        String email = userData?['email'] ?? "";

        return SafeArea(
          child: Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Shop Now",
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.050,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "GOOD DAY $firstName",
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  // Conditional IconButton based on email check
                  if (email == 'obaidullahman7@gmail.com')
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddProductScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.indigo),
                    ),
                  // CircleAvatar
                  CircleAvatar(
                    backgroundImage: userData?['image_url'] != null
                        ? NetworkImage(userData!['image_url'])
                        : const AssetImage('assets/profile3.jpg')
                    as ImageProvider,
                    maxRadius: 25,
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slider Section
                    buildSlider(size),
                    SizedBox(height: size.height * 0.03),
                    // Animated Category and Products from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No products found"));
                    }

                    // Mapping Firestore documents into product list
                    var products = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;

                      // Debugging: Print each product data to check null values
                      print("Product data: $data");

                      // Safely check if fields exist and are not null, otherwise use defaults
                      String name = data['name'] ?? 'Unnamed Product';
                      String image = data['image'] ?? 'assets/default_image.png'; // Use a local placeholder image for null cases
                      String category = data['category'] ?? 'Unknown Category';
                      double price = (data['price'] != null) ? data['price'] as double : 0.0;
                      int stock = (data['stock'] != null) ? data['stock'] as int : 0;
print(name);
                      print(image);
                      print(category);
                      print(price);
                      print(stock);

                      // Return a product map with necessary fields checked for null
                      return {
                        'name': name,
                        'image': image,
                        'category': category,
                        'price': price,
                        'stock': stock,
                        'id': doc.id, // Include the document ID
                      };
                    }).toList();

                    // Debug: Print the final list of products
                    print("Final list of products: $products");

                    return Column(
                      children: [
                        animatedCategorySection(
                          "T-Shirts",
                          products
                              .where((p) => p['category'] == 'Shirts')
                              .toList(),
                          0,
                        ),
                        SizedBox(height: size.height * 0.020),
                        animatedCategorySection(
                          "Cotton Pants",
                          products
                              .where((p) => p['category'] == 'Pants')
                              .toList(),
                          1,
                        ),
                        SizedBox(height: size.height * 0.020),
                        animatedCategorySection(
                          "Nike Shoes",
                          products
                              .where((p) => p['category'] == 'Shoes')
                              .toList(),
                          2,
                        ),
                      ],
                    );
                  },
                ),
                    // StreamBuilder<QuerySnapshot>(
                    //   stream: FirebaseFirestore.instance
                    //       .collection('products')
                    //       .snapshots(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       return const Center(child: CircularProgressIndicator());
                    //     }
                    //
                    //     if (!snapshot.hasData) {
                    //       return const Center(child: Text("No products found"));
                    //     }
                    //
                    //     // Print the number of documents retrieved
                    //     print("Number of products: ${snapshot.data!.docs.length}");
                    //
                    //     // Handle cases where fields might be missing or null
                    //     var products = snapshot.data!.docs.map((doc) {
                    //       var data = doc.data() as Map<String, dynamic>;
                    //
                    //       // Ensure product data fields exist or provide default values
                    //       String name = data['name'] ?? 'Unnamed Product';
                    //       String image = data['image'] ?? 'assets/default_image.png';
                    //       String category = data['category'] ?? 'Unknown Category';
                    //       data['id'] = doc.id; // Include the document ID
                    //
                    //       // Returning only valid products
                    //       return {
                    //         'name': name,
                    //         'image': image,
                    //         'category': category,
                    //         'id': doc.id,
                    //         'price': data['price'] ?? 'N/A',
                    //         'stock': data['stock'] ?? 0,
                    //       };
                    //     }).toList();
                    //
                    //     print("Retrieved products: $products");
                    //
                    //     return Column(
                    //       children: [
                    //         animatedCategorySection(
                    //           "T-Shirts",
                    //           products.where((p) => p['category'] == 'Shirts').toList(),
                    //           0,
                    //         ),
                    //         SizedBox(height: size.height * 0.020),
                    //         animatedCategorySection(
                    //           "Cotton Pants",
                    //           products.where((p) => p['category'] == 'Pants').toList(),
                    //           1,
                    //         ),
                    //         SizedBox(height: size.height * 0.020),
                    //         animatedCategorySection(
                    //           "Nike Shoes",
                    //           products.where((p) => p['category'] == 'Shoes').toList(),
                    //           2,
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Slider Widget
  Widget buildSlider(Size size) {
    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.2,
          child: PageView.builder(
            itemCount: 3,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/cover.jpg",
                    height: size.height * 0.2,
                    width: size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => buildDot(index, size)),
          ),
        ),
      ],
    );
  }

  // Dot indicator for the slider
  Widget buildDot(int index, Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 5),
      height: size.height * 0.01,
      width: _currentPage == index ? size.width * 0.03 : size.width * 0.01,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.indigo : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  // Helper function to create Animated Category Section
// Helper function to create Animated Category Section
  Widget animatedCategorySection(String title, List<Map<String, dynamic>> products, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _categoryAnimationControllers[index],
              curve: Curves.easeInOut,
            ),
          ),
          child: CategoryHeader(
            title: title,
            count: '    ${products.length}',
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _categoryAnimationControllers[index],
              curve: Curves.easeInOut,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: products.map((productMap) {
                // Validate fields before using them
                String name = productMap['name'] ?? 'Unnamed Product';
                String price = (productMap['price'] != null) ? productMap['price'].toString() : '0.0';
                String imageUrl = productMap['image'] ?? 'assets/default_image.png';
                String productId = productMap['id'] ?? '';

                int stock = productMap['stock'] ?? 0;
                bool availability = stock > 0;

                // Assuming you have a Product class that can be instantiated from a Map
                Product product = Product.fromMap(productMap); // Create Product instance

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen(
                          productId: productId,
                        ),
                      ),
                    );
                  },
                  child: ProductWidget(
                    name: name,
                    price: price, // Now a String
                    availability: availability,
                    imageUrl: imageUrl,
                    product: product, // Pass Product instance
                    isFavorite: productMap['isFavorite'] ?? false,
                    onFavoriteToggle: () {
                      context.read<ProductProvider>().toggleFavorite(product);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
