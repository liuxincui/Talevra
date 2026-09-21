import 'package:flutter/material.dart';
import 'package:talevra/main.dart';

/// 品牌入口 US — 美国市场（英语）
/// 运行：flutter run --flavor brand_us -t lib/main_brand_us.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const TalevraApp(
      brandCode: 'brand_us',
      supportedLocales: [Locale('en')],
      defaultLocale: Locale('en'),
    ),
  );
}
