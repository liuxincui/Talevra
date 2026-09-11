import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前运行的品牌码（如 brand_us / brand_jp），由各品牌入口注入。
/// 任何页面可通过 ref.watch(brandCodeProvider) 读取，避免层层透传。
final brandCodeProvider = Provider<String>((ref) => 'unknown');
