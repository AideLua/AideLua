更新日期：2022.10.15
### v5.0.2(50299)
1. `createVirtualClass(normalTable)` 增加 `__index` 方法
    作用：使 `Manager` 可以直接赋值
2. `PermissionUtil.smartRequestPermission(permissions)` 方法已删除
    作用：被 `PermissionUtil.askForRequestPermissions(permissionsLists)` 代替，更好申请权限
3. 新增 `LuaEditorHelper.initKeysTaskFunc(keyWords,jesse205KeyWords)`
4. 新增 `LuaEditorHelper.initKeys(editor,editorParent,pencilEdit,progressBar)`

### v5.0.3
1. `onCreate(savedInstanceState)` 先执行模块的 `onCreate` ，再执行本身的代码。如果模块的返回 `true` ，则不执行本身的代码。
    作用：支持更多功能（如：新增 `keys` ，启动时选择性打开文件）
2. `PluginsUtil.callElevents(name, ...)` 将降低 `false` 的优先级
    作用：使程序逻辑更完善
3. `PluginsUtil.loadPlugins()` 并不总是校验所有插件的启用状态
    作用：提升子页面的打开速度
4. `PluginsUtil` 升级3.1版本
5. `PluginsUtil.getReallyEnabled(enabled,config)` 是否真的已启用
6. 模块 `init.lua` 移除 `minemastercode` 、`targetmastercode` 、`supported` ，详情请见 Wiki
7. 模块 `init.lua` 新增 `icon-night` ，自适应夜间模式图标

### v5.0.4
v5.0.4
1. `FilesTabManager.closeFile(lowerFilePath,removeTab,changeEditor)` 第二个变量由原来没用的 `blockOpen` 改为 `removeTab` ，默认为 `true`
2. NoneView将不在启动时初始化
3. 新增 `ProjectManager.reopenProject()` 项目可能会在未关闭旧项目的情况下打开新的
    作用：刷新 `config.lua`
4. `EditorsManager.keyWords` 与 `EditorsManager.jesse205KeyWords` 已废除，已由 `editorLayouts.LuaEditor.packagesList` 、`editorLayouts.LuaEditor.keywordsList` 代替
    作用：方便插件添加关键字
5. SharedData 中将 `Jesse205Lib_Highlight` 与 `AndroidX_Highlight` 已被 `jesse205Lib_support` 与 `androidX_support` 取代
    作用：统一变量
6. 页面标识新增 `newproject` ，`about` ，`layouthelper` ，`javaapi` ，`NewProject` 页面
    作用：更方便地添加内容
7. Jesse205 库的 `Jesse205` 改为 `jesse205` ，哪里报错就看哪里吧
    作用：好看
8. `main` 页面 `bottomAppBar` 不再固定大小
9. `RePackTool` 工具的 `getMainProjectName` 已更名为 `getMainModuleName`
10. 修复 `main` 页面 `onResume` 的 `notFirstOnResume`始终为 `true` 的 bug，并且现在可以返回true阻止程序继续运行
11. `AppPath.AppSdcardCacheDataDir` 已更名为 `AppPath.AppSdcardDataCacheDir`，`AppPath.AppShareDir`已更名为`AppPath.AppMediaDir`，`AppPath.AppShareCacheDir `已更名为 `AppPath.AppMediaCacheDir` ，新增 `AppPath.AppSdcardDataTempDir`等路径
12. `main` 页面新增 `formatColor2Hex(color)` 与 `getColorAndHex(text)`
13. FileTemplates 新增 `enName` 与 `id`
    作用：新增中文，切换语言时保持选项不变