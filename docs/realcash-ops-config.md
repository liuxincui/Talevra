# RealCash 后台运营配置表（Talevra）

这张表只整理 Talevra App 需要的参数。表中的数值来自当前 Mixreels 竞品调研，只是首版建议值；运营保存到 RealCash 后，App 通过 `/api/rc/app/configCenter` 获取，服务端返回值才是线上生效值。App 不应再写死这些奖励数值。

配置链路：

```text
竞品调研建议值 -> 运营填写 RealCash 后台 -> configCenter 返回 -> Talevra 客户端读取
```

## configCenter 配置字段总表

以下字段均属于 RealCash 后台业务配置，由 App 调用 `/api/rc/app/configCenter` 获取。`值` 为当前竞品调研建议值，运营可在 RealCash 后台调整；客户端不应本地写死或修改。

| key | 值 | 说明 |
|---|---:|---|
| `baseInfo.coinCount` | `1000000` | 1 USD 对应金币数 |
| `starterCoinGrant.default` | `12000` | 未单独配置国家的新用户启动奖励金币 |
| `starterCoinGrant.US` | `740666666` | 美国新用户启动奖励金币，数值需运营确认 |
| `starterCoinGrant.BR` | `20000` | 巴西新用户启动奖励金币 |
| `starterCoinGrant.ID` | `80000` | 印尼新用户启动奖励金币 |
| `starterCoinGrant.KR` | `15000` | 韩国新用户启动奖励金币 |
| `showContent.goal` | `[5,10,20,30,50]` | 累计观看集数任务目标梯度 |
| `showContent.coins` | `[500,1000,2000,3000,4000]` | 对应看剧任务金币奖励 |
| `showContent.magnification` | `2` | 看剧任务广告翻倍倍数 |
| `showAd.goal` | `[3,5,10,20,30,50]` | 激励广告任务次数目标梯度 |
| `showAd.coins` | `[2000,3000,4000,5000,8000,10000]` | 对应广告任务金币奖励 |
| `showAd.magnification` | `2` | 广告任务广告翻倍倍数 |
| `login.goal` | `[1,2,3,4,5,6,7]` | 连续签到天数目标 |
| `login.coins` | `[500,800,1000,1200,1500,2000,3000]` | 对应签到金币奖励 |
| `login.magnification` | `[5,2,2,2,2,2,2]` | 对应签到广告翻倍倍数 |
| `circle.goal` | `[1,2,3]` | 转盘次数目标 |
| `circle.coins` | `[50,100,150]` | 对应转盘基础金币奖励 |
| `circle.magnification` | `[0,0,10]` | 对应转盘广告翻倍倍数 |
| `circle.childrenRound` | `10` | 转盘可执行或累计轮数 |
| `circle.interval` | `10` | 转盘任务间隔值 |
| `notice_open.coins` | `100` | 首次开启通知奖励金币 |
| `notice_open.magnification` | `10` | 通知任务广告翻倍倍数 |
| `notice_open.interval` | `20` | 通知任务间隔值 |
| `defaultAdRevenue.general` | `0.0005` | 默认单次广告收入，单位 USD |
| `sendCoinInfo.ecpmCap` | `0.06` | 单次广告计奖收入上限，单位 USD |
| `sendCoinInfo.ratioNew` | `0.2` | 新用户广告收入返币比例 |
| `sendCoinInfo.ratioOld` | `0.1` | 老用户广告收入返币比例 |
| `adTypeRate.rewarded` | `1` | 激励视频收益系数 |
| `adTypeRate.interstitial` | `1` | 插屏收益系数 |
| `adTypeCoinCap.rewarded` | `0.06` | 激励视频单次收益封顶，单位 USD |
| `adTypeCoinCap.interstitial` | `0.06` | 插屏单次收益封顶，单位 USD |
| `frequencyInfo.videoCap` | `50` | 每日激励视频计奖上限 |
| `frequencyInfo.nativeCap` | `0` | 每日原生广告上限 |
| `frequencyInfo.interstitialCap` | `100` | 每日插屏计奖上限 |
| `frequencyInfo.splashCap` | `0` | 每日开屏广告上限 |
| `frequencyInfo.bannerCap` | `0` | 每日横幅广告上限 |
| `frequencyInfo.splashTime` | `300` | 开屏广告最小间隔，单位秒 |
| `adFrequencyInfo.adCap` | `3` | 总体广告频次上限 |
| `adFrequencyInfo.deviceCap` | `3` | 单设备广告频次上限 |
| `adFrequencyInfo.ipCap` | `3` | 单 IP 广告频次上限 |
| `sendCoinInfo.userDayCap` | `4` | 用户每日广告收益上限，单位 USD |
| `sendCoinInfo.deviceDayCap` | `4` | 设备每日广告收益上限，单位 USD |
| `sendCoinInfo.ipDayCap` | `4` | IP 每日广告收益上限，单位 USD |
| `getCapInfo.userDayCap` | `100` | 用户每日金币获取次数上限 |
| `getCapInfo.deviceDayCap` | `100` | 设备每日金币获取次数上限 |
| `getCapInfo.ipDayCap` | `100` | IP 每日金币获取次数上限 |

## 先发给运营：需要交给 App/研发的参数

以下是运营需要交给 App/研发的内容。这里只列 App 实际需要的参数；RealCash 后台内部的密钥、风控算法和服务端字段不在本表范围内。

| 类别 | 参数 | 运营需要提供的值 | 是否必填 | 备注 |
|---|---|---|---|---|
| 环境 | 测试 Base URL | `http://polo-test.halomobi.net` | 是 | 联调使用 |
| 环境 | 正式 Base URL | `https://polodood.com/` | 是 | 发布使用 |
| 产品 | `productId` | `69f06ba5b804f96d16376f07` | 是 | RealCash 产品标识 |
| 产品 | `version` | `1.1.37` | 是 | 后台配置版本，需与客户端兼容 |
| 广告 | `ad_platform` | 例如 `max`、`admob` | 是 | 必须与实际广告 SDK 一致 |
| 广告位 | rewarded `slotId` | 运营后台对应广告位 ID | 是 | `slotType=1` |
| 广告位 | rewarded `unitId` | 广告平台激励视频单元 ID | 是 | `slotType=1` |
| 广告位 | interstitial `slotId` | 运营后台对应广告位 ID | 否 | 当前可暂不启用插屏结算 |
| 广告位 | interstitial `unitId` | 广告平台插屏单元 ID | 否 | `slotType=2` |
| 国家 | App 默认国家 | `US/BR/MX/ID/JP/KR` 之一 | 是 | 使用 ISO 3166-1 alpha-2 大写编码，请求配置中心 |

### 不需要运营填写的运行时字段

以下字段由客户端或服务端自动生成，运营不要配置固定值：`deviceId`、`haloUid`、`uid`、`reqId`、`cid`、`eventTime`、`RequestTime`、`Token`、`resTime`、`totalCoins`。其中 `Token` 由服务端按签名算法生成，`haloUid` 由 `reportInfo` 返回。

## App 运行时自动生成的字段

| 字段 | 生成方 | 说明 |
|---|---|---|
| `deviceId` | 客户端 | 首次安装生成并持久化，不能每次启动变化 |
| `haloUid` | RealCash | `reportInfo` 返回，客户端保存后复用 |
| `uid` | 当前为空 | 当前无登录体系，固定传空字符串 |
| `reqId` | 客户端 | 每次广告请求唯一 |
| `cid` | 客户端 | 每次广告结算唯一，重试必须复用 |
| `eventTime` | 客户端 | 广告事件发生时间 |
| `Token`、`RequestTime` | 服务端签名层 | 不由运营填写，不把私钥放入客户端 |
| `totalCoins`、`coins` | RealCash | 结算响应返回，客户端不能自行计算覆盖 |

App 不需要运营提供这些字段的固定值。

## 一、接入基础参数

| 配置项 | key/字段 | 当前值 | 运营填写/确认 | 说明 |
|---|---|---|---|---|
| 测试环境 | `baseUrl.test` | `http://polo-test.halomobi.net` | 保持或替换 | 联调环境 |
| 正式环境 | `baseUrl.prod` | `https://polodood.com/` | 保持或替换 | 发布环境 |
| 产品 ID | `productId` | `69f06ba5b804f96d16376f07` | 确认 | RealCash 产品标识 |
| 配置版本 | `version` | `1.1.37` | 确认 | 客户端/配置版本 |
| 默认广告平台 | `ad_platform` | `max` | 填真实平台 | 例如 MAX、AdMob，按 SDK 实际值填写 |

## 二、App 广告位参数

| 广告类型 | key | 当前值 | 运营填写/确认 | `slotType` |
|---|---|---|---|---:|
| 激励视频 | `rewarded.slotId` | `rewarded-slot` | 填 RealCash 广告位 ID | 1 |
| 激励视频 | `rewarded.unitId` | `rewarded-unit` | 填广告平台 unit ID | 1 |
| 插屏 | `interstitial.slotId` | `interstitial-slot` | 填 RealCash 广告位 ID | 2 |
| 插屏 | `interstitial.unitId` | `interstitial-unit` | 填广告平台 unit ID | 2 |

## 三、配置中心返回给 App：金币基准与新人奖励

| key | 当前值 | 是否按国家 | 运营说明 |
|---|---:|---|---|
| `baseInfo.coinCount` | 1,000,000 | 否 | 1 USD 对应金币数，不是提现汇率 |
| `starterCoinGrant.default` | 12,000 | 是 | 未单独配置国家使用 |
| `starterCoinGrant.US` | 740,666,666 | 是 | 数值明显异常，发布前必须确认 |
| `starterCoinGrant.BR` | 20,000 | 是 | 巴西 |
| `starterCoinGrant.ID` | 80,000 | 是 | 印尼 |
| `starterCoinGrant.KR` | 15,000 | 是 | 韩国 |

## 四、配置中心返回给 App：任务奖励

### 看剧任务

| key | 当前值 | 含义 |
|---|---|---|
| `showContent.goal` | `[5,10,20,30,50]` | 累计观看集数梯度 |
| `showContent.coins` | `[500,1000,2000,3000,4000]` | 对应金币奖励 |
| `showContent.magnification` | `2` | 任务奖励广告翻倍倍数 |

### 看广告任务

| key | 当前值 | 含义 |
|---|---|---|
| `showAd.goal` | `[3,5,10,20,30,50]` | 激励广告次数梯度 |
| `showAd.coins` | `[2000,3000,4000,5000,8000,10000]` | 对应金币奖励 |
| `showAd.magnification` | `2` | 任务奖励广告翻倍倍数 |

### 连续签到

| key | 当前值 | 含义 |
|---|---|---|
| `login.goal` | `[1,2,3,4,5,6,7]` | 连续签到天数 |
| `login.coins` | `[500,800,1000,1200,1500,2000,3000]` | 每天对应金币奖励 |
| `login.magnification` | `[5,2,2,2,2,2,2]` | 每天广告翻倍倍数 |

## 五、配置中心返回给 App：广告收益与风控

| key | 当前值 | 含义 |
|---|---:|---|
| `defaultAdRevenue.general` | `0.0005` | 默认单次广告收入，USD |
| `sendCoinInfo.ecpmCap` | `0.06` | 单次计奖收入上限，USD |
| `sendCoinInfo.ratioNew` | `0.2` | 新用户返币比例 |
| `sendCoinInfo.ratioOld` | `0.1` | 老用户返币比例 |
| `adTypeRate.rewarded` | `1` | 激励视频收益系数 |
| `adTypeRate.interstitial` | `1` | 插屏收益系数 |
| `adTypeCoinCap.rewarded` | `0.06` | 激励视频单次封顶，USD |
| `adTypeCoinCap.interstitial` | `0.06` | 插屏单次封顶，USD |
| `sendCoinInfo.userDayCap` | `4` | 用户每日广告收益上限，USD |
| `sendCoinInfo.deviceDayCap` | `4` | 设备每日广告收益上限，USD |
| `sendCoinInfo.ipDayCap` | `4` | IP 每日广告收益上限，USD |
| `getCapInfo.userDayCap` | `100` | 用户每日金币获取次数上限 |
| `getCapInfo.deviceDayCap` | `100` | 设备每日金币获取次数上限 |
| `getCapInfo.ipDayCap` | `100` | IP 每日金币获取次数上限 |

## 六、配置中心返回给 App：广告频控

| key | 当前值 | 含义 |
|---|---:|---|
| `frequencyInfo.videoCap` | `50` | 每日激励视频计奖上限 |
| `frequencyInfo.nativeCap` | `0` | 每日原生广告上限 |
| `frequencyInfo.interstitialCap` | `100` | 每日插屏计奖上限 |
| `frequencyInfo.splashCap` | `0` | 每日开屏广告上限 |
| `frequencyInfo.bannerCap` | `0` | 每日横幅广告上限 |
| `frequencyInfo.splashTime` | `300` | 开屏广告最小间隔，秒 |
| `adFrequencyInfo.adCap` | `3` | 总体广告频次上限 |
| `adFrequencyInfo.deviceCap` | `3` | 设备广告频次上限 |
| `adFrequencyInfo.ipCap` | `3` | IP 广告频次上限 |

## 七、App 广告事件参数

| key/字段 | 当前值 | 运营说明 |
|---|---|---|
| `moduleCode` | `short_dram` | 短剧业务模块编码 |
| `adEventSource` | `1` | 正常广告收益，完成后调用 `getCoins` |
| `adEventSource` | `4` | 领取任务后的额外奖励，不调用 `getCoins` |
| `slotType.rewarded` | `1` | 激励视频 |
| `slotType.interstitial` | `2` | 插屏 |
| `event` | `request/fill/imp/videoCompleted/videoClosed/fillRevenue` | RealCash 广告事件枚举 |

## 八、配置中心国家策略

| 国家 | country code | 单独配置项 | 当前值 |
|---|---|---|---:|
| 美国 | `US` | `starterCoinGrant.US` | 740,666,666（待确认） |
| 巴西 | `BR` | `starterCoinGrant.BR` | 20,000 |
| 印尼 | `ID` | `starterCoinGrant.ID` | 80,000 |
| 韩国 | `KR` | `starterCoinGrant.KR` | 15,000 |
| 其他 | default | `starterCoinGrant.default` | 12,000 |

当前 App 支持 `US`、`BR`、`MX`、`ID`、`JP`、`KR` 六个国家。除新人奖励外，其他配置全球统一，不需要复制六套。`MX`、`JP` 当前没有单独新人奖励，使用 `starterCoinGrant.default`；若运营要按国家调整看剧奖励或广告收益，需新增对应国家节点并同步服务端配置规则。

## 九、客户端获取规则

以下配置由客户端调用 `/api/rc/app/configCenter` 获取，客户端只做缓存和展示，不允许覆盖后台值：

| 后台配置 | 客户端读取字段 | 客户端用途 |
|---|---|---|
| 金币基准 | `baseInfo.coinCount` | 展示金币与美元估值 |
| 新人奖励 | `starterCoinGrant` | 服务端首次设备初始化时发放 |
| 看剧任务 | `showContent` | 显示目标、进度和奖励 |
| 看广告任务 | `showAd` | 显示广告任务目标和奖励 |
| 签到任务 | `login` | 显示连续签到奖励 |
| 广告收益 | `defaultAdRevenue`、`sendCoinInfo`、`adTypeRate`、`adTypeCoinCap` | 由服务端计算，客户端仅展示结果 |
| 风控频控 | `frequencyInfo`、`adFrequencyInfo`、`getCapInfo` | 客户端展示限制状态，最终以服务端判定为准 |

客户端本地只允许保留最近一次成功配置作为离线兜底；一旦后台返回新值，应覆盖旧缓存。客户端不能自行修改任务目标、奖励金币、返币比例或风控上限。

## 十、运营确认清单

1. 确认 `productId`、正式/测试域名和配置版本。
2. 填写 rewarded/interstitial 的 `slotId`、`unitId` 和实际 `ad_platform`。
3. 确认 App 默认国家码。
4. 确认 `starterCoinGrant.US=740666666` 是否为真实值。
5. 确认所有任务数组目标数与奖励数长度一致。
6. 确认当前全球统一策略；如需国家差异，只先开放新人奖励国家节点。
