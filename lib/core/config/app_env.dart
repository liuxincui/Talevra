/// 运行环境配置。与"品牌/国家" flavor 正交：
/// flavor 决定投放国家与语种，ENV 决定接口域名与日志级别。
/// 注入方式：flutter run --dart-define=ENV=staging
enum AppEnv { dev, staging, prod }

class AppEnvConfig {
  final AppEnv env;
  final String apiBaseUrl;
  const AppEnvConfig._({required this.env, required this.apiBaseUrl});

  static const dev = AppEnvConfig._(
    env: AppEnv.dev,
    apiBaseUrl: 'https://dev-api.talevra.com',
  );
  static const staging = AppEnvConfig._(
    env: AppEnv.staging,
    apiBaseUrl: 'https://staging-api.talevra.com',
  );
  static const prod = AppEnvConfig._(
    env: AppEnv.prod,
    apiBaseUrl: 'https://api.talevra.com',
  );

  static AppEnvConfig get current {
    const name = String.fromEnvironment('ENV', defaultValue: 'dev');
    return switch (name) {
      'staging' => staging,
      'prod' => prod,
      _ => dev,
    };
  }

  bool get isProd => env == AppEnv.prod;
  bool get isDev => env == AppEnv.dev;
}
