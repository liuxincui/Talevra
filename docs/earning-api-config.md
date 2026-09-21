# 网赚业务接口文档（历史本地模型参考）

> 本文保留 Mixreels 反编译出的本地字段和数值，供运营数值核对。RealCash 的实际请求字段、签名、用户初始化和广告接口以 [realcash-api-spec.md](realcash-api-spec.md) 为准；不要按本文的 `deviceNo` 或“合并广告接口”实现线上请求。

参照 Mixreels 反编译结果整理。当前产品没有登录体系，客户端上报稳定且唯一的 `deviceNo`，服务端以 `productId + deviceNo` 识别匿名用户、保存余额和任务进度。

最小业务闭环只保留 5 个接口：配置、任务列表、任务执行、任务领取、广告结算。任务详情合并到任务列表；广告事件上报与金币结算合并为一次请求。当前产品没有提现入口，因此不下发提现档位、提现币种和提现返现任务。

## 通用约定

- 请求方式：`POST`
- 请求格式：`application/json`
- `productId`：`69f06ba5b804f96d16376f07`
- `version`：`1.1.37`
- `deviceNo`：客户端上报的稳定设备号，用于区分匿名用户；同一安装周期内不得变化
- 服务端以 `productId + deviceNo` 建立唯一匿名账户，不依赖登录态或 `haloUid`
- 所有写入接口必须传唯一 `idempotencyKey`
- 服务端必须按用户、设备和 IP 执行频控，不能信任客户端传入的进度或奖励金额

通用成功结构：

```json
{
  "status": 0,
  "msg": "success",
  "request_id": "req-001",
  "data": {}
}
```

通用失败结构：

```json
{
  "status": 40003,
  "msg": "daily limit reached",
  "request_id": "req-002",
  "data": null
}
```

建议的最小错误码：

| status | 含义 |
|---:|---|
| `0` | 成功 |
| `40001` | 参数错误 |
| `40002` | 重复请求，返回首次处理结果 |
| `40003` | 达到每日上限 |
| `40004` | 任务未完成 |
| `40005` | 奖励已领取 |
| `40006` | 广告事件校验失败 |

## 1. 配置接口

`POST /api/rc/app/configCenter`

一次返回当前客户端实际使用的静态配置。该接口不返回用户余额和任务进度，可按 `productId + country + version` 缓存。

请求 JSON：

```json
{
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US",
  "version": "1.1.37"
}
```

成功返回 JSON：

```json
{
  "status": 0,
  "msg": "success",
  "request_id": "req-config-001",
  "data": {
    "baseInfo": {
      "coinCount": 1000000
    },
    "starterCoinGrant": {
      "default": 12000,
      "BR": 20000,
      "ID": 80000,
      "KR": 15000,
      "US": 740666666
    },
    "showContent": {
      "goal": [5, 10, 20, 30, 50],
      "coins": [500, 1000, 2000, 3000, 4000],
      "magnification": 2
    },
    "showAd": {
      "goal": [3, 5, 10, 20, 30, 50],
      "coins": [2000, 3000, 4000, 5000, 8000, 10000],
      "magnification": 2
    },
    "login": {
      "goal": [1, 2, 3, 4, 5, 6, 7],
      "coins": [500, 800, 1000, 1200, 1500, 2000, 3000],
      "magnification": [5, 2, 2, 2, 2, 2, 2]
    },
    "circle": {
      "goal": [1, 2, 3],
      "coins": [50, 100, 150],
      "magnification": [0, 0, 10],
      "childrenRound": 10,
      "interval": 10
    },
    "frequencyInfo": {
      "videoCap": 50,
      "interstitialCap": 100
    },
    "adFrequencyInfo": {
      "adCap": 3,
      "deviceCap": 3,
      "ipCap": 3
    },
    "defaultAdRevenue": {
      "general": 0.0005
    },
    "sendCoinInfo": {
      "ecpmCap": 0.06,
      "ratioNew": 0.2,
      "ratioOld": 0.1,
      "userDayCap": 4,
      "deviceDayCap": 4,
      "ipDayCap": 4
    },
    "adTypeRate": {
      "rewarded": 1,
      "interstitial": 1
    },
    "adTypeCoinCap": {
      "rewarded": 0.06,
      "interstitial": 0.06
    },
    "getCapInfo": {
      "userDayCap": 100,
      "deviceDayCap": 100,
      "ipDayCap": 100
    },
    "notice_open": {
      "coins": 100,
      "magnification": 10,
      "interval": 20
    }
  }
}
```

## 2. 任务列表与账户快照

`POST /api/rc/task/all`

一次返回匿名用户余额、注册时间、当日次数、签到状态和所有任务。页面启动、领取奖励或广告结算后调用该接口刷新状态，不再单独提供用户信息和任务详情接口。

请求 JSON：

```json
{
  "deviceNo": "550e8400-e29b-41d4-a716-446655440000",
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US"
}
```

成功返回 JSON：

```json
{
  "status": 0,
  "msg": "success",
  "request_id": "req-task-all-001",
  "data": {
    "wallet": {
      "coins": 12500,
      "registeredAt": "2026-09-21T08:00:00Z"
    },
    "today": {
      "episodeCount": 2,
      "rewardedAdCount": 1,
      "interstitialCount": 0,
      "spinCount": 0
    },
    "checkIn": {
      "streak": 1,
      "checkedToday": true
    },
    "tasks": [
      {
        "taskId": "showContent-5",
        "taskType": "showContent",
        "title": "Watch 5 episodes",
        "goal": 5,
        "coins": 500,
        "magnification": 2,
        "progress": 2,
        "completed": false,
        "collected": false
      }
    ]
  }
}
```

首次出现的 `deviceNo` 由服务端创建匿名账户并发放一次新人奖励；重复请求不得重复发放。服务端应校验设备号格式，并结合 IP 和设备风控字段限制批量伪造设备号。

## 3. 任务执行

`POST /api/rc/task/do`

统一处理签到、看完一集、转盘和通知权限奖励。广告任务进度只能由广告结算接口推进，不能通过本接口直接增加。

请求 JSON：

```json
{
  "deviceNo": "550e8400-e29b-41d4-a716-446655440000",
  "productId": "69f06ba5b804f96d16376f07",
  "taskType": "showContent",
  "idempotencyKey": "episode-drama-100-episode-5",
  "payload": {
    "dramaId": "drama-100",
    "episodeId": "episode-5",
    "completed": true
  }
}
```

`taskType` 和 `payload`：

| taskType | payload | 说明 |
|---|---|---|
| `login` | `{}` | 每日签到，同一天只能成功一次 |
| `showContent` | `dramaId`、`episodeId`、`completed=true` | 看完一集，同一剧集不能重复计数 |
| `circle` | `{}` | 执行一次转盘，由服务端决定奖励 |
| `notice_open` | `permissionGranted=true` | 首次开启通知权限奖励 |

成功返回 JSON：

```json
{
  "status": 0,
  "msg": "success",
  "request_id": "req-task-do-001",
  "data": {
    "taskType": "showContent",
    "progress": 3,
    "completedTaskIds": [],
    "rewardCoins": 0,
    "balance": 12500,
    "remainingCount": null
  }
}
```

`circle` 可在 `rewardCoins` 返回本次直接到账金币，在 `remainingCount` 返回当日剩余次数；其他里程碑任务通过任务领取接口发奖。

## 4. 任务领取

`POST /api/rc/task/collect`

请求 JSON：

```json
{
  "deviceNo": "550e8400-e29b-41d4-a716-446655440000",
  "productId": "69f06ba5b804f96d16376f07",
  "taskId": "showContent-5",
  "idempotencyKey": "collect-showContent-5-20260921"
}
```

成功返回 JSON：

```json
{
  "status": 0,
  "msg": "success",
  "request_id": "req-task-collect-001",
  "data": {
    "taskId": "showContent-5",
    "rewardCoins": 500,
    "collected": true,
    "balance": 13000
  }
}
```

## 5. 广告完成与金币结算

`POST /api/rc/ad/getCoins`

广告完成后一次完成事件上报、合法性校验、频控校验、金币计算和入账，不再单独调用 `/api/rc/ad/eventInfo`。

请求 JSON：

```json
{
  "deviceNo": "550e8400-e29b-41d4-a716-446655440000",
  "productId": "69f06ba5b804f96d16376f07",
  "eventId": "ad-event-001",
  "idempotencyKey": "ad-event-001",
  "adType": "rewarded",
  "adPlatform": "applovin",
  "adUnitId": "rewarded-unit-01",
  "revenue": 0.0042,
  "currency": "USD",
  "completedAt": "2026-09-21T08:30:00Z"
}
```

成功返回 JSON：

```json
{
  "status": 0,
  "msg": "success",
  "request_id": "req-ad-coins-001",
  "data": {
    "eventId": "ad-event-001",
    "acceptedRevenue": 0.0042,
    "rewardCoins": 840,
    "balance": 13840,
    "todayAdCount": 2,
    "settled": true
  }
}
```

同一 `eventId` 或 `idempotencyKey` 只能入账一次。服务端应使用广告平台回调或可信收入数据校验 `revenue`；无法验证时使用配置中的 `defaultAdRevenue.general`，不能直接信任客户端金额。
