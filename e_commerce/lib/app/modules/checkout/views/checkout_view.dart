import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Pengiriman & Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indikator Alur Pemesanan
              Container(
                padding: const EdgeInsets.all(12),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStep('1', 'Keranjang', true, isDark),
                    _buildStepLine(true),
                    _buildStep('2', 'Pengiriman', true, isDark),
                    _buildStepLine(false),
                    _buildStep('3', 'Selesai', false, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Alamat Pengiriman
              Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.nameController,
                validator: controller.validateName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Penerima',
                  hintText: 'Contoh: Ahmad Rizki',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.phoneController,
                validator: controller.validatePhone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp / Telepon',
                  hintText: 'Contoh: 081234567890',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.addressController,
                validator: controller.validateAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap Rumah',
                  hintText:
                      'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan, kota/kabupaten',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Pilihan Kurir Pengiriman
              Text(
                'Kurir Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Column(
                  children: List.generate(controller.courierOptions.length, (
                    index,
                  ) {
                    final courier = controller.courierOptions[index];
                    final isSelected =
                        controller.selectedCourierIndex.value == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => controller.selectCourier(index),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 26,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      courier.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      courier.estimatedTime,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                controller.currencyFormatter.format(
                                  courier.cost,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),

              // Pilihan Metode Pembayaran
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Column(
                  children: [
                    _buildPaymentOption(
                      index: 0,
                      title: 'COD (Bayar di Tempat)',
                      subtitle:
                          'Bayar tunai kepada kurir saat sneakers sampai di rumah',
                      icon: Icons.payments_outlined,
                      selectedIndex: controller.selectedPaymentMethod.value,
                      onTap: () => controller.selectPaymentMethod(0),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      index: 1,
                      title: 'Transfer Bank (BCA / Mandiri)',
                      subtitle:
                          'Verifikasi pesanan otomatis via Virtual Account',
                      icon: Icons.account_balance_outlined,
                      selectedIndex: controller.selectedPaymentMethod.value,
                      onTap: () => controller.selectPaymentMethod(1),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      index: 2,
                      title: 'QRIS (Gopay / OVO / ShopeePay)',
                      subtitle: 'Scan cepat barcode QRIS di layar konfirmasi',
                      icon: Icons.qr_code_scanner_rounded,
                      selectedIndex: controller.selectedPaymentMethod.value,
                      onTap: () => controller.selectPaymentMethod(2),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ringkasan Biaya Belanja
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Pembayaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        'Total Harga Barang (${controller.cart.totalItemCount} item)',
                        controller.formattedSubtotal,
                        isDark,
                      ),
                      const SizedBox(height: 6),
                      _buildPriceRow(
                        'Pajak PPN (11%)',
                        controller.formattedTax,
                        isDark,
                      ),
                      const SizedBox(height: 6),
                      _buildPriceRow(
                        'Ongkos Kirim (${controller.courierOptions[controller.selectedCourierIndex.value].name})',
                        controller.formattedCourierFee,
                        isDark,
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Tagihan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            controller.formattedGrandTotal,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 20),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(
            () => ElevatedButton.icon(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                controller.isLoading.value
                    ? 'Memproses Pesanan...'
                    : 'Bayar Sekarang & Buat Pesanan',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.placeOrder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String label, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? AppColors.primary
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppColors.primary : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required int selectedIndex,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    bool isDark, {
    bool isDiscount = false,
    bool isFree = false,
  }) {
    Color textColor;
    if (isDiscount || isFree) {
      textColor = AppColors.success;
    } else {
      textColor = isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isDiscount || isFree
                ? FontWeight.bold
                : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
