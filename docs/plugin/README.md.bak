---
next:
  text: main.aly 配置
  link: pages/main.md
---

# 插件文档

Util 版本：v3.1
::: details 本页内容
[[toc]]
:::
[插件模板](https://gitee.com/AideLua/AideLua/tree/master/app/plugins/templates/)

## 提示

1. 本文档部分说明格式为 “__变量名__ (数据类型): 说明” 或 “__数据类型__: 说明”
2. 标有 <Badge type="danger" text="X" vertical="middle" /> 的表示已废除，相关 API 已被移除
3. 标有 <Badge type="danger" text="*" vertical="middle" /> 的表示必须文件、方法 或 变量
4. 软件写的比较随意，因此您可以随意调用API，就像是修改软件本身一样，此文档只是起帮助理解的作用。

::: warning
已废除的 API 无法继续使用，因此您需要进行特殊的判断，请谨慎提高 `targetcode` ，以免造成用户数据损失
:::

::: danger 建议最低的最低适配软件版本
我们强烈建议从 __v5.1.0(51099)或以上__ 开始适配，因为在 v5.1.0 发生了巨大变化，大到开发者自己都不知道改了啥。本文档有非常多地方待修正或者补充，如果您发现了某处有问题，希望您可以联系我们以修复。
:::

## 手动导入

1. 打开文件管理，进入 `内部存储/Android/media/com.jesse205.aidelua2/files/plugins` ，如果没有此文件夹就手动新建一个
2. 下载插件（扩展名通常为 `zip` 或 `alp` ，当然也不排除还有其他扩展名）
3. 使用 zip 格式打开插件，打开 `init.lua` 文件，复制 `packagename` (包名) 的参数（ `=` 后面，不带引号）
4. 在 `plugins` 文件夹 里面新建文件夹，重命名为 插件的 `packagename` (就是刚刚复制的文字)
5. 解压插件内所有的文件，到*第4步*新建的文件夹
6. 重启 AideLua

## 注意事项:

1. 目标版本和最低版本请按实际情况填写，最低为 `50099`
2. 扩展名应为 `alp` (Androlua+ 扩展) 或 `zip`
3. 为了防止污染全局变量，插件内直接赋值为插件的局部变量。如要修改全局变量，请使用 `_G.xxx=xxx`

## 通用 API

::: warning
尽量避免使用 Jesse205 库。因为 Jesse205 库每次改动都比较大，很容易引起插件报错。
:::

::: tip
Aide Lua 的插件通常以植入代码的方式实现。<br>
您可以在 Github 或者 Gitee 上查看此程序的源码，以便编写良好的插件。
:::

### PluginsUtil <Badge text="table" vertical="middle" /> <Badge text="Util" vertical="middle" />

插件相关 API，也是支持插件运行的模块

| 变量 | 说明 |
| ---- | ---- |
| _VERSION | __string__: Util 版本 |
| PLUGINS_PATH | __string__: 插件存放路径 |
| PLUGINS_DATA_PATH | __string__: 插件数据存放路径 |

#### PluginsUtil.getPluginDataPath(packageName)

获取插件数据目录

| 参数 | 说明 |
| ------------- | ---- |
| packageName | __string__: 插件包名。 |

#### PluginsUtil.getPluginPath(packageName)

获取插件目录

| 参数 | 说明 |
| ---- | ---- |
| packageName | __string__: 插件包名，如果文件夹名与真正的 `init.lua` 中的 `packagename` 不同，则 `packageName` 传入文件夹名。 |

#### PluginsUtil.clearOpenedPluginPaths() <Badge text="在 v5.0.4(50499) 添加" vertical="middle" />

清除已启用插件列表，用于重新加载插件

### activityName <Badge text="string" vertical="middle" />

当前页面 (Activity) 名，可能为 `nil`

| 值 | 说明 |
| ---- | ----- |
| main | 主页面 |
| settings | 软件设置页面 |
| newproject | 新建工程页面 <Badge text="v5.0.4+" vertical="middle" /> |
| viewclass | 查看类页面 <Badge text="v5.0.4+" vertical="middle" /> |
| about | 关于页面 <Badge text="v5.0.4+" vertical="middle" /> |
| layouthelper | 布局助手页面 <Badge text="v5.0.4+" vertical="middle" /> |
| javaapi | JavaAPI查看器页面 <Badge text="v5.0.4+" vertical="middle" /> |

### getPluginDataPath(packageName)

获取插件数据目录，与 [`PluginsUtil.getPluginDataPath(packageName)`](#pluginsutil-getplugindatapath-packagename) 完全相同

### getPluginPath(packageName)

获取插件目录，与 [`PluginsUtil.getPluginPath(packageName)`](#pluginsutil-getpluginpath-packagename) 完全相同

## 插件文件说明

### <Badge type="danger" text="*" vertical="middle" /> init.lua <Badge text="文件" vertical="middle" />

插件入口，也用于存放模块信息的文件

| 变量 | 说明 |
| ---- | ---- |
| <Badge type="danger" text="*" vertical="middle" /> appname | __string__: 插件名 |
| <Badge type="danger" text="*" vertical="middle" /> packagename | __string__: 插件包名 |
| <Badge type="danger" text="*" vertical="middle" /> appname | __string__: 插件名 |
| <Badge type="danger" text="*" vertical="middle" /> appver | __string__: 插件版本名 |
| <Badge type="danger" text="*" vertical="middle" /> appcode | __number__: 插件版本号 |
| <Badge type="danger" text="*" vertical="middle" /> packagename | __string__: 插件包名 |
| mode  | __string__: 模式，默认为 `"plugin"` |
| utilversion | __string__: Util版本，此变量不起任何作用，当前为 `"3.1"`  |
| thirdplugins | __table (list)__: 需要安装的第三方库 <br > 内容: 插件的包名 |
| supported2 | __table (map)__: 支持的APP列表 <br > 索引: 软件代号 (`apptype`) <br > 内容: __table (map)__: 支持的版本，mincode为最低版本，targetcode为最高版本 |
| events | __table (map)__: 全局事件 |

::: details 已弃用

| 变量 | 说明 | 原因 |
| ---- | ---- | ---- |
| <Badge type="danger" text="*" vertical="middle" /> minemastercode <Badge type="danger" text="Util v3.1 废除" vertical="middle" /> | __number__: 最低支持的APP版本号。 | 多个宿主只能使用相同的版本 |
| <Badge type="danger" text="*" vertical="middle" /> targemastercode <Badge type="danger" text="Util v3.1 废除" vertical="middle" /> | __number__: 目标适配的APP版本号。 | 多个宿主只能使用相同的版本 |
| supported <Badge type="danger" text="Util v3.1 废除" vertical="middle" /> | __table (list)__: 支持的APP列表。此变量在 Util 版本 `3.1` 弃用。 | 未指定宿主版本 |

:::

::: tip 
全局事件与独立事件基本一致。

但与独立的事件相比，第一个参数为页面名称，但是很可能为 `nil`）
:::

::: warning
`init.lua` 中运行中不会有各种内置变量，只有在运行后会将环境表设置为 `metatable` ，自动取 `_G` 中的值
:::

::: details 彩蛋

| 软件代号 ( `apptype` )  | 代指软件 |
| ---- | ---- |
| aidelua | Aide Lua (Pro) |
| eddelua | Edde Lua (截止目前此app不支持插件) |
| alstudio | Android Lua Studio (截止目前此app仅存于想象) |
| yunchu_jesse205 | 云储 优化版 (截止目前此app不支持插件) |
| eddeyunchumanager | Edde 后台管理 (截止目前此app仅存于想象) |
| userstatistics | 用户统计 (截止目前此app仅存于想象) |
| goapk_jesse205 | GoApk (截止目前此app仅存于想象且已停止) |
| highapk | 良心APK (截止目前此app仅存于想象) |
| eddebrowser | Edde 浏览器 (截止目前此app仅存于想象) |
| eddeconnect | Edde 互联 (截止目前此app仅存于想象) |
| eddestudy | Edde 学习桌面 (截止目前此app仅存于想象) |
| eddemusic | Edde 音乐(截止目前此app仅存于想象) |
| eddevideo | Edde 视频(截止目前此app仅存于想象) |
| eddebook | Edde 阅读(截止目前此app仅存于想象) |
| hellotool | 哈兔Box (截止目前此app不支持此类型插件) |
| androidbox | 安卓工具箱 (截止目前此app仅存于想象) |

:::

### main.lua <Badge text="文件" vertical="middle" />

插件主页面

| 参数顺序 (...) | 说明 |
| ---- | ---- |
| 1 | 项目路径 |
| 2 | 文件路径 |

### config/events/ <Badge text="文件夹" vertical="middle" />

存放各个页面的独立事件的文件夹

* 文件扩展名: `aly` (不支持 `lua` )
* 文件名称: `<页面标识>.aly`
* 文件示例: `main.aly`、`settings.aly` ......
* 更多请见 [`page` 目录](pages/main.md)
