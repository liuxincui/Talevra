import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:talevra/core/config/app_env.dart';
import 'package:talevra/core/logger/app_logger.dart';
import 'package:talevra/core/tool/request_signer.dart';

/// 网络层单例。baseUrl 随环境切换，dev 打印请求体。
class ApiClient {
  ApiClient._();

  static late final Dio instance;

  static void init() {
    final env = AppEnvConfig.current;
    instance = Dio(
      BaseOptions(
        baseUrl: env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    instance.interceptors.add(
      LogInterceptor(requestBody: env.isDev, responseBody: env.isDev),
    );
    instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra['signed'] != false && env.useRequestSigning) {
            final body = options.data is Map<String, dynamic>
                ? jsonEncode(options.data)
                : (options.data?.toString() ?? '{}');
            options.headers.addAll(RequestSigner.sign(body));
          }
          handler.next(options);
        },
      ),
    );
    AppLogger.i('ApiClient ready: ${env.apiBaseUrl}', tag: 'Net');
  }
}
