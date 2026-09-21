# RealCash 网赚接口协议（Talevra 匿名设备版）

本文是 Talevra 对 RealCash 开发者接入指南的本地实现约定。开发时以本文为准，不需要反复翻阅飞书；RealCash 字段名保持原样，业务层再映射为本地模型。

## 1. 接入范围

当前产品无登录、无真实提现入口，因此只实现匿名网赚闭环：

```text
设备初始化 -> 配置拉取 -> 任务查询 -> 任务执行/领取
                                -> 广告事件上报 -> 广告金币结算
                                -> 余额刷新
```

本期不实现：提现档位、提现订单、提现币种、互动组件、奖励展示策略和等级接口。

## 2. 环境与通用约定

| 项目 | 测试 | 正式 |
|---|---|---|
| Base URL | `http://polo-test.halomobi.net` | `https://polodood.com/` |
| HTTP | `POST` | `POST` |
| Content-Type | `application/json` | `application/json` |

每次请求都必须带请求头：

```http
Token: <token>
RequestTime: <Unix 秒级时间戳>
```

### 2.1 签名算法

1. `key1 = privateKey + RequestTime`。
2. `key2 = MD5(key1)`，取十六进制 MD5 结果的后 16 位作为 AES key。
3. 用 AES/CBC/PKCS5Padding 加密原始 JSON 字符串。`iv` 由运营提供。
4. 对密文 Base64，得到 `cipherText`。
5. `Token = MD5(cipherText)`。

签名必须基于实际发送的 JSON 字符串计算，不能先格式化后再发送另一份 JSON。`privateKey`、`iv` 只能放在服务端或密钥管理系统，不能放入 Flutter、Git 或运营公开表格。

### 2.2 匿名用户标识

客户端首次启动生成并持久化 `deviceId`（产品层也可叫 `deviceNo`，但发给 RealCash 的字段必须是 `deviceId`）。先调用 `reportInfo`，保存返回的 `data.haloUid`；之后所有 RealCash 用户接口都传 `haloUid + deviceId`。

不能把本地 `deviceId` 直接伪装成 `haloUid`，也不能每次启动重新生成设备号。

### 2.3 通用返回结构

```json
{
  "status": 0,
  "msg": "success",
  "data": {}
}
```

`status=0` 才算成功。非 0 时保留 `status`、`msg` 和请求日志，不得本地猜测发币或标记任务完成。

## 3. 用户初始化

### `POST /api/rc/user/reportInfo`

应用启动时调用；同一 `deviceId` 重复调用应返回同一 `haloUid`。

请求 JSON（兼容字段可按服务端版本保留）：

```json
{
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "reqTime": 1760000000,
  "os": "Android"
}
```

`ip`、`country` 在 RealCash V1.0.20 起不再由服务端接收；客户端可以兼容传递，但不得依赖这两个字段生效。国家以配置接口和服务端识别结果为准。

成功响应：

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

本地保存：`deviceId`、`haloUid`、`productId`、最近国家码和可选的服务端时间偏差。

## 4. 配置中心

### `POST /api/rc/app/configCenter`

按 `productId + 国家码 + version` 缓存；进入网赚页、缓存过期或服务端版本变化时刷新。`/api/rc/app/config` 不再使用。

请求 JSON：

```json
{
  "productId": "69f06ba5b804f96d16376f07",
  "country": "US"
}
```

说明：分国家配置查询接口要求国家码；但 V1.0.20 说明普通业务请求中的 `ip/country` 不再作为用户识别参数。配置中心的国家参数仍用于选择配置。

成功响应示例（字段按当前 Talevra 使用范围保留）：

```json
{
  "status": 0,
  "msg": "success",
  "data": {
    "baseInfo": { "coinCount": 1000000 },
    "starterCoinGrant": { "default": 12000, "BR": 20000, "ID": 80000, "KR": 15000, "US": 740666666 },
    "showContent": { "goal": [5, 10, 20, 30, 50], "coins": [500, 1000, 2000, 3000, 4000], "magnification": 2 },
    "showAd": { "goal": [3, 5, 10, 20, 30, 50], "coins": [2000, 3000, 4000, 5000, 8000, 10000], "magnification": 2 },
    "login": { "goal": [1, 2, 3, 4, 5, 6, 7], "coins": [500, 800, 1000, 1200, 1500, 2000, 3000], "magnification": [5, 2, 2, 2, 2, 2, 2] },
    "frequencyInfo": { "videoCap": 50, "interstitialCap": 100 },
    "adFrequencyInfo": { "adCap": 3, "deviceCap": 3, "ipCap": 3 },
    "defaultAdRevenue": { "general": 0.0005 },
    "sendCoinInfo": { "ecpmCap": 0.06, "ratioNew": 0.2, "ratioOld": 0.1, "userDayCap": 4, "deviceDayCap": 4, "ipDayCap": 4 },
    "adTypeRate": { "rewarded": 1, "interstitial": 1 },
    "adTypeCoinCap": { "rewarded": 0.06, "interstitial": 0.06 },
    "getCapInfo": { "userDayCap": 100, "deviceDayCap": 100, "ipDayCap": 100 }
  }
}
```

完整运营数值、类型和国家差异见 [realcash-ops-config.md](realcash-ops-config.md)。

## 5. 任务查询

### `POST /api/rc/task/all`

页面打开、领取成功、广告结算成功后刷新。请求：

```json
{
  "haloUid": "server-user-id",
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "showAll": true
}
```

`country` 可按文档版本兼容传递，但 V1.0.20 后不作为普通用户请求的服务端识别字段。

响应中客户端至少读取：`task` 对象的任务标识、任务类型、目标、奖励、`childrenRound`；`userTask` 对象的进度、领取状态、`nowRound`。服务端原始字段不要改名后再回传给 SDK。

示例：

```json
{
  "status": 0,
  "msg": "success",
  "data": {
    "taskList": [
      {
        "task": { "taskCode": "showContent", "goal": 5, "coins": 500, "childrenRound": 1 },
        "userTask": { "progress": 2, "collected": false, "nowRound": 1 }
      }
    ]
  }
}
```

## 6. 任务进度上报

### `POST /api/rc/task/do`

只上报真实完成的业务动作，不能让客户端直接传奖励金额。请求示例：

```json
{
  "haloUid": "server-user-id",
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "taskCode": "showContent",
  "taskId": "showContent-5",
  "idempotencyKey": "drama-100-episode-5",
  "payload": { "dramaId": "drama-100", "episodeId": "episode-5", "completed": true }
}
```

签到使用 `taskCode=login`；看剧使用实际任务 code 和内容完成信息。广告任务进度由 `getCoins` 成功后服务端推进，不要通过 `task/do` 伪造广告次数。

## 7. 任务领取

### `POST /api/rc/task/collect`

用户点击领取时调用。请求：

```json
{
  "haloUid": "server-user-id",
  "uid": "",
  "deviceId": "persistent-install-id",
  "productId": "69f06ba5b804f96d16376f07",
  "taskId": "showContent-5",
  "idempotencyKey": "collect-showContent-5-20260921"
}
```

成功后以服务端返回余额为准，并重新调用 `task/all` 刷新任务状态。重复领取必须按服务端幂等结果处理。

## 8. 广告事件上报

### `POST /api/rc/ad/eventInfo`

广告 SDK 生命周期按顺序上报：`request`、`fill`、`imp`、`videoCompleted`、`videoClosed`、`fillRevenue`。最小完成事件示例：

```json
{
  "reqId": "ad-request-001",
  "event": "videoCompleted",
  "eventTime": 1760000100,
  "haloUid": "server-user-id",
  "uid": "",
  "productId": "69f06ba5b804f96d16376f07",
  "deviceId": "persistent-install-id",
  "moduleCode": "short_dram",
  "adEventSource": 1,
  "ad_platform": "max",
  "slotInfo": { "slotType": 1, "slotId": "rewarded-slot", "unitId": "rewarded-unit", "impRevenue": 0.0042, "ad_platform": "max" }
}
```

`slotType`：1 激励视频、2 插屏、3 开屏、4 原生、5 Banner。`adEventSource`：1 正常广告收益，3 互动组件，4 领取任务后的额外奖励（不再调用 `getCoins`），5 非看广告任务场景。设备和应用信息按飞书文档提供的 `device`、`app` 结构补齐。

## 9. 广告金币结算

### `POST /api/rc/ad/getCoins`

仅在 `adEventSource=1` 且激励广告完成并通过 SDK 校验后调用。每次完成生成唯一 `cid`，失败重试必须复用同一个 `cid`。

请求：

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
  "event": "videoCompleted"
}
```

成功响应：

```json
{
  "status": 0,
  "msg": "success",
  "data": { "cid": "coin-request-001", "coins": 840, "psource": "normal", "tsource": "ad_completed", "totalCoins": 13840, "totalAmounts": 0.01384 }
}
```

本地将 `coins` 作为本次奖励，使用 `totalCoins` 覆盖余额；`totalAmounts` 仅展示估值，不作为提现金额。禁止用本地计算结果覆盖服务端余额。

## 10. 余额/注册信息刷新

### `POST /api/rc/user/getInfo`

建议在首页启动、从后台恢复和结算异常后调用，用于取得服务端最终余额、注册时间戳及其他用户快照。V1.0.21 还可能返回 `multiCurrency`，当前不展示、不参与业务计算。

请求沿用 `haloUid`、`uid`、`deviceId`、`productId`。具体响应字段按服务端返回保存；余额仍以服务端字段为准。

## 11. 错误、重试和幂等

| 场景 | 客户端处理 |
|---|---|
| 网络超时 | 仅对同一 `cid`、`idempotencyKey` 重试，指数退避 |
| `status != 0` | 不发本地奖励，展示可重试状态并记录 `status/msg` |
| 重复请求 | 接受服务端幂等返回，不重复叠加金币 |
| 达到频控/风控 | 停止自动重试，刷新任务和余额 |
| 配置拉取失败 | 使用上一次成功缓存；首次启动无缓存时只展示非网赚核心页面 |

## 12. 本地映射原则

- RealCash 是余额、任务进度和奖励的唯一账本。
- 本地只缓存 `deviceId`、`haloUid`、配置、任务展示状态和最近服务端余额。
- `deviceNo` 仅是产品旧命名；RealCash 请求一律使用 `deviceId`。
- 不实现提现相关接口，也不在客户端保存提现密钥或提现档位。
