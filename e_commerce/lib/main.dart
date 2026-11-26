import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/services/auth_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/local/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  // Sesi 06: Pastikan engine Flutter terinisialisasi sebelum mengakses SharedPreferences dan Hive CE
  WidgetsFlutterBinding.ensureInitialized();

  // Sesi 09: Inisialisasi Firebase Core dengan platform options terkonfigurasi (Android & iOS)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi dan daftarkan StorageService secara asynchronous ke GetX dependency registry
  final storageService = await Get.putAsync(() => StorageService().init());

  // Sesi 08 & 09: Inisialisasi AuthService terpusat dengan memanfaatkan SharedPreferences dan Firebase Auth
  await Get.putAsync(() => AuthService().init(prefs: storageService.prefs));

  runApp(
    GetMaterialApp(
      title: "KicksStore",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storageService.themeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
