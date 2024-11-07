import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/favorite_product.dart';
import '../widgets/customdrawer.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteModel> favouriteProducts = [];
  List<FavoriteModel> allProducts = []; // To store all products

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _fetchFavouriteProducts(); // Fetch products from Firebase
  }

  Future<List<FavoriteModel>> _fetchFavouriteProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('isFavorite', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Pass the document ID to the FavoriteModel
      return FavoriteModel.fromMap(data, doc.id); // Get the ID using doc.id
    }).toList();
  }


  void _filterProducts() {
    setState(() {
      favouriteProducts = allProducts
          .where((product) => product.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _removeFromFavorites(FavoriteModel product) async {
    await FirebaseFirestore.instance
        .collection('favorites') // Replace with your Firestore collection name
        .doc(product.id) // Assuming you have an 'id' field for the document ID
        .update({
      'isFavorite': false
    }); // Update the document to remove from favorites

    setState(() {
      favouriteProducts.remove(product); // Remove from the local list
      allProducts.remove(product); // Remove from the allProducts list
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Favourite Products",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.050,
                color: Colors.indigo,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search Favorites...",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: size.width * 0.040,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.030),
              Expanded(
                child: FutureBuilder<List<FavoriteModel>>(
                  future: _fetchFavouriteProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No favorite products found."));
                    }

                    favouriteProducts = snapshot.data!; // Use FavoriteModel

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: favouriteProducts.length,
                      itemBuilder: (context, index) {
                        final product = favouriteProducts[index];
                        return Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white54,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white60,
                                spreadRadius: 0.5,
                                offset: Offset(5, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Image.network( // Use Image.network for URLs
                                product.image,
                                fit: BoxFit.contain,
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    product.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: size.width * 0.033,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$ ${product.price}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: size.width * 0.040,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _removeFromFavorites(product); // Remove from favorites
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
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
