import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/product_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = Get.find<ProductController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar Area
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _productController.setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                  onSubmitted: (value) =>
                      _productController.setSearchQuery(value),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _productController.setSearchQuery(_searchController.text);
                },
                child: const Text('Cari'),
              ),
            ],
          ),
        ),

        // Filter Chips Area (Daftar kategori dinamis dari API)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _productController.categories.map((category) {
                  final isSelected =
                      _productController.selectedCategory.toLowerCase() ==
                          category.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category[0].toUpperCase() + category.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.indigo,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (_) =>
                          _productController.setCategoryFilter(category),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),

        // List Produk Area
        Expanded(
          child: Obx(() {
            // Indikator loading saat data diambil dari API
            if (_productController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_productController.errorMessage.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal memuat produk',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _productController.errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Coba Lagi'),
                        onPressed: () => _productController.fetchProducts(),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_productController.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan coba gunakan kata kunci pencarian atau kategori lain.',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => await _productController.fetchProducts(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _productController.products.length,
                itemBuilder: (context, index) {
                  final product = _productController.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Get.toNamed(AppRoutes.detail, arguments: product);
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
