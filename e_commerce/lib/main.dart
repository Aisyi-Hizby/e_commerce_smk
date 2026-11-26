import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/services/auth_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/local/storage_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // Memastikan jembatan komunikasi antara engine Flutter dan platform native Android/iOS telah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi dan daftarkan StorageService secara asynchronous ke GetX dependency registry
  final storageService = await Get.putAsync(() => StorageService().init());

  // Sesi 08: Inisialisasi AuthService terpusat dengan memanfaatkan SharedPreferences yang sudah dimuat
  await Get.putAsync(() => AuthService().init(prefs: storageService.prefs));

  runApp(
    GetMaterialApp(
      title: "KicksStore",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storageService.themeMode,
    ),
  );
}
