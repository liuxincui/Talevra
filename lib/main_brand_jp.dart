import 'package:flutter/material.dart';
import 'package:talevra/main.dart';

/// 品牌入口 JP — 日本市场（日语为主，en 兜底）
/// 运行：flutter run --flavor brand_jp -t lib/main_brand_jp.dart
void main() async {
  await AppInitializer.init();
  runApp(const TalevraApp(
    brandCode: 'brand_jp',
    supportedLocales: [Locale('ja'), Locale('en')],
    defaultLocale: Locale('ja'),
  ));
}
