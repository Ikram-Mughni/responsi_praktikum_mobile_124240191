import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product_model.dart';

class FavoriteController extends GetxController {
  final RxList<ProductModel> _favorites = <ProductModel>[].obs;
  List<ProductModel> get favorites => _favorites;

  late Box _wishlistBox;

  @override
  void onInit() {
    super.onInit();
    _wishlistBox = Hive.box('wishlistBox');
    loadFavorites();
  }

  // Key penyimpanan per user di Hive
  Future<String> _getWishlistKey() async {
    final prefs = await SharedPreferences.getInstance();
    final String currentUser = prefs.getString('currentUser') ?? 'guest';
    return 'wishlist_$currentUser';
  }

  // Load data wishlist dari Local Database (Hive)
  Future<void> loadFavorites() async {
    final key = await _getWishlistKey();
    final rawData = _wishlistBox.get(key);

    _favorites.clear();
    if (rawData != null) {
      try {
        final List<dynamic> decoded = (rawData is String) ? jsonDecode(rawData) : rawData;
        _favorites.assignAll(
          decoded.map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item))).toList(),
        );
      } catch (e) {
        _favorites.clear();
      }
    }
  }

  // Simpan data wishlist ke Local Database (Hive) agar persisten saat aplikasi ditutup
  Future<void> _saveFavorites() async {
    final key = await _getWishlistKey();
    final encoded = _favorites.map((e) => e.toJson()).toList();
    await _wishlistBox.put(key, encoded);
  }

  bool isFavorite(int id) {
    return _favorites.any((product) => product.id == id);
  }

  void toggleFavorite(ProductModel product) {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((item) => item.id == product.id);
      _saveFavorites();
      // SnackBar berwarna merah saat produk dihapus dari wishlist
      Get.snackbar(
        'Wishlist',
        '${product.title} dihapus dari wishlist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.favorite_border, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    } else {
      _favorites.add(product);
      _saveFavorites();
      Get.snackbar(
        'Wishlist',
        '${product.title} ditambahkan ke wishlist!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.favorite, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeFavorite(ProductModel product) {
    _favorites.removeWhere((item) => item.id == product.id);
    _saveFavorites();
    Get.snackbar(
      'Wishlist',
      '${product.title} dihapus dari wishlist.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.delete_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  // Reset state wishlist (misal saat logout)
  void clearState() {
    _favorites.clear();
  }
}
