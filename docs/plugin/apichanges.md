# API变更说明
更新日期：2022.11.1
::: details 本页内容
[[toc]]
:::

### v5.0.2(50299)
1. `createVirtualClass(normalTable)` 增加 `__index` 方法
    * 作用：使 `Manager` 可以直接赋值
2. `PermissionUtil.smartRequestPermission(permissions)` 方法已删除
    * 作用：被 `PermissionUtil.askForRequestPermissions(permissionsLists)` 代替，更好申请权限
3. 新增 `LuaEditorHelper.initKeysTaskFunc(keyWords,jesse205KeyWords)`
4. 新增 `LuaEditorHelper.initKeys(editor,editorParent,pencilEdit,progressBar)`

### v5.0.3(50399)
1. `onCreate(savedInstanceState)` 先执行模块的 `onCreate` ，再执行本身的代码。如果模块的返回 `true` ，则不执行本身的代码。
    * 作用：支持更多功能（如：新增 `keys` ，启动时选择性打开文件）
2. `PluginsUtil.callElevents(name, ...)` 将降低 `false` 的优先级
    * 作用：使程序逻辑更完善
3. `PluginsUtil.loadPlugins()` 并不总是校验所有插件的启用状态
    * 作用：提升子页面的打开速度
4. `PluginsUtil` 升级3.1版本
5. `PluginsUtil.getReallyEnabled(enabled,config)` 是否真的已启用
6. 模块 `init.lua` 移除 `minemastercode` 、`targetmastercode` 、`supported` ，详情请见 Wiki
7. 模块 `init.lua` 新增 `icon-night` ，自适应夜间模式图标

### v5.0.4(50499)
::: details API 名称变更
SharedData：
 原名称 | 新名称 | 说明 |
| ---- | ---- | --- |
| Jesse205Lib_Highlight | jesse205Lib_support | Jesse205 库支持 |
| AndroidX_Highlight | androidX_support | AndroidX 库支持 |

Jesse205 库：
| 原名称 | 新名称 | 说明 |
| ---- | ---- | --- |
| Jesse205 | jesse205 | Jesse205库基本上所有的语句 |
| AppPath.AppSdcardCacheDataDir | AppPath.AppSdcardDataCacheDir | Android/data/`<packagename>`/cache |
| AppPath.AppShareDir | AppPath.AppMediaDir | Android/media/`<packagename>`/cache |
| AppPath.AppShareCacheDir | AppPath.AppMediaCacheDir | Android/media/`<packagename>`/cache |

其他 API：
| 原名称 | 新名称 | 说明 |
| ---- | ---- | --- |
| RePackTool.getMainProjectName | RePackTool.getMainModuleName | 那个东西叫模块 |

:::

::: details 页面标识变更
| 原标识 | 新标识 | 说明 |
| ---- | ---- | --- |
| / | newproject | 新建工程页面 |
| / | about | 关于页面 |
| / | layouthelper | 布局助手页面 |
| / | javaapi | JavaAPI查看器页面 |
| / | viewclass | 查看类页面 |
:::

::: details 参数变更
| 函数名 | 原参数 | 新参数 | 说明 |
| ---- | ---- | --- | --- |
| FilesTabManager.closeFile | (lowerFilePath,`blockOpen`,changeEditor) | (lowerFilePath,`removeTab`,changeEditor) | __removeTab__: 移除文件标签，默认为`true` |
| getFilePathCopyMenus | (inLibDirPath,filePath,fileName,isFile,fileType)  | (inLibDirPath,filePath,`fileRelativePath`,<br>fileName,isFile,`isResDir`,fileType) | |
:::

:::: details 废除 API
::: warning
您必须及时删除这些API，否则您的插件将无法运行
:::
| 名称 | 说明 |
| ---- | --- |
| EditorsManager.keyWords | 默认关键词 |
| EditorsManager.jesse205KeyWords | Jesse205 库关键词 |

::::

::: details 新增 API
| 名称 | 说明 |
| ---- | --- |
| AppPath.AppDataTempDir | /data/data/`<packagename>`/files/temp |
| AppPath.AppSdcardDataTempDir | Android/data/`<packagename>`/files/temp |
| AppPath.AppMediaTempDir | Android/media/`<packagename>`/files/temp |
| editorLayouts.LuaEditor.packagesList| 待加载的包地图/列表 |
| editorLayouts.LuaEditor.keywordsList| 待加载的关键词地图/列表 |
| FileTemplates.enName | 模板英文名 |
| FileTemplates.id | 模板标识 |
| FilesBrowserManager.providers | 文件浏览器提供者 |
| ProjectManager.reopenProject() | 重新打开项目。 <br> <Badge type="warning" text="*" vertical="middle" /> 由于此API，项目可能会在未关闭旧项目的情况下打开新的项目。 |
| formatColor2Hex(color) | 将 number 类型的颜色值转换为字符串的16进制 <br> __color__ (number): 颜色值 <br> __return__ (string): 颜色值 |
| getColorAndHex(text) | 获取文字内颜色的数值和16进制 <br> __text__ (number): 待分析的文本 <br> __return__ (number), (string): 颜色值 |
| getTableIndexList(mTable) | 获取table的索引列表 <br> __mTable__ (table): 随便的 table <br> __return__ (table (list)): mTable的索引列表 |
| editorLayouts[EditorName]<br>.onTypefaceChangeListener(ids,config,<br>editor,typeface,boldTypeface,italicTypeface) | 当编辑器字体发生改变时 |

PluginsUtil：
| 名称 | 说明 |
| ---- | --- |
| clearOpenedPluginPaths() | 清除已启用的插件路径列表 |

类库：
| 名称 | 说明 |
| ---- | --- |
| db | LuaDB, [在 Github 上查看](https://github.com/limao996/LuaDB) |

:::

::: details 新增事件
| 名称 | 说明 |
| ---- | --- |
| onStart() | [了解详情](/AideLua/plugin/pages/main.html#onstart) |
| onStop() | [了解详情](/AideLua/plugin/pages/main.html#onstop) |
| onKeyShortcut(keyCode, event) | [了解详情](/AideLua/plugin/pages/main.html#onkeyshortcut-keycode-event) |
:::

1.  `FilesTabManager.closeFile(lowerFilePath,removeTab,changeEditor)` 第二个变量由原来没用的 `blockOpen` 改为 `removeTab` ，默认为 `true`
2.  NoneView 将不在启动时初始化
     * 作用：优化代码
3.  新增 `ProjectManager.reopenProject()` ，项目可能会在未关闭旧项目的情况下打开新的
     * 作用：刷新 `config.lua`
4.  `EditorsManager.keyWords` 与 `EditorsManager.jesse205KeyWords` 已废除，已由 `editorLayouts.LuaEditor.packagesList` 、`editorLayouts.LuaEditor.keywordsList` 代替
     * 作用：方便插件添加关键字
5.  SharedData 中将 `Jesse205Lib_Highlight` 与 `AndroidX_Highlight` 已被 `jesse205Lib_support` 与 `androidX_support` 取代
     * 作用：统一变量
6.  页面标识新增 `newproject` ，`about` ，`layouthelper` ，`javaapi` ，`viewclass` 页面
     * 作用：更方便地添加内容
7.  Jesse205 库的 `Jesse205` 改为 `jesse205` ，哪里报错就看哪里吧
     * 作用：好看
8.  `main` 页面 `bottomAppBar` 不再固定大小
9.  `RePackTool` 工具的 `getMainProjectName` 已更名为 `getMainModuleName`
10.  修复 `main` 页面 `onResume` 的 `notFirstOnResume`始终为 `true` 的 bug，并且现在可以返回true阻止程序继续运行
11.  `AppPath.AppSdcardCacheDataDir` 已更名为 `AppPath.AppSdcardDataCacheDir`，`AppPath.AppShareDir`已更名为`AppPath.AppMediaDir`，`AppPath.AppShareCacheDir `已更名为 `AppPath.AppMediaCacheDir` ，新增 `AppPath.AppSdcardDataTempDir`等路径
12.  `main` 页面新增 `formatColor2Hex(color)` 与 `getColorAndHex(text)`
13.  FileTemplates 新增 `enName` 与 `id`
     * 作用：新增中文，切换语言时保持选项不变
14.  `getFilePathCopyMenus()` 的参数改为 `(inLibDirPath,filePath,fileRelativePath,fileName,isFile,isResDir,fileType)`，新增了 `fileRelativePath` 与 `isResDir`
     * 作用：能获取到更多的复制菜单
15.  新增文件浏览器提供者，`FilesBrowserManager.providers`
     * 作用：更自由添加文件菜单
16.  新增模块 `db`，[在 Github 上查看](https://github.com/limao996/LuaDB)
17. 新增 `editorLayouts[EditorName].onTypefaceChangeListener(ids,config,editor,typeface,boldTypeface,italicTypeface)`
    * 作用：提供个性化字体
18.  新增 `onStart` 与 `onStop` 等事件，[了解详情](/AideLua/plugin/pages/main.html#onstart)
19.  新增 `PluginsUtil.clearOpenedPluginPaths()`，清除已启用的插件路径列表
     * 作用：方便重载插件
20.  新增 `getTableIndexList(mTable)`，获取table的索引列表