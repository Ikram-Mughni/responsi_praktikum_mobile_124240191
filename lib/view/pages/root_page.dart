import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/root_controller.dart';
import 'favorite_page.dart';
import 'home_page.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RootController rootController = Get.find<RootController>();
    final AuthController authController = Get.find<AuthController>();

    final List<Widget> pages = const [
      HomePage(),
      FavoritePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                authController.username.isNotEmpty
                    ? 'Halo, ${authController.username}!'
                    : 'Halo, Pengguna!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const Text(
                'ShoppingHub',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Tombol untuk menuju halaman Wishlist di AppBar sesuai ketentuan soal
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Halaman Wishlist',
            onPressed: () {
              rootController.changeIndex(1);
            },
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi Keluar',
                middleText: 'Apakah Anda yakin ingin keluar dari akun?',
                textConfirm: 'Ya, Keluar',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  authController.logout();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(
        () => IndexedStack(
          index: rootController.currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: rootController.currentIndex,
          onTap: rootController.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
          ],
        ),
      ),
    );
  }
}
