# 插件文档
文档版本：v3.1
## tips
1. 以下部分说明格式为 “变量名: 数据类型: 说明”
2. 标有 `[x]` 的表示已废除
3. 标有 `*` 的表示必须文件、方法 或 变量

## 手动导入
1. 打开文件管理，进入 `内部存储/Android/media/com.Jesse205.aidelua2/files/plugins` ，没有就新建一个
2. 下载插件（通常为 zip 或 alp ）
3. 使用 zip 格式打开插件，打开init.lua文件，复制 `packagename` (包名) 的参数（ `=` 后面，不带引号）
4. 在 `plugins` 文件夹 里面新建文件夹，重命名为 插件的 `packagename` (就是刚刚复制的文字)
5. 解压插件内所有的文件，到 第4步新建的文件夹
6. 重启 AideLua

## 注意事项: 
1. 目标版本和最低版本请按实际情况填写，最低为 `50099`
2. 扩展名应为 `alp` (Androlua+ 扩展) 或 `zip`
3. 为了防止污染全局变量，插件内直接赋值为插件的局部变量。如要修改全局变量，请使用 `_G.xxx=xxx`

### 通用API
#### PluginsUtil `table` `Util`
插件相关API

##### PluginsUtil.getPluginDataPath(packageName) `function`
获取插件数据目录

| 参数 | 说明 |
| ---- | --- |
| packageName | __string__: 插件包名。 |

##### PluginsUtil.getPluginPath(packageName) `function`
获取插件目录

| 参数 | 说明 |
| ---- | --- |
| packageName | __string__: 插件包名，如果文件夹名与真正的 `init.lua` 中的 `packagename` 不同，则 `packageName` 传入文件夹名。 |

#### activityName `string`
当前活动名，可能为 `nil`

| 值 | 说明 |
| ---- | --- |
| main | 主页面 |
| settings | 设置页面 |

#### getPluginDataPath(packageName)
获取插件数据目录，与 [`PluginsUtil.getPluginDataPath(packageName)`](#pluginsutil-getplugindatapath-packagename-function) 完全相同

#### getPluginPath(packageName)
获取插件目录，与 [`PluginsUtil.getPluginPath(packageName)`](#pluginsutil-getpluginpath-packagename-function) 完全相同


## 插件文件说明: 
### \* init.lua
插件入口，也用于存放模块信息的文件

| 变量 | 说明 |
| ---- | --- |
| \* appname | __string__: 插件名 |
| \* packagename | __string__: 插件包名 |
| \* appname | __string__: 插件名 |
| \* appver | __string__: 插件版本名 |
| \* appcode | __number__: 插件版本号 |
| \* packagename | __string__: 插件包名 |
| \[x\] minemastercode | __number__: 最低支持的APP版本号 |
| \[x\] targemastercode | __number__: 目标适配的APP版本号 |
| mode | __string__: 模式，默认为 `"plugin"` |
| utilversion | __string__: Util版本，此变量不起任何作用，当前为 `"3.1"` |
| thirdplugins | __table (list)__: 需要安装的第三方库 <br > 内容: 插件的包名 |
| `[x]` supported | __table (list)__: 支持的APP列表 |
| supported2 | __table (map)__: 支持的APP列表 <br > 索引: 软件代号 (`apptype`) <br > 内容: __table (map)__: 支持的版本，mincode为最低版本，targetcode为最高版本|
| events | __table (map)__: 全局事件（与独立的事件相比，第一个参数为页面名称，但是很可能为 `nil`）

| 软件代号 (`apptype`) | 代指软件 |
| ---- | --- |
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
| eddestudy | Edde 学习桌面 (截止目前此app仅存于想象) 
| hellotool | 哈兔Box (截止目前此app不支持此类型插件) |

### main.lua
插件主页面

| 接收参数 (...) | 说明 |
| ---- | --- |
| prjPath | 项目路径 |
| filePath | 文件路径 |

### config/events/
存放各个页面的事件的文件夹

* 文件扩展名: `aly`
* 文件名称: `页面名称.aly`
* 文件示例: `main.aly` `settings.aly`
* 更多请见 `page` 文件夹

| 文件 | 说明 |
| ---- | --- |
| main.aly | 软件主页面 |
| settings.aly | 软件设置页面 |
| newproject.aly | 新建工程页面 |

