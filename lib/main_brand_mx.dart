import 'package:flutter/material.dart';
import 'package:talevra/main.dart';

/// 品牌入口 MX — 墨西哥市场（西班牙语为主，en 兜底）
/// 运行：flutter run --flavor brand_mx -t lib/main_brand_mx.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const TalevraApp(
      brandCode: 'brand_mx',
      supportedLocales: [Locale('es'), Locale('en')],
      defaultLocale: Locale('es'),
    ),
  );
}
