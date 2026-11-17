import 'package:get/get.dart';
import '../model/product_model.dart';
import '../service/api_service.dart';

class ProductController extends GetxController {
  final RxList<ProductModel> _products = <ProductModel>[].obs;
  final RxList<String> _categories = <String>['All'].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  final RxString _selectedCategory = 'All'.obs;
  final RxString _searchQuery = ''.obs;

  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;

  List<ProductModel> get characters => _products;
  String get selectedStatus => _selectedCategory.value;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
  }

  // Ambil daftar kategori dari API
  Future<void> fetchCategories() async {
    try {
      final cats = await ApiService.getCategories();
      _categories.assignAll(['All', ...cats]);
    } catch (_) {
      // Fallback kategori dasar jika endpoint gagal
      _categories.assignAll(['All', 'beauty', 'fragrances', 'furniture', 'groceries']);
    }
  }

  // Ambil produk dari API
  Future<void> fetchProducts() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      List<ProductModel> data;
      if (_searchQuery.value.trim().isNotEmpty) {
        data = await ApiService.searchProducts(_searchQuery.value.trim());
        if (_selectedCategory.value != 'All') {
          data = data
              .where((item) =>
                  item.category.toLowerCase() == _selectedCategory.value.toLowerCase())
              .toList();
        }
      } else if (_selectedCategory.value != 'All') {
        data = await ApiService.getProductsByCategory(_selectedCategory.value);
      } else {
        data = await ApiService.fetchProducts();
      }

      _products.assignAll(data);
    } catch (e) {
      _errorMessage.value = e.toString();
      _products.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter kategori
  void setCategoryFilter(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchProducts();
    }
  }

  // Alias method untuk kompatibilitas
  void setStatusFilter(String category) => setCategoryFilter(category);

  // Pencarian produk
  void setSearchQuery(String query) {
    _searchQuery.value = query;
    fetchProducts();
  }

  // Alias untuk kompatibilitas
  Future<void> fetchCharacters() => fetchProducts();
}
