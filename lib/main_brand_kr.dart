import 'package:flutter/material.dart';
import 'package:talevra/main.dart';

/// 品牌入口 KR — 韩国市场（韩语为主，en 兜底）
/// 运行：flutter run --flavor brand_kr -t lib/main_brand_kr.dart
void main() async {
  await AppInitializer.init();
  runApp(const TalevraApp(
    brandCode: 'brand_kr',
    supportedLocales: [Locale('ko'), Locale('en')],
    defaultLocale: Locale('ko'),
  ));
}
