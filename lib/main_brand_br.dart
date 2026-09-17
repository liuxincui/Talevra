import 'package:flutter/material.dart';
import 'package:talevra/main.dart';

/// 品牌入口 BR — 巴西市场（葡萄牙语为主，en 兜底）
/// 运行：flutter run --flavor brand_br -t lib/main_brand_br.dart
void main() async {
  await AppInitializer.init();
  runApp(
    const TalevraApp(
      brandCode: 'brand_br',
      supportedLocales: [Locale('pt'), Locale('en')],
      defaultLocale: Locale('pt'),
    ),
  );
}
