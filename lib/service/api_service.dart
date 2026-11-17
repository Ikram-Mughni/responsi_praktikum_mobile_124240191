import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';

  // 1. Ambil daftar produk (minimal 10 produk)
  static Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> products = data['products'] ?? [];
        return products.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat produk (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi API: $e');
    }
  }

  // 2. Ambil detail satu produk berdasarkan ID: GET /products/{id}
  static Future<ProductModel> getSingleProduct(int productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$productId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail produk (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi API: $e');
    }
  }

  // 3. Ambil seluruh kategori dari API: GET /products/category-list
  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/category-list'));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) {
            if (item is String) {
              return item;
            } else if (item is Map) {
              return item['slug']?.toString() ?? item['name']?.toString() ?? '';
            }
            return item.toString();
          }).where((cat) => cat.isNotEmpty).toList();
        }
        return [];
      } else {
        throw Exception('Gagal memuat kategori (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat kategori: $e');
    }
  }

  // 4. Ambil produk berdasarkan kategori terpilih
  static Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/category/$category'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> products = data['products'] ?? [];
        return products.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat kategori $category (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi API: $e');
    }
  }

  // 5. Pencarian produk
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> products = data['products'] ?? [];
        return products.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mencari produk (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan pencarian API: $e');
    }
  }
}
