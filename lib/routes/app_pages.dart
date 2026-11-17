import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/product_controller.dart';
import '../controller/favorite_controller.dart';
import '../controller/root_controller.dart';
import '../view/pages/detail_page.dart';
import '../view/pages/favorite_page.dart';
import '../view/pages/login_page.dart';
import '../view/pages/register_page.dart';
import '../view/pages/root_page.dart';
import 'app_routes.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<RootController>(() => RootController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<FavoriteController>(() => FavoriteController());
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FavoriteController>()) {
      Get.lazyPut<FavoriteController>(() => FavoriteController());
    }
  }
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.root,
      page: () => const RootPage(),
      binding: RootBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => Scaffold(
        appBar: AppBar(
          title: const Text('Wishlist'),
        ),
        body: const FavoritePage(),
      ),
      binding: DetailBinding(),
    ),
  ];
}
