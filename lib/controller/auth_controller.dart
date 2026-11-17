import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import 'favorite_controller.dart';
import 'root_controller.dart';

class AuthController extends GetxController {
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _username = ''.obs;
  String get username => _username.value;

  late Box _userBox;

  @override
  void onInit() {
    super.onInit();
    _userBox = Hive.box('usersBox');
    _seedDefaultUser();
    loadCurrentUser();
  }

  // Akun bawaan agar memudahkan pengujian login saat responsi
  Future<void> _seedDefaultUser() async {
    if (!_userBox.containsKey('user')) {
      await _userBox.put('user', 'password');
    }
    if (!_userBox.containsKey('budi123')) {
      await _userBox.put('budi123', 'password123');
    }
  }

  // Ambil username aktif dari SharedPreferences
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _username.value = prefs.getString('currentUser') ?? '';
  }

  // Registrasi akun baru dan simpan ke Local Database (Hive)
  Future<void> register(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Username dan Password wajib diisi!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    if (_userBox.containsKey(cleanUsername)) {
      Get.snackbar(
        'Registrasi Gagal',
        'Username "$cleanUsername" sudah terdaftar. Silakan gunakan username lain.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));

    // Simpan ke Hive
    await _userBox.put(cleanUsername, cleanPassword);
    _isLoading.value = false;

    Get.snackbar(
      'Berhasil',
      'Akun berhasil dibuat. Silakan login.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
    Get.offNamed(AppRoutes.login);
  }

  // Login dan verifikasi dengan data dari Local Database (Hive)
  Future<void> login(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Username dan Password tidak boleh kosong!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));

    final storedPassword = _userBox.get(cleanUsername);

    if (storedPassword != null && storedPassword == cleanPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentUser', cleanUsername);

      _username.value = cleanUsername;

      // Reload wishlist user aktif
      if (Get.isRegistered<FavoriteController>()) {
        await Get.find<FavoriteController>().loadFavorites();
      }

      _isLoading.value = false;
      Get.offAllNamed(AppRoutes.root);
    } else {
      _isLoading.value = false;
      Get.snackbar(
        'Login Gagal',
        'Username atau Password salah!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Logout dan bersihkan session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUser');

    _username.value = '';

    // Reset state controller
    if (Get.isRegistered<FavoriteController>()) {
      Get.find<FavoriteController>().clearState();
    }
    if (Get.isRegistered<RootController>()) {
      Get.find<RootController>().changeIndex(0);
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
