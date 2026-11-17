import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/favorite_controller.dart';
import '../../model/product_model.dart';
import '../../service/api_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ProductModel? product;
  bool isLoading = true;
  String errorMessage = '';
  final FavoriteController favController = Get.find<FavoriteController>();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final args = Get.arguments;
    int productId = 0;

    if (args is ProductModel) {
      productId = args.id;
      product = args; // Menampilkan data awal segera sembari memuat data detail API terbaru
    } else if (args is int) {
      productId = args;
    }

    if (productId <= 0) {
      setState(() {
        isLoading = false;
        errorMessage = 'ID produk tidak valid.';
      });
      return;
    }

    try {
      setState(() {
        isLoading = product == null;
        errorMessage = '';
      });

      // Mengambil detail produk berdasarkan ID produk dari API (GET /products/{id})
      final detail = await ApiService.getSingleProduct(productId);
      if (mounted) {
        setState(() {
          product = detail;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.title ?? 'Detail Produk'),
        actions: [
          if (product != null)
            Obx(() {
              final isFav = favController.isFavorite(product!.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                tooltip: isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
                onPressed: () => favController.toggleFavorite(product!),
              );
            }),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage.isNotEmpty && product == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat detail produk',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: _fetchDetail,
                    ),
                  ],
                ),
              ),
            );
          }

          final currentProduct = product!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk
                Container(
                  width: double.infinity,
                  height: 280,
                  color: Colors.white,
                  child: currentProduct.image.isNotEmpty
                      ? Image.network(
                          currentProduct.image,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                        ),
                ),

                // Konten Detail
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Badge Kategori
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              currentProduct.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              currentProduct.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            backgroundColor: Colors.indigo.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Harga & Diskon
                      Row(
                        children: [
                          Text(
                            '\$${currentProduct.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (currentProduct.discountPercentage > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${currentProduct.discountPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card Informasi Lengkap
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Produk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const Divider(height: 24),
                              _buildDetailRow(
                                Icons.sell_outlined,
                                'Brand',
                                currentProduct.brand.isNotEmpty
                                    ? currentProduct.brand
                                    : 'Tidak tersedia',
                              ),
                              _buildDetailRow(
                                Icons.category_outlined,
                                'Kategori',
                                currentProduct.category,
                              ),
                              _buildDetailRow(
                                Icons.attach_money,
                                'Harga',
                                '\$${currentProduct.price.toStringAsFixed(2)}',
                              ),
                              _buildDetailRow(
                                Icons.percent,
                                'Persentase Diskon',
                                '${currentProduct.discountPercentage.toStringAsFixed(2)}%',
                              ),
                              _buildDetailRow(
                                Icons.star,
                                'Rating',
                                '${currentProduct.rating} / 5.0',
                              ),
                              _buildDetailRow(
                                Icons.inventory_2_outlined,
                                'Informasi Stok',
                                '${currentProduct.stock} unit',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentProduct.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: product != null
          ? Obx(() {
              final isFav = favController.isFavorite(product!.id);
              return FloatingActionButton.extended(
                onPressed: () => favController.toggleFavorite(product!),
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                label: Text(isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist'),
                backgroundColor: isFav ? Colors.red : Colors.indigo,
                foregroundColor: Colors.white,
              );
            })
          : null,
    );
  }
}
