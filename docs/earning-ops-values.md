# 网赚运营数值表（历史参考）

> 本文仅保留 Mixreels 竞品调研数值。正式运营配置请使用 [RealCash 后台运营配置表](realcash-ops-config.md)，由运营写入 RealCash 后台，客户端通过 `configCenter` 获取；不要把本文数值直接写死到客户端。

这张表给运营确认数值。`key` 与配置接口返回字段一一对应，运营确认中文含义和数值，研发按 key 落配置。当前版本没有登录和真实提现入口，因此只配置金币、任务、签到、转盘、通知奖励和广告收益规则。

## 配置范围

| 配置范围 | 当前规则 |
|---|---|
| 全局统一 | 看剧任务、看广告任务、签到、转盘、通知奖励、广告频控、收益换算、收益风控 |
| 按国家配置 | 新用户启动奖励，仅 BR、ID、KR、US 有单独值，其余国家使用 default |
| 当前不配置 | 提现档位、提现币种、提现兑换比例、提现返现任务，因为没有提现入口 |

## 金币兑换与新人奖励

| key | 配置项 | 默认值 | US | BR | ID | KR | 是否按国家 | 运营说明 |
|---|---|---:|---:|---:|---:|---:|---|---|
| `baseInfo.coinCount` | 1 USD 对应金币数 | 1,000,000 | 1,000,000 | 1,000,000 | 1,000,000 | 1,000,000 | 否 | 统一金币换算基准，不是提现汇率 |
| `starterCoinGrant.{country}` | 新用户启动奖励 | 12,000 | 740,666,666 | 20,000 | 80,000 | 15,000 | 是 | 实际 key 为 `.default/.US/.BR/.ID/.KR`；US 数值需确认 |

## 看剧任务

| 数组序号 | 目标 key | 奖励 key | 倍数 key | 累计看剧集数 | 奖励金币 | 广告翻倍倍数 | 是否按国家 |
|---:|---|---|---|---:|---:|---:|---|
| 0 | `showContent.goal[0]` | `showContent.coins[0]` | `showContent.magnification` | 5 | 500 | 2 | 否 |
| 1 | `showContent.goal[1]` | `showContent.coins[1]` | `showContent.magnification` | 10 | 1,000 | 2 | 否 |
| 2 | `showContent.goal[2]` | `showContent.coins[2]` | `showContent.magnification` | 20 | 2,000 | 2 | 否 |
| 3 | `showContent.goal[3]` | `showContent.coins[3]` | `showContent.magnification` | 30 | 3,000 | 2 | 否 |
| 4 | `showContent.goal[4]` | `showContent.coins[4]` | `showContent.magnification` | 50 | 4,000 | 2 | 否 |

## 看广告任务

| 数组序号 | 目标 key | 奖励 key | 倍数 key | 累计广告次数 | 奖励金币 | 广告翻倍倍数 | 是否按国家 |
|---:|---|---|---|---:|---:|---:|---|
| 0 | `showAd.goal[0]` | `showAd.coins[0]` | `showAd.magnification` | 3 | 2,000 | 2 | 否 |
| 1 | `showAd.goal[1]` | `showAd.coins[1]` | `showAd.magnification` | 5 | 3,000 | 2 | 否 |
| 2 | `showAd.goal[2]` | `showAd.coins[2]` | `showAd.magnification` | 10 | 4,000 | 2 | 否 |
| 3 | `showAd.goal[3]` | `showAd.coins[3]` | `showAd.magnification` | 20 | 5,000 | 2 | 否 |
| 4 | `showAd.goal[4]` | `showAd.coins[4]` | `showAd.magnification` | 30 | 8,000 | 2 | 否 |
| 5 | `showAd.goal[5]` | `showAd.coins[5]` | `showAd.magnification` | 50 | 10,000 | 2 | 否 |

## 签到奖励

| 数组序号 | 天数 key | 奖励 key | 倍数 key | 连续签到 | 奖励金币 | 广告翻倍倍数 | 是否按国家 |
|---:|---|---|---|---:|---:|---:|---|
| 0 | `login.goal[0]` | `login.coins[0]` | `login.magnification[0]` | 第 1 天 | 500 | 5 | 否 |
| 1 | `login.goal[1]` | `login.coins[1]` | `login.magnification[1]` | 第 2 天 | 800 | 2 | 否 |
| 2 | `login.goal[2]` | `login.coins[2]` | `login.magnification[2]` | 第 3 天 | 1,000 | 2 | 否 |
| 3 | `login.goal[3]` | `login.coins[3]` | `login.magnification[3]` | 第 4 天 | 1,200 | 2 | 否 |
| 4 | `login.goal[4]` | `login.coins[4]` | `login.magnification[4]` | 第 5 天 | 1,500 | 2 | 否 |
| 5 | `login.goal[5]` | `login.coins[5]` | `login.magnification[5]` | 第 6 天 | 2,000 | 2 | 否 |
| 6 | `login.goal[6]` | `login.coins[6]` | `login.magnification[6]` | 第 7 天 | 3,000 | 2 | 否 |

## 转盘奖励

| 数组序号 | 次数 key | 奖励 key | 倍数 key | 当日转盘 | 基础奖励金币 | 广告翻倍倍数 | 是否按国家 |
|---:|---|---|---|---:|---:|---:|---|
| 0 | `circle.goal[0]` | `circle.coins[0]` | `circle.magnification[0]` | 第 1 次 | 50 | 0 | 否 |
| 1 | `circle.goal[1]` | `circle.coins[1]` | `circle.magnification[1]` | 第 2 次 | 100 | 0 | 否 |
| 2 | `circle.goal[2]` | `circle.coins[2]` | `circle.magnification[2]` | 第 3 次 | 150 | 10 | 否 |

补充规则：`circle.childrenRound=10`；`circle.interval=10`，具体含义和单位需产品确认。

## 通知奖励

| key | 配置项 | 数值 | 是否按国家 | 运营说明 |
|---|---|---:|---|---|
| `notice_open.coins` | 首次开启通知奖励 | 100 金币 | 否 | 同一设备只发一次 |
| `notice_open.magnification` | 广告翻倍倍数 | 10 | 否 | 通知任务翻倍奖励 |
| `notice_open.interval` | 间隔值 | 20 | 否 | 单位待产品确认 |

## 广告收益换算

| key | 配置项 | 数值 | 是否按国家 | 运营说明 |
|---|---|---:|---|---|
| `defaultAdRevenue.general` | 默认单次广告收入 | 0.0005 USD | 否 | 广告平台未返回收入时使用 |
| `sendCoinInfo.ecpmCap` | 单次广告收入封顶 | 0.06 USD | 否 | 超过部分不计奖 |
| `sendCoinInfo.ratioNew` | 新用户返币比例 | 20% | 否 | 注册未满 7 天 |
| `sendCoinInfo.ratioOld` | 老用户返币比例 | 10% | 否 | 注册满 7 天 |
| `adTypeRate.rewarded` | 激励视频收益系数 | 1 | 否 | rewarded |
| `adTypeRate.interstitial` | 插屏收益系数 | 1 | 否 | interstitial |
| `adTypeCoinCap.rewarded` | 激励视频单次封顶 | 0.06 USD | 否 | rewarded |
| `adTypeCoinCap.interstitial` | 插屏单次封顶 | 0.06 USD | 否 | interstitial |

计算示例：广告收入 `0.0042 USD`，新用户返币比例 `20%`，金币基准 `1,000,000`，奖励为 `0.0042 × 20% × 1,000,000 = 840` 金币，最终还需经过风控上限。

## 广告频控与收益风控

| key | 配置项 | 数值 | 是否按国家 | 运营说明 |
|---|---|---:|---|---|
| `frequencyInfo.videoCap` | 每日激励视频计奖上限 | 50 次 | 否 | 超过后不计奖 |
| `frequencyInfo.interstitialCap` | 每日插屏广告计奖上限 | 100 次 | 否 | 超过后不计奖 |
| `adFrequencyInfo.adCap` | 总体广告频次上限 | 3 次 | 否 | 单场景或单周期频控 |
| `adFrequencyInfo.deviceCap` | 设备广告频次上限 | 3 次 | 否 | 设备维度频控 |
| `adFrequencyInfo.ipCap` | IP 广告频次上限 | 3 次 | 否 | IP 维度频控 |
| `sendCoinInfo.userDayCap` | 用户每日广告奖励上限 | 4 USD | 否 | 服务端风控 |
| `sendCoinInfo.deviceDayCap` | 设备每日广告奖励上限 | 4 USD | 否 | 服务端风控 |
| `sendCoinInfo.ipDayCap` | IP 每日广告奖励上限 | 4 USD | 否 | 服务端风控 |
| `getCapInfo.userDayCap` | 用户每日金币获取上限 | 100 次 | 否 | 服务端风控 |
| `getCapInfo.deviceDayCap` | 设备每日金币获取上限 | 100 次 | 否 | 服务端风控 |
| `getCapInfo.ipDayCap` | IP 每日金币获取上限 | 100 次 | 否 | 服务端风控 |

## 国家配置建议

| key | 国家 | country code | 新人奖励金币 | 备注 |
|---|---|---|---:|---|
| `starterCoinGrant.US` | 美国 | US | 740,666,666 | 数值异常，发布前必须确认 |
| `starterCoinGrant.BR` | 巴西 | BR | 20,000 | 单独配置 |
| `starterCoinGrant.ID` | 印尼 | ID | 80,000 | 单独配置 |
| `starterCoinGrant.KR` | 韩国 | KR | 15,000 | 单独配置 |
| `starterCoinGrant.default` | 其他国家 | default | 12,000 | 使用默认值 |

除新人奖励外，其他数值当前全部全球统一，不需要按国家复制配置。

## 运营需要确认

| key | 项目 | 当前值 | 需要确认 |
|---|---|---:|---|
| `starterCoinGrant.US` | US 新人奖励 | 740,666,666 | 是否为异常值，还是确实要发放 |
| `circle.interval` | 转盘 interval | 10 | 具体含义和单位 |
| `notice_open.interval` | 通知 interval | 20 | 具体含义和单位 |
