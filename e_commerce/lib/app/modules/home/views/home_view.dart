import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/local/storage_service.dart';
import 'package:e_commerce/app/modules/home/controllers/home_controller.dart';
import 'package:e_commerce/app/modules/home/views/components/product_card.dart';
import 'package:e_commerce/app/modules/home/views/components/promo_banner.dart';
import 'package:e_commerce/app/modules/home/widgets/product_card_shimmer.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Halaman Utama (Katalog & Beranda KicksStore)
/// Diperbarui di Sesi 02: Menggunakan Reaktivitas GetX (.obs & Obx)
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.electric_bolt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                children: const [
                  TextSpan(text: 'Kicks'),
                  TextSpan(
                    text: 'Store',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Navigasi ke Wishlist
          IconButton(
            tooltip: 'Wishlist Favorit',
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => Get.toNamed(Routes.WISHLIST),
          ),

          // Navigasi ke Riwayat Pesanan
          IconButton(
            tooltip: 'Riwayat Pesanan',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Get.toNamed(Routes.ORDERS),
          ),

          // Sesi 06: Tombol Saklar Dark / Light Mode (Tersimpan Persisten ke SharedPreferences)
          IconButton(
            tooltip: 'Ganti Tema',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.accent : AppColors.lightTextPrimary,
            ),
            onPressed: () {
              if (Get.isRegistered<StorageService>()) {
                Get.find<StorageService>().toggleTheme();
              } else {
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              }
            },
          ),

          // Sesi 02: Navigasi ke Keranjang Belanja dengan Badge Reaktif (Obx)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Keranjang Belanja',
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => Get.toNamed(Routes.CART),
              ),
              Obx(() {
                final count = controller.cartCount;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchProducts,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pengguna (Greeting & Foto Profil)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final isLoggedIn =
                            Get.isRegistered<AuthService>() &&
                            AuthService.to.isLoggedIn.value;
                        final email = Get.isRegistered<AuthService>()
                            ? AuthService.to.currentUserEmail.value
                            : '';
                        final greeting = isLoggedIn && email.isNotEmpty
                            ? 'Halo, ${email.split('@').first}! 👋'
                            : 'Halo, Sneakers Enthusiast! 👋';
                        return Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        );
                      }),
                      const SizedBox(height: 2),
                      Text(
                        'Temukan Sepatu Impianmu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final isLoggedIn =
                        Get.isRegistered<AuthService>() &&
                        AuthService.to.isLoggedIn.value;
                    return InkWell(
                      onTap: () {
                        if (isLoggedIn) {
                          _showAccountBottomSheet(context);
                        } else {
                          Get.toNamed(Routes.LOGIN);
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: isLoggedIn
                            ? AppColors.primary
                            : AppColors.primary.withAlpha(40),
                        child: Icon(
                          Icons.person_rounded,
                          color: isLoggedIn ? Colors.white : AppColors.primary,
                          size: 26,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Kolom Pencarian (Search Bar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Air Jordan, Ultraboost, 550...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      color: AppColors.primary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Banner Promo Eksklusif
              const PromoBanner(),
              const SizedBox(height: 20),

              // Sesi 02: Filter Kategori Horizontal Reaktif (Obx)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return Obx(() {
                      final isSelected =
                          controller.selectedCategory.value == category;
                      return InkWell(
                        onTap: () => controller.changeCategory(category),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkSurfaceCard
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Judul Bagian Katalog & Jumlah Produk Dinamis
              Obx(() {
                final count = controller.filteredProducts.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Katalog Sneakers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '$count Produk',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),

              // Sesi 06: Tampilan Shimmer Skeleton Loading saat fetch produk berlangsung
              Obx(() {
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return const ProductGridShimmer(itemCount: 4);
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 56,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal Memuat Produk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: controller.fetchProducts,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = controller.filteredProducts;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada produk di kategori ini',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return Obx(() {
                      final isFav = controller.isFavorite(product.id);
                      return ProductCard(
                        title: product.name,
                        category: product.category,
                        price: product.formattedPrice,
                        rating: product.rating,
                        imageUrl: product.imageUrl,
                        isFavorite: isFav,
                        // Sesi 03: Navigasi berargumen ke Detail Produk via Model
                        onTap: () => controller.openDetail(product),
                        // Sesi 03: Quick Add to Cart via CartController
                        onAddToCart: () => controller.addToCart(product),
                        // Sesi 03: Toggle Favorite
                        onToggleFavorite: () =>
                            controller.toggleFavorite(product.id),
                      );
                    });
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark
            ? AppColors.darkTextMuted
            : AppColors.lightTextMuted,
        backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Akun',
          ),
        ],
        onTap: (index) {
          if (index == 1) Get.toNamed(Routes.WISHLIST);
          if (index == 2) Get.toNamed(Routes.ORDERS);
          if (index == 3) {
            final isLoggedIn =
                Get.isRegistered<AuthService>() &&
                AuthService.to.isLoggedIn.value;
            if (isLoggedIn) {
              _showAccountBottomSheet(context);
            } else {
              Get.toNamed(Routes.LOGIN);
            }
          }
        },
      ),
    );
  }

  /// Menampilkan lembar modal akun jika pengguna sudah terautentikasi
  void _showAccountBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = AuthService.to;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header Profil Pengguna
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withAlpha(40),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            auth.currentUserEmail.value.isNotEmpty
                                ? auth.currentUserEmail.value
                                : 'Pengguna KicksStore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Akun Terautentikasi (Firebase)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const SizedBox(height: 8),

              // Menu Cepat: Riwayat Pesanan
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Riwayat Pesanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.ORDERS);
                },
              ),

              // Menu Cepat: Daftar Wishlist
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.pinkAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Daftar Wishlist',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.WISHLIST);
                },
              ),
              const SizedBox(height: 16),

              // Tombol Logout Akun
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showLogoutConfirmationDialog();
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Dialog konfirmasi sebelum melakukan logout
  void _showLogoutConfirmationDialog() {
    Get.defaultDialog(
      title: 'Konfirmasi Keluar',
      middleText: 'Apakah Anda yakin ingin keluar dari akun KicksStore?',
      textConfirm: 'Ya, Keluar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.lightTextSecondary,
      onConfirm: () async {
        Get.back(); // Tutup dialog konfirmasi
        if (Get.isRegistered<AuthService>()) {
          await AuthService.to.logout();
        }
        if (!Get.testMode && Get.overlayContext != null) {
          Get.snackbar(
            'Berhasil Keluar 👋',
            'Sesi akun Anda telah diakhiri. Sampai jumpa kembali!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          );
        }
      },
    );
  }
}
