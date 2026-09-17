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

> 每个国家 en 作为兜底语种。应用名称统一为 Talevra。

## 运行与构建

首次构建前，在不会提交到 Git 的 `android/local.properties` 中配置 Dramaverse：

```properties
pssdk.appId=<Dramaverse App ID>
pssdk.vodAppId=<BytePlus VOD App ID>
pssdk.securityKey=<Dramaverse Security Key>
pssdk.licenseAssetPath=vod_player.lic
pssdk.debug=false
```

将对应包名的播放器授权文件放到
`android/app/src/main/assets/vod_player.lic`。License、签名文件、APK、映射表和符号文件均不提交到 Git。

```bash
# 运行某国品牌（以美国为例）
flutter run --flavor brand_us -t lib/main_brand_us.dart

# 指定环境（dev/staging/prod，与品牌正交）
flutter run --flavor brand_jp --dart-define=ENV=staging -t lib/main_brand_jp.dart

# 发布 APK（Android R8 + Dart 混淆）
flutter build apk --flavor brand_kr --release -t lib/main_brand_kr.dart \\
  --obfuscate --split-debug-info=build/symbols/brand_kr
```

## 配置说明

配置分为品牌、运行环境和语言三个维度，彼此独立组合：

### 运行环境

通过 `--dart-define=ENV=` 注入环境，支持 `dev`、`staging`、`prod`，默认是 `dev`：

| ENV | API 地址 | 请求签名 |
|-----|----------|----------|
| `dev` | `https://dev-api.talevra.com` | 关闭 |
| `staging` | `https://staging-api.talevra.com` | 开启 |
| `prod` | `https://api.talevra.com` | 开启 |

示例：

```bash
flutter run --flavor brand_jp -t lib/main_brand_jp.dart --dart-define=ENV=staging
flutter build apk --flavor brand_us -t lib/main_brand_us.dart --dart-define=ENV=prod --release \\
  --obfuscate --split-debug-info=build/symbols/brand_us
```

Android release 构建在 `android/app/build.gradle.kts` 中显式开启 R8 和资源压缩；debug/profile
构建保持关闭，便于测试和调试。`--obfuscate` 只负责 Flutter/Dart 符号混淆，生成的
`--split-debug-info` 符号目录必须按 flavor 和版本归档，用于线上崩溃堆栈还原。

环境配置实现位于 `lib/core/config/app_env.dart`。新增或修改环境时，应同步更新环境枚举、API 地址和相关发布配置；禁止在页面中写死环境判断或 API 地址。

### 品牌与国家

品牌由 Android `productFlavor` 和 Flutter 入口共同决定：

- `android/app/build.gradle.kts`：维护 flavor、包名后缀、应用名称和 Android 资源语言；
- `lib/main_brand_*.dart`：维护 `brandCode`、主语言和兜底语言；
- 两处的 flavor 名必须一致，例如 `brand_jp`。

新增品牌时，必须同时新增 Android flavor 和对应的 Flutter 入口，再执行 `flutter pub get && flutter test`。

### 语言

语言资源位于 `lib/l10n/`，文件格式为 `app_<locale>.arb`。品牌入口设置默认语言和可用语言，`en` 通常作为兜底语言；用户切换后的语言会保存到本地存储，下次启动继续使用。

新增语言时：

1. 新增 `lib/l10n/app_<locale>.arb`；
2. 更新 `lib/l10n/app_localizations.dart` 及对应品牌入口；
3. 更新 Android flavor 的 `resourceConfigurations`（如涉及原生资源）；
4. 运行 `flutter gen-l10n`（或 `flutter pub get`）并执行测试。

### 网赚配置

网赚配置集中在 `lib/features/earning/config/earning_config.dart`，由 `EarningConfig.local` 提供本地默认值；进入网赚页后，客户端按国家调用配置中心，服务端返回值只覆盖允许动态调整的字段，未返回时继续使用本地默认值。

当前可配置项包括：

| 配置项 | 说明 | 本地默认值 |
|--------|------|------------|
| `productId` | 网赚产品标识 | `69f06ba5b804f96d16376f07` |
| `version` | 网赚配置版本 | `1.1.37` |
| `coinCount` | 币种/积分总量配置 | `1000000` |
| `watchGoals` | 看剧任务梯度 | `5, 10, 20, 30, 50` |
| `adGoals` | 看广告任务梯度 | `3, 5, 10, 20, 30, 50` |
| `checkInCoins` | 连续签到奖励 | `500, 800, 1000, 1200, 1500, 2000, 3000` |
| `videoDailyCap` | 视频广告每日上限 | `50` |
| `interstitialDailyCap` | 插屏广告每日上限 | `100` |
| `starterCoins` | 按国家配置新人币 | `default=12000`，BR=20000，ID=80000，KR=15000 |

提现档位默认值也集中在该配置中：注册满 3/7/30/30/60/180 天，对应 `1/5/10/50/100/200 USD`；服务端成功返回档位列表时优先使用服务端数据。

网赚接口统一封装在 `lib/features/earning/data/earning_api.dart` 和 `earning_repository.dart`，包括配置、任务、余额、签到、广告结算和任务领取。页面只调用 `EarningController`，不得直接拼接 `/api/rc/*` 请求或修改配置默认值。

### 配置边界

页面和业务模块通过配置服务读取品牌、环境和语言，不直接读取 `String.fromEnvironment`、Android flavor 或本地存储实现。配置变更应集中在 `lib/core/config/` 和各品牌入口，避免在多个页面复制配置值。

## 架构

项目遵循“页面和交互层 → 通用业务模块层 → 基础设施层”的单向依赖，页面不得直接调用网络、存储或第三方 SDK。完整边界与落位规则见 [系统架构约束](docs/system-architecture.md)。

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
