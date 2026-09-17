import 'package:shared_preferences/shared_preferences.dart';

/// 本地 KV 存储（偏好设置、登录态等）。在 main 启动时 init。
class LocalStorage {
  LocalStorage._();

  static late SharedPreferences _instance;
  static bool _initialized = false;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static bool get isInitialized => _initialized;
  static SharedPreferences get I => _instance;
}
