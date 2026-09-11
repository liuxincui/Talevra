# Talevra — Flutter 多国短剧客户端

短剧 App 客户端，Flutter 技术栈。通过 Android `productFlavor` + Flutter 多入口实现**一套代码、六个投放国家**，每个国家启用各自语言集。

> 原生 Kotlin 版本已备份至 `../Talevra_legacy/`，确认无需回退后可删除。

## 投放国家与语种矩阵

| 国家 | flavor | applicationId | 语种集（主语言在前） | 语言 |
|------|--------|---------------|---------------------|------|
| 美国 | `brand_us` | `com.talevra.talevra.us` | en | English |
| 巴西 | `brand_br` | `com.talevra.talevra.br` | pt, en | Português |
| 墨西哥 | `brand_mx` | `com.talevra.talevra.mx` | es, en | Español |
| 印尼 | `brand_id` | `com.talevra.talevra.id` | id, en | Bahasa |
| 日本 | `brand_jp` | `com.talevra.talevra.jp` | ja, en | 日本語 |
| 韩国 | `brand_kr` | `com.talevra.talevra.kr` | ko, en | 한국어 |

> 每个国家 en 作为兜底语种。app_name 目前为占位（Talevra US/BR/...），待正式品牌名替换。

## 运行与构建

```bash
# 运行某国品牌（以美国为例）
flutter run --flavor brand_us -t lib/main_brand_us.dart

# 指定环境（dev/staging/prod，与品牌正交）
flutter run --flavor brand_jp --dart-define=ENV=staging -t lib/main_brand_jp.dart

# 发布 APK
flutter build apk --flavor brand_kr --release -t lib/main_brand_kr.dart
```

## 架构

```
lib/
  main.dart                 通用 TalevraApp（接入路由/主题/本地化/provider）+ AppInitializer
  main_brand_{us,br,mx,id,jp,kr}.dart   六国入口，只注入 brandCode + supportedLocales + defaultLocale
  app/
    router/app_router.dart  go_router 路由（/ 首页, /player/:dramaId 播放页）
    theme/app_theme.dart    light/dark 主题
  core/
    config/app_env.dart     环境配置（dev/staging/prod，dart-define 注入）
    config/brand_provider.dart  品牌码 riverpod provider
    logger/app_logger.dart  日志
    network/api_client.dart dio 网络层单例
    storage/local_storage.dart  shared_preferences KV 存储
  features/
    home/      首页外壳 + 首页 tab
    library/   书库 tab（占位）
    settings/  设置 tab（占位）
    player/    播放页（占位）
  l10n/                     arb 资源 + gen-l10n 生成代码
android/app/build.gradle.kts  flavorDimensions=brand，六国 productFlavors
```

- **品牌维度（productFlavor）**：每国独立 `applicationIdSuffix` + `resValue` app_name + `resourceConfigurations` 限定打包语种。
- **语言维度（Flutter）**：`lib/main.dart` 的 `TalevraApp` 接收 `supportedLocales` + `defaultLocale`，入口注入。新增语种 = 加 `app_xx.arb` + 入口注册 locale。
- **环境维度**：`AppEnvConfig` 用 `--dart-define=ENV=` 注入，与品牌正交。

## 新增投放国家四步

1. `android/app/build.gradle.kts` 加 `create("brand_xx")`（appId 后缀、app_name、语种集）
2. `lib/main_brand_xx.dart` 新建入口，注入品牌码与 `supportedLocales`
3. 新语种则添加 `lib/l10n/app_xx.arb`
4. `flutter pub get && flutter test` 回归

## 测试与质量

- `flutter analyze` 要求 0 issues
- `flutter test` 覆盖六国默认语种断言（Home / Início / Inicio / Beranda / ホーム / 홈）

## 技术栈

Flutter 3.32 / Dart 3.8 · go_router · dio · flutter_riverpod · shared_preferences · flutter_localizations
