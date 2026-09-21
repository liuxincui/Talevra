import 'package:flutter/material.dart';
import 'package:talevra/main.dart';

/// 品牌入口 ID — 印尼市场（印尼语为主，en 兜底）
/// 运行：flutter run --flavor brand_id -t lib/main_brand_id.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const TalevraApp(
      brandCode: 'brand_id',
      supportedLocales: [Locale('id'), Locale('en')],
      defaultLocale: Locale('id'),
    ),
  );
}
