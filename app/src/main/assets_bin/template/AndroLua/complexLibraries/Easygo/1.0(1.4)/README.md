# 华为平行世界

> 部分小米平板支持华为的平行视界哦

> 谷歌在 Android 12L 也发布了类似的东西，因此您也需要适配 Android 12L。

## 业务简介

平行视界以Activity为基本单位，以左右窗口分离显示技术、双窗口生命周期管理、双窗口显示模式和切换逻辑为核心技术的实现应用内分屏的系统侧解决方案。应用可以根据自身业务设计分屏显示Activity组合，以实现符合应用逻辑的最佳单应用多窗口用户体验，且支持一次开发，多端部署。

## easygo.json 配置文件

`easygo.json` 存放在 `assets` 或`assets_bin` 目录下。

以下表格从[配置指南](https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/config-introduction-0000001054270212)摘抄并修复部分语法问题。

| 参数 | 限制 | 描述 |
| ---- | ---- | ---- |
| easyGoVersion | 1 | 协议版本，固定值为 `1.0` |
| client | 1 | 应用包名 |
| logicEntities.head.function | 1 | 调用组件名，固定值 `magicwindow` |
| logicEntities.head.required | 1 | 预留字段，固定值 `true` |
| logicEntities.body.mode | 1 | 基础分屏模式<br>__0__：购物模式，`activityPairs`节点不生效<br>__1__：自定义模式（包括导航栏模式） |
| logicEntities.body.activityPairs | ? | 自定义模式参数，配置从 `from` 页面到 `to` 页面的分屏展示 |
| logicEntities.body.activityPairs.from | * | 触发分屏的源 Activity |
| logicEntities.body.activityPairs.to | \* | 触发分屏的目标Activity，`*`表示任意Activity<br>__自定义模式__：`[{"from"："com.xxx.ActivityA", "to"："com.xxx.ActivityB"}]` 表示A上启动B，触发分屏（A左B右）<br>__导航栏模式__：`[{"from"："com.xxx.ActivityA", "to"："*"}]` |
| logicEntities.body.defaultDualActivities | ? | 应用冷启动默认打开首页双屏配置 |
| logicEntities.body.defaultDualActivities.mainPages | 1 | 主页面 Activity，可以有多个，分号隔开<br>展开态时冷启动应用打开此页面时，系统在右屏自动启动 `relatedPage` 页面 |
| logicEntities.body.defaultDualActivities.relatedPage | ? | 右屏默认展示页面 Activity<br>`mainPages` 和 `relatedPage` 只能配置1对，需要具体的 Activity 名，不支持通配符<br>如: `[{"mainPages":"com.xxx.MainActivity","relatedPage":"com.xxx.EmptyActivity"}]` |
| logicEntities.body.transActivities | * | 过渡页面列表 | 如 `["com.xxx.ActivityD","com.xxx.ActivityE","com.xxx.ActivityF"]` |
| logicEntities.body.Activities | ? | 应用关键 Activity 属性列表 |
| logicEntities.body.Activities.name | 1 | Activity 组件名 |
| logicEntities.body.Activities.defaultFullScreen | ? | Activity 是否支持默认以全屏启动<br>__true__：支持<br>__false__：不支持<br>默认为 `false` |
| logicEntities.body.Activities.lockSide | ？ | Activity 锁定方式，当前仅支持锁定在 primary 侧<br>__primary__：锁定在主界面那一侧，锁定后，另一侧启动新的 Activity 时不会轻易平推窗口过来，除非推过来的窗口也是 __primary__ 锁定窗口(典型场景：直播购物场景，将直播 Activity 配置成锁定)。
| logicEntities.body.Activities.isSupportDraggingToFreeform | ？ | 当前 Activity 是否支持拖出到悬浮窗，当 `logicEntities.body.UX.draggingToFreeForm` 配置为 `window` 时生效。<br>__true__：支持<br>__false__：不支持<br>默认为 `false` |
| logicEntities.body.UX | ? | 页面 UX 控制配置 |
| logicEntities.body.UX.supportRotationUxCompat | ? | 是否开启窗口缩放，用于提高转屏应用UX显示兼容性<br>__true__：支持<br>__false__：不支持<br>默认为 `false` ，仅针对平板产品生效 |
| logicEntities.body.UX.isDraggable | ? | 是否支持分屏窗口拖动<br>__true__：支持<br>__false__：不支持<br>默认为 `false` ，仅针对平板产品生效 |
| logicEntities.body.supportVideoFullscreen | ? | 是否支持视频全屏<br>__true__：支持<br>__false__：不支持<br>默认为 `true` ，仅针对平板产品生效 |
| logicEntities.body.UX.supportDraggingToFullScreen | ？ | 是否支持在分屏和全屏之间拖动切换<br>__ALL__：所有设备上支持此功能<br>__PAD__: 仅平板产品上支持此功能<br>__FOLD__: 仅折叠屏上支持此功能<br>如果支持多个产品，可以用 `|` 进行分割，例如想在折叠屏和平板上同时支持，则配置为 `PAD|FOLD` |
| logicEntities.body.UX.supportLock | ？ | 是否支持应用内用户锁定功能，配置为 `true` 后，双窗口显示状态会显示锁定按钮，用户点击后可以进行锁定和解锁操作，锁定后，左右窗口不再关联，即左侧打开新窗口在左侧显示，右侧打开新窗口在右侧显示。<br>__true__：支持锁定<br>__false__：不支持<br>默认为 `false` |
| logicEntities.body.UX.draggingToFreeForm | ？ | 是否支持应用内 Activity 拖出到悬浮窗。<br>__app__：应用内所有 Activity 均支持拖出到悬浮窗<br>__window__：只有在 `logicEntities.body.Activities` 中配置了`isSupportDraggingToFreeform` 为 `true` 的 Activity 才支持拖出到悬浮窗<br>__off__: 关闭应用的拖出到悬浮窗功能 |

> 说明
>
>“？”：取值为0/1<br>
>“*”：可取多个数值

## 针对小米的适配

敬请期待

## 相关链接

* [适配指南](https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/config-introduction-0000001054270212) - 华为开发者联盟
* [业务介绍](https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/introduction-0000001051507626) - 华为开发者联盟
* [适配指导](https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/adaptation-guidance-0000001054031462) - 华为开发者联盟

