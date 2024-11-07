import 'dart:io'; // Import to use File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_textfield.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(); // Price Controller
  XFile? _imageFile; // Store selected image
  String? _selectedCategory; // Store selected category
  int? _selectedStock; // Store selected stock

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Sample data for dropdowns
  final List<String> _colors = ['Red', 'Blue', 'Green', 'Black', 'White'];
  final List<String> _categories = ['Shirts', 'Pants', 'Shoes'];
  final List<String> _shoesSizes = ['5', '6', '7', '8', '9']; // Sizes for shoes
  final List<String> _shirtPantsSizes = ['S', 'M', 'L', 'XL', 'XXL']; // Sizes for shirts and pants
  final List<int> _stocks = List.generate(101, (index) => index); // Generates stock from 0 to 100

  // Store selected colors and sizes
  List<String> _selectedColors = [];
  List<String> _selectedSizes = [];

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      String name = _nameController.text.trim();
      String description = _descriptionController.text.trim();
      double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      // Generate a unique ID for the product
      String productId = FirebaseFirestore.instance.collection('products').doc().id;

      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImageToStorage(_imageFile!, productId);

      // Create a new product object with the unique ID
      Map<String, dynamic> productData = {
        'id': productId,
        'name': name,
        'description': description,
        'image': imageUrl,
        'price': price,
        'category': _selectedCategory,
        'colors': _selectedColors.map((color) => _convertColorToHex(color)).toList(), // Convert selected colors to hex strings
        'sizes': _selectedSizes, // Store selected sizes as a list
        'stock': _selectedStock,
        'isFavorite': false,
        // 'isAvailable': true,
      };

      try {
        // Add the product to Firestore using the unique ID
        await FirebaseFirestore.instance.collection('products').doc(productId).set(productData);
        _showSnackBar('Product added successfully!');
        _clearForm();
      } catch (e) {
        _showSnackBar('Failed to add product: $e');
      }
    } else {
      _showSnackBar('Please select an image to upload.');
    }
  }

  // Helper method to convert color name to hex string
  String _convertColorToHex(String? colorName) {
    switch (colorName) {
      case 'Red':
        return '0xFFFF0000'; // ARGB format
      case 'Green':
        return '0xFF00FF00'; // ARGB format
      case 'Blue':
        return '0xFF0000FF'; // ARGB format
      case 'Black':
        return '0xFF000000'; // ARGB format
      case 'White':
        return '0xFFFFFFFF'; // ARGB format
      default:
        return '0xFFFFFFFF'; // Default to white if not recognized
    }
  }

  Future<String> _uploadImageToStorage(XFile image, String productId) async {
    // Define the path to store the image
    Reference ref = FirebaseStorage.instance.ref().child('products/$productId/${image.name}');

    // Upload the file
    await ref.putFile(File(image.path));

    // Get the download URL
    String downloadUrl = await ref.getDownloadURL();

    return downloadUrl; // Return the download URL
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear(); // Clear the price controller
    setState(() {
      _selectedCategory = null; // Clear selected category
      _selectedStock = null; // Clear selected stock
      _selectedColors.clear(); // Clear selected colors
      _selectedSizes.clear(); // Clear selected sizes
      _imageFile = null; // Clear selected image
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery, // or ImageSource.camera
        imageQuality: 80,
      );

      if (selectedImage != null) {
        setState(() {
          _imageFile = selectedImage; // Update the selected image
        });
      } else {
        _showSnackBar('No image selected.'); // Inform the user
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e'); // Handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: GoogleFonts.poppins(
            color: Colors.indigo,
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Product Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Product Description',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New Price Input Field
                CustomTextField(
                  controller: _priceController,
                  labelText: 'Product Price',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Product Category',
                    labelStyle: GoogleFonts.poppins(color: Colors.indigo),
                    border: const OutlineInputBorder(),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: const TextStyle(color: Colors.indigo)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSizes.clear(); // Clear previously selected sizes
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a product category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sizes Selection Section based on category
                Text('Select Sizes', style: GoogleFonts.poppins(color: Colors.indigo)),
                if (_selectedCategory == 'Shoes') ..._shoesSizes.map((size) {
                  return CheckboxListTile(
                    title: Text(size, style: const TextStyle(color: Colors.indigo)),
                    value: _selectedSizes.contains(size),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _selectedSizes.add(size); // Add size if checked
                        } else {
                          _selectedSizes.remove(size); // Remove size if unchecked
                        }
                      });
                    },
                  );
                }).toList()
                else ..._shirtPantsSizes.map((size) {
                  return CheckboxListTile(
                    title: Text(size, style: const TextStyle(color: Colors.indigo)),
                    value: _selectedSizes.contains(size),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _selectedSizes.add(size); // Add size if checked
                        } else {
                          _selectedSizes.remove(size); // Remove size if unchecked
                        }
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Colors Selection Section
                Text('Select Colors', style: GoogleFonts.poppins(color: Colors.indigo)),
                ..._colors.map((color) {
                  return CheckboxListTile(
                    title: Text(color, style: const TextStyle(color: Colors.indigo)),
                    value: _selectedColors.contains(color),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _selectedColors.add(color); // Add color if checked
                        } else {
                          _selectedColors.remove(color); // Remove color if unchecked
                        }
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Stock Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedStock,
                  decoration: InputDecoration(
                    labelText: 'Product Stock',
                    labelStyle: GoogleFonts.poppins(color: Colors.indigo),
                    border: const OutlineInputBorder(),
                  ),
                  items: _stocks.map((int stock) {
                    return DropdownMenuItem<int>(
                      value: stock,
                      child: Text(stock.toString(), style: const TextStyle(color: Colors.indigo)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStock = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select the stock quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextButton.icon(onPressed: _pickImage, label: const Text('Pick an Image'), icon: const Icon(Icons.image),),
                // Image Picker Button
                // ElevatedButton(
                //   onPressed: _pickImage,
                //   child: const Text('Pick an Image'),
                // ),
                const SizedBox(height: 16),

                // Display the selected image
                _imageFile != null
                    ? Image.file(File(_imageFile!.path), height: 150)
                    : const Text('No image selected', style: TextStyle(color: Colors.red)),

                const SizedBox(height: 16),

                // Add Product Button
                ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
