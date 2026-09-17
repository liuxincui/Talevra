import 'package:flutter/foundation.dart';
import 'package:talevra/core/config/app_env.dart';

/// 极简日志：dev/staging 打全量，prod 仅 error。
class AppLogger {
  const AppLogger._();

  static void d(Object? msg, {String? tag}) =>
      _log('D', tag ?? 'App', msg, always: false);

  static void i(Object? msg, {String? tag}) =>
      _log('I', tag ?? 'App', msg, always: false);

  static void e(Object? msg, {Object? error, StackTrace? stack, String? tag}) {
    _log('E', tag ?? 'App', msg, always: true);
    if (error != null) _log('E', tag ?? 'App', error, always: true);
    if (stack != null) _log('E', tag ?? 'App', stack, always: true);
  }

  static void _log(
    String level,
    String tag,
    Object? msg, {
    required bool always,
  }) {
    if (!always && AppEnvConfig.current.isProd) return;
    if (kDebugMode) debugPrint('[$level/$tag] $msg');
  }
}
