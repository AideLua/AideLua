---
next:
  text: main.aly 配置
  link: pages/main.md
---

# 插件文档 <Badge type="tip" text="v4.0 (alpha)" />

* __PluginsManager 版本__：v4.0

::: tip
您正在浏览 PluginsManager v4.0.0 版本文档，新版本 Aide Lua 结构发生了巨大变化，删除了旧版本的所有 API。如需浏览旧版本文档，请转到[这里](old/README.md)。
:::

::: details 本页内容
[[toc]]
:::
[插件模板](https://gitee.com/AideLua/AideLua/tree/master/app/plugins/templates/)

## 提示

1. 本文档部分说明格式为 “__变量名__ (数据类型): 说明” 或 “__数据类型__: 说明”
2. 标有 <Badge type="danger" text="已废除" vertical="middle" /> 的表示已废除，相关 API 或方法已被移除
3. 标有 <Badge type="danger" text="*" vertical="middle" /> 的表示必须文件、方法 或 变量
4. 部分 AndroLua+ 插件也可以使用，但是效果不好

::: warning
已废除的 API 无法继续使用，因此您需要进行特殊的判断，请谨慎提高 `targetcode` ，以免造成用户体验下降，甚至用户数据丢失
:::

::: danger 建议最低的最低适配软件版本
我们强烈建议从 __v5.2.0(52099) 或以上__ 开始适配，因为在 v5.2.0 发生了翻天覆地的变化，软件架构及运行逻辑发生了巨大变化。
:::

## 手动导入

1. 打开文件管理，进入 `内部存储/Android/media/com.jesse205.aidelua2/files/plugins` ，如果没有此文件夹就手动新建一个
2. 下载插件（扩展名通常为 `zip` 或 `alp` ，当然也不排除还有其他扩展名）
3. 使用 zip 格式打开插件，打开 `init.lua` 文件，复制 `packagename` (包名) 的参数（ `=` 后面，不带引号）
4. 在 `plugins` 文件夹 里面新建文件夹，重命名为 插件的 `packagename` (就是刚刚复制的文字)
5. 解压插件内所有的文件，到*第4步*新建的文件夹
6. 重启 AideLua

::: warning
插件解压文件夹必须与插件包名一致
:::

## 注意事项

1. 目标版本和最低版本请按实际情况填写。
2. 宿主版本号符合 `显示版本 迭代版本` ，其中 `迭代版本` 为 `99` 时代表正式版本。如 `52099` 代表 `v5.2.0正式版`。
3. 扩展名应为 `alp` (兼容 Androlua+ 扩展) 或 `zip`（Aide Lua 专属扩展）
4. 为了防止污染全局变量，插件内直接赋值为插件的局部变量。如要修改全局变量，请使用 `_APP_G.xxx=xxx`
5. 插件不可直接访问全局变量。如需访问，请通过 `_APP_G.xxx` 来访问全局变量
6. 插件管理器不会自动添加插件路径为环境变量。因此您不可以直接使用 `import` 或者 `require`
7. 请充分利用 `thirdplugins` 变量，因为某些插件可能需要正确的执行顺序才能运行

## 内置插件

### Jesse205 Library Support

Jesse205框架的支持插件

[查看源代码]()

### AndroidX Support

[查看源代码]()

## 通用 API

::: warning
请尽量避免使用 Jesse205 框架。因为 Jesse205 框架每次改动都比较大，很容易引起插件报错。
:::

::: tip

:::

### PluginsManager <Badge text="table" vertical="middle" /> <Badge text="Manager" vertical="middle" />

插件管理器

插件相关 API，也是支持插件运行的模块

| 常量              | 说明                         |
| ----------------- | ---------------------------- |
| _VERSION          | __string__: Util 版本        |
| PLUGINS_PATH      | __string__: 插件存放路径     |
| PLUGINS_DATA_PATH | __string__: 插件数据存放路径 |

#### PluginsManager.getPluginDataPath(packageName:string)

获取插件数据目录

| 参数        | 说明                   |
| ----------- | ---------------------- |
| packageName | __string__: 插件包名。 |

| 返回值类型 | 说明             |
| ---------- | ---------------- |
| string     | 插件数据存放目录 |

#### PluginsManager.getPluginPath(packageName:string)

获取插件目录

| 参数        | 说明                                                                                                           |
| ----------- | -------------------------------------------------------------------------------------------------------------- |
| packageName | __string__: 插件包名，如果文件夹名与真正的 `init.lua` 中的 `packagename` 不同，则 `packageName` 传入文件夹名。 |

| 返回值类型 | 说明             |
| ---------- | ---------------- |
| string     | 插件存放目录 |

#### PluginsManager.clearEnabledPluginPaths()

清除已启用插件列表，用于重新加载插件

#### PluginsManager.getEnabledPluginPaths()

获取已启用插件路径列表

| 返回值类型 | 说明             |
| ---------- | ---------------- |
| String[]     | 插件存放目录 |

### activityName <Badge text="string" vertical="middle" />

当前页面 (Activity) 名，可能为 `nil`

| 值           | 说明              |
| ------------ | ----------------- |
| main         | 主页面            |
| settings     | 软件设置页面      |
| newproject   | 新建工程页面      |
| viewclass    | 查看类页面        |
| about        | 关于页面          |
| layouthelper | 布局助手页面      |
| javaapi      | JavaAPI 查看器页面 |

### pluginDataPath <Badge text="string" vertical="middle" />

获取插件数据目录，与 [`PluginsManager.getPluginDataPath(packageName)`](#pluginsmanager-getplugin-data-path-packagename-string) 完全相同

### pluginPath <Badge text="string" vertical="middle" />

获取插件目录，与 [`PluginsManager.getPluginPath(packageName)`](#pluginsutil-getpluginpath-packagename) 完全相同

## 插件文件说明

### README.md <Badge text="文件" vertical="middle" /> <Badge text="v5.1.1+" vertical="middle" />

插件的说明文档

::: danger
说明文档的文件名只能是 `README.md` ，不能是 `readme.md` 、 `README.txt` 或其他。
:::

### <Badge type="danger" text="*" vertical="middle" /> init.lua <Badge text="文件" vertical="middle" />

插件入口，也用于存放模块信息的文件

| 变量                                                           | 说明                                                                                                                                             |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| <Badge type="danger" text="*" vertical="middle" /> appname     | __string__: 插件名                                                                                                                               |
| <Badge type="danger" text="*" vertical="middle" /> packagename | __string__: 插件包名                                                                                                                             |
| <Badge type="danger" text="*" vertical="middle" /> appname     | __string__: 插件名                                                                                                                               |
| <Badge type="danger" text="*" vertical="middle" /> appver      | __string__: 插件版本名                                                                                                                           |
| <Badge type="danger" text="*" vertical="middle" /> appcode     | __number__: 插件版本号                                                                                                                           |
| <Badge type="danger" text="*" vertical="middle" /> packagename | __string__: 插件包名                                                                                                                             |
| mode                                                           | __string__: 模式，默认为 `"plugin"`                                                                                                              |
| utilversion                                                    | __string__: Util版本，此变量不起任何作用，当前为 `"3.1"`                                                                                         |
| thirdplugins                                                   | __table (list)__: 需要安装的第三方库 <br > 内容: 插件的包名                                                                                      |
| supported2                                                     | __table (map)__: 支持的APP列表 <br > 索引: 软件代号 (`apptype`) <br > 内容: __table (map)__: 支持的版本，mincode为最低版本，targetcode为最高版本 |
| events                                                         | __table (map)__: 全局事件                                                                                                                        |

::: details 已弃用

| 变量                                                                                                                               | 说明                                                             | 原因                       |
| ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------- |
| <Badge type="danger" text="*" vertical="middle" /> minemastercode <Badge type="danger" text="Util v3.1 废除" vertical="middle" />  | __number__: 最低支持的APP版本号。                                | 多个宿主只能使用相同的版本 |
| <Badge type="danger" text="*" vertical="middle" /> targemastercode <Badge type="danger" text="Util v3.1 废除" vertical="middle" /> | __number__: 目标适配的APP版本号。                                | 多个宿主只能使用相同的版本 |
| supported <Badge type="danger" text="Util v3.1 废除" vertical="middle" />                                                          | __table (list)__: 支持的APP列表。此变量在 Util 版本 `3.1` 弃用。 | 未指定宿主版本             |

:::

::: tip 
全局事件与独立事件基本一致。

但与独立的事件相比，第一个参数为页面名称，但是很可能为 `nil`）
:::

::: warning
`init.lua` 中运行中不会有各种内置变量，只有在运行后会将环境表设置为 `metatable` ，自动取 `_G` 中的值
:::

::: details 彩蛋

| 软件代号 ( `apptype` ) | 代指软件                                     |
| ---------------------- | -------------------------------------------- |
| aidelua                | Aide Lua (Pro)                               |
| eddelua                | Edde Lua (截止目前此app不支持插件)           |
| alstudio               | Android Lua Studio (截止目前此app仅存于想象) |
| yunchu_jesse205        | 云储 优化版 (截止目前此app不支持插件)        |
| eddeyunchumanager      | Edde 后台管理 (截止目前此app仅存于想象)      |
| userstatistics         | 用户统计 (截止目前此app仅存于想象)           |
| goapk_jesse205         | GoApk (截止目前此app仅存于想象且已停止)      |
| highapk                | 良心APK (截止目前此app仅存于想象)            |
| eddebrowser            | Edde 浏览器 (截止目前此app仅存于想象)        |
| eddeconnect            | Edde 互联 (截止目前此app仅存于想象)          |
| eddestudy              | Edde 学习桌面 (截止目前此app仅存于想象)      |
| eddemusic              | Edde 音乐(截止目前此app仅存于想象)           |
| eddevideo              | Edde 视频(截止目前此app仅存于想象)           |
| eddebook               | Edde 阅读(截止目前此app仅存于想象)           |
| hellotool              | 哈兔Box (截止目前此app不支持此类型插件)      |
| androidbox             | 安卓工具箱 (截止目前此app仅存于想象)         |

:::

### main.lua <Badge text="文件" vertical="middle" />

插件主页面

| 参数顺序 (...) | 说明     |
| -------------- | -------- |
| 1              | 项目路径 |
| 2              | 文件路径 |

### config/events/ <Badge text="文件夹" vertical="middle" />

存放各个页面的独立事件的文件夹

* 文件扩展名: `aly` (不支持 `lua` )
* 文件名称: `<页面标识>.aly`
* 文件示例: `main.aly`、`settings.aly` ......
* 更多请见 [`page` 目录](pages/main.md)
