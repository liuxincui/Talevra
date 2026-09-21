# RealCash 接口复用与本地数据映射

来源：RealCash 开发者接入指南（飞书文档，2026-09-18）。本文只做接口选型和字段映射，不修改业务代码。

## 一、推荐接入链路

RealCash 的匿名接入不是直接把自定义 `deviceNo` 作为所有接口用户 ID，而是：

```text
deviceId/installId
  -> /api/rc/user/reportInfo
  -> 服务端返回 haloUid
  -> 后续任务、广告、余额接口使用 haloUid + deviceId
```

因此本地应保存：

| 本地字段 | 来源 | 是否持久化 | 用途 |
|---|---|---|---|
| `deviceId` | 客户端生成的 installId，或按平台取得的设备 ID | 是 | 匿名设备标识，不能每次启动重置 |
| `haloUid` | `user/reportInfo` 返回 | 是 | RealCash 服务端用户标识 |
| `productId` | 应用配置 | 是/常量 | `69f06ba5b804f96d16376f07` |
| `country` | 本地国家或服务端 IP 国家 | 可刷新 | 两位国家码 |
| `reqTime` | 客户端当前秒级时间戳 | 否 | 上报参数/签名辅助 |
| `resTime` | `user/reportInfo` 返回 | 否 | 服务端时间校准 |

不要把 `deviceNo` 直接当成 `haloUid`。如果产品必须使用 `deviceNo` 这个命名，可以在客户端内部映射为 RealCash 的 `deviceId` 或 `installId`，请求字段仍按 RealCash 文档使用 `deviceId`。

## 二、当前可以直接复用的接口

| 接口 | 建议 | 原因 |
|---|---|---|
| `/api/rc/user/reportInfo` | 必接 | 用设备号创建/恢复匿名用户并取得 `haloUid` |
| `/api/rc/app/configCenter` | 必接 | 获取金币、任务、广告收益和频控配置；`/api/rc/app/config` 已标记废弃 |
| `/api/rc/task/all` | 必接 | 获取任务模板和用户任务进度 |
| `/api/rc/task/detail` | 可选 | 只有任务列表信息不足时才调用；页面可先不接 |
| `/api/rc/task/do` | 必接 | 上报签到、看剧/任务进度 |
| `/api/rc/task/collect` | 必接 | 领取已完成任务奖励 |
| `/api/rc/ad/eventInfo` | 必接 | 按 RealCash 协议上报广告请求、填充、展示、播放完成等事件 |
| `/api/rc/ad/getCoins` | 必接 | 按广告完成事件申请发币并获取最新余额 |
| `/api/rc/user/getInfo` | 建议接 | 获取真实余额、冻结余额、注册天数和服务端国家；可作为任务列表之外的余额刷新接口 |
| `/api/rc/level/list` | 当前不接 | 没有提现入口，不需要提现档位 |
| `/api/rc/order/create`、`/api/rc/order/list` | 当前不接 | 没有真实提现功能 |
| `/api/rc/strategy/info` | 当前可不接 | 奖励展示策略依赖提现/多策略场景，当前没有提现入口 |
| `/api/rc/module/*` | 当前不接 | 互动组件（老虎机、转盘）不是短剧基础网赚闭环；若后续接入再单独实现 |

## 三、匿名用户初始化

### `POST /api/rc/user/reportInfo`

请求字段来自飞书文档：

```json
{
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "reqTime": 1760000000,
  "reqIp": "",
  "reqCountry": "US",
  "os": "Android"
}
```

返回关键字段：

```json
{
  "status": 0,
  "msg": "success",
  "data": {
    "haloUid": "server-user-id",
    "resTime": 1760000001
  }
}
```

本地映射：

| RealCash 字段 | 本地数据 |
|---|---|
| `data.haloUid` | 新增匿名账户标识 `remoteHaloUid` |
| `deviceId` | 本地 `installId/deviceId` |
| `data.resTime` | 可用于服务端时间偏差计算 |

重复上报同一 `deviceId` 应复用原有 `haloUid`，不能每次创建新用户。

## 四、配置接口

### `POST /api/rc/app/configCenter`

请求：

```json
{
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US"
}
```

使用现有 [网赚业务接口文档](earning-api-config.md) 中配置返回的字段映射：

| RealCash 返回节点 | 本地字段 |
|---|---|
| `baseInfo.coinCount` | `EarningConfig.coinCount` |
| `frequencyInfo.videoCap` | `videoDailyCap` |
| `frequencyInfo.interstitialCap` | `interstitialDailyCap` |
| `adFrequencyInfo.adCap` | `adDailyCap` |
| `defaultAdRevenue.general` | `defaultAdRevenueUsd` |
| `sendCoinInfo.ecpmCap` | `ecpmCapUsd` |
| `sendCoinInfo.ratioNew` | `newUserRatio` |
| `sendCoinInfo.ratioOld` | `oldUserRatio` |
| `sendCoinInfo.userDayCap` | `userDayCapUsd` |
| `sendCoinInfo.deviceDayCap` | `deviceDayCapUsd` |
| `sendCoinInfo.ipDayCap` | `ipDayCapUsd` |
| `adTypeRate` | `adTypeRates` |
| `adTypeCoinCap` | `adTypeCoinCaps` |
| `starterCoinGrant` | `starterCoins` |

任务数组需要按 RealCash 实际返回结构确认是 `showContent/showAd/login/circle` 还是 `tasks` 模板返回；不要在解析层凭字段名猜测并覆盖本地任务值。

## 五、任务接口与本地模型

### `POST /api/rc/task/all`

建议请求：

```json
{
  "haloUid": "server-user-id",
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US",
  "showAll": true
}
```

飞书文档确认该接口存在，但任务对象字段需要以该章节的最新定义为准。客户端至少需要映射：

| 返回字段 | 本地字段 |
|---|---|
| `taskId` / `id` | `EarningTask.id` |
| `taskType` / `type` | `EarningTask.type` |
| `name` / `title` | `EarningTask.title` |
| `goal` | `EarningTask.goal` |
| `coins` | `EarningTask.reward` |
| `magnification` / `multiple` | `EarningTask.multiplier` |
| `userTask.progress` | `EarningTask.progress` |
| `userTask.collected` / `claimed` | `EarningTask.claimed` |
| `childrenRound` | 任务周期内子任务可执行次数 |
| `nowRound` | 当前执行轮次 |

### `POST /api/rc/task/do`

该接口用于任务进度上报。请求至少需要：

```json
{
  "haloUid": "server-user-id",
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US",
  "taskCode": "showContent",
  "taskId": "task-episode-5",
  "idempotencyKey": "episode-drama-100-5",
  "payload": {
    "dramaId": "drama-100",
    "episodeId": "episode-5"
  }
}
```

需要后端确认 `taskCode/taskId` 的精确命名；本地不要把观看集数直接改成本地余额，以上报成功响应为准。

### `POST /api/rc/task/collect`

请求至少需要：

```json
{
  "haloUid": "server-user-id",
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US",
  "taskId": "task-episode-5"
}
```

本地处理：成功后刷新任务列表和余额，不直接按本地 `reward` 加金币；RealCash 服务端才是最终账本。

## 六、广告接口

### `POST /api/rc/ad/eventInfo`

飞书文档确认事件枚举：`request`、`fill`、`imp`、`videoCompleted`、`videoClosed`、`fillRevenue`。

短剧激励广告最小请求：

```json
{
  "reqId": "ad-request-001",
  "event": "videoCompleted",
  "eventTime": 1760000100,
  "haloUid": "server-user-id",
  "uid": "",
  "productId": "69f06ba5b804f96d16376f07",
  "deviceId": "persistent-install-id",
  "adEventSource": 1,
  "ad_platform": "max",
  "slotInfo": {
    "slotType": 1,
    "slotId": "rewarded-slot",
    "unitId": "rewarded-unit",
    "impRevenue": 0.0042,
    "ad_platform": "max"
  }
}
```

`adEventSource` 使用规则：

| 值 | 场景 |
|---:|---|
| `1` | ECPM 发币/正常广告收益 |
| `3` | 互动组件广告 |
| `4` | 领取任务后的额外奖励广告；该场景不应再调用 `getCoins` |
| `5` | 看广告任务之外的任务 |

设备、应用和广告位的完整结构按飞书文档填写：`device` 包括 `os/osv/ua/ip/make/model/width/height/connectionType/carrier/deviceId/installId`；`app` 包括 `appName/version/pkgName/sdkInfoList`；`slotInfo` 包括 `slotType/slotId/unitId/impRevenue/impRevenueList/ad_platform`。

### `POST /api/rc/ad/getCoins`

飞书文档确认请求字段：`cid`、`reqId`、`uid`、`haloUid`、`deviceId`、`ip`、`productId`、`slotId`、`slotType`、`country`、`event`。

激励视频完成后的最小请求：

```json
{
  "cid": "coin-request-001",
  "reqId": "ad-request-001",
  "uid": "",
  "haloUid": "server-user-id",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "slotId": "rewarded-slot",
  "slotType": 1,
  "country": "US",
  "event": "videoCompleted"
}
```

成功响应关键字段：

```json
{
  "status": 0,
  "msg": "success",
  "data": {
    "cid": "coin-request-001",
    "coins": 840,
    "psource": "normal",
    "tsource": "ad_completed",
    "totalCoins": 13840,
    "totalAmounts": 0.01384
  }
}
```

本地映射：`coins` 作为本次奖励展示，`totalCoins` 覆盖本地余额，`totalAmounts` 仅作金额估值展示。不要用本地计算结果覆盖 `totalCoins`。

## 七、签名与环境

飞书文档要求所有接口请求头携带：

```http
Token: <签名结果>
RequestTime: <Unix 秒级时间戳>
```

签名为 AES-CBC-PKCS5 加密原始 JSON，再对 Base64 密文做 MD5。`privateKey` 和 `iv` 由运营提供，不能写入运营数值表，也不能提交到公开仓库。

环境：

```text
测试：http://polo-test.halomobi.net
正式：https://polodood.com/
```

## 八、开发落地说明

本文用于接口选型和字段映射；实际开发请求、响应示例、签名和错误处理统一以 [RealCash 网赚接口协议](realcash-api-spec.md) 为准。任务字段不要在客户端自行改名或推导，直接保留 RealCash 的 `task`、`userTask`、`childrenRound` 和 `nowRound` 原字段。

运营数值、广告位和环境参数统一看 [RealCash 运营配置表](realcash-ops-config.md)。
