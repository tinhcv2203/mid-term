import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mid_term/screen/loginScreen.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;
  String? _imageUrl;
  String fullName = "Cao Van Tinh";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Lấy full name của user từ Firestore
  void _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['fullName'] ?? user.email!;
        });
      }
    }
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Upload ảnh lên Firebase Storage và lấy URL
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child("products/$fileName.jpg");
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload image error: $e");
      return null;
    }
  }

  // Thêm hoặc chỉnh sửa sản phẩm
  void _addOrEditProduct({String? productId}) {
    if (productId != null) {
      _fetchProductDetails(productId);
    } else {
      _nameController.clear();
      _priceController.clear();
      _image = null;
      _imageUrl = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _image != null
                  ? Image.file(_image!, height: 100)
                  : _imageUrl != null
                  ? Image.network(_imageUrl!, height: 100)
                  : const Text("No Image Selected"),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
                onPressed: _pickImage,
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text;
                  final price = double.tryParse(_priceController.text) ?? 0;
                  if (name.isNotEmpty && price > 0) {
                    String? imageUrl = _image != null ? await _uploadImage(_image!) : _imageUrl;

                    if (productId == null) {
                      // Thêm sản phẩm mới
                      await _firestore.collection('products').add({
                        'name': name,
                        'price': price,
                        'imageUrl': imageUrl,
                        'userId': userId,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    } else {
                      // Cập nhật sản phẩm
                      await _firestore.collection('products').doc(productId).update({
                        'name': name,
                        'price': price,
                        'imageUrl': imageUrl,
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(productId == null ? 'Add Product' : 'Update Product'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Lấy thông tin sản phẩm khi chỉnh sửa
  void _fetchProductDetails(String productId) async {
    DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      setState(() {
        _nameController.text = doc['name'];
        _priceController.text = doc['price'].toString();
        _imageUrl = doc['imageUrl'];
        _image = null;
      });
    }
  }

  // Xóa sản phẩm
  void _deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const loginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Welcome, $fullName!", style: const TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').where('userId', isEqualTo: userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        leading: product['imageUrl'] != null
                            ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 50),
                        title: Text(product['name']),
                        subtitle: Text("Price: \$${product['price']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _addOrEditProduct(productId: product.id)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(product.id)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _addOrEditProduct(), child: const Icon(Icons.add)),
    );
  }
}
