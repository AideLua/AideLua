未完待续

# main.aly <Badge text="文件" vertical="middle" /> <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" />

::: details 本页内容
[[toc]]
:::

`pages/main.lua` : 主页面配置文件

## 事件说明

### onCreate(savedInstanceState) <Badge text="生命周期" vertical="middle" />

[Activity 生命周期：onCreate()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#oncreate)

这是页面创建时候执行的事件

此时软件即将自动打开上一次或者传入的工程，以及刷新 `toggle` 状态

| 参数               | 说明                                                                                                                                                |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| savedInstanceState | __Bundle__: 如果 Activity 在先前被关闭后被重新初始化，那么这个 Bundle 包含它最近在 onSaveInstanceState(Bundle) 中提供的数据。注意：默认值为 `nil`。 |

| 返回类型 | 说明                                                           |
| -------- | -------------------------------------------------------------- |
| boolean  | 如果返回 `true` 则停止执行接下来的操作（如：自动打开工程等）。 |

代码执行顺序：

> 调用插件事件 - 判断返回值，检测并打开项目 - 同步 `toggle` 状态

::: warning 注意
在 __v5.0.3(50399)__ 之前，代码执行顺序为：
> 检测并打开项目 - 调用插件事件 - 同步 `toggle` 状态
:::

### onCreateOptionsMenu(menu)

这是创建菜单时执行的事件

| 参数 | 说明                                   |
| ---- | -------------------------------------- |
| menu | __Menu__: 你在其中放置项目的选项菜单。 |

代码执行顺序：

> 添加自带菜单 - 执行插件事件

### onOptionsItemSelected(item)

这是菜单被点击时执行的事件

| 参数 | 说明                                         |
| ---- | -------------------------------------------- |
| item | __MenuItem__: 被选中的菜单项。此值不能为空。 |

代码执行顺序：

> 添加自带菜单 - 调用插件事件 - 标记 `LoadedMenu` 为 `true` - 刷新菜单状态

::: warning
Aide Lua 未使用标准的菜单更新方式，因此您使用 `activity.invalidateOptionsMenu()` 无法刷新菜单显示。相反，您应该使用 `refreshMenusState()` 来刷新菜单显示。
:::

### onKeyShortcut(keyCode, event)

按键被按 当一个快捷键事件没有被 Activity 中的任何视图处理时被调用。覆盖此方法以实现 Activity 的全局按键快捷方式。按键快捷方式也可以通过设置菜单项的快捷方式属性来实现。

| 参数    | 说明                                 |
| ------- | ------------------------------------ |
| keyCode | __int__: event.getKeyCode() 中的值。 |
| event   | __KeyEvent__: 按键事件的描述。       |

| 返回类型 | 说明                                                       |
| -------- | ---------------------------------------------------------- |
| boolean  | 如果返回 `true` 则停止执行接下来的操作（响应自带快捷键）。 |

代码执行顺序：
> 调用插件事件 - 判断返回值，响应自带快捷键事件

### onConfigurationChanged(config)

配置文件发生改变，常见于屏幕旋转

| 参数   | 说明                                          |
| ------ | --------------------------------------------- |
| config | Configuration__: 新设备配置。此值不能为 `nil` |

* [Configuration](https://developer.android.google.cn/reference/android/content/res/Configuration) - Android 开发者

### onResume() <Badge text="生命周期" vertical="middle" />

[Activity 生命周期：onResume()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#onresume)

常见于返回到页面

### onPause() <Badge text="生命周期" vertical="middle" /> <Badge text="v5.1.1+" vertical="middle" />

[Activity 生命周期：onPause()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#onpause)

Activity 暂停时执行，常见于切到后台

### onStart() <Badge text="生命周期" vertical="middle" /> <Badge text="v5.0.4+" vertical="middle" />

[Activity 生命周期：onStart()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#onstart)

Activity 开始时执行，常见于回到页面

### onStop() <Badge text="生命周期" vertical="middle" /> <Badge text="v5.0.4+" vertical="middle" />

[Activity 生命周期：onStop()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#onstop)

Activity 停止时执行，常见于切到后台

### onDestroy() <Badge text="生命周期" vertical="middle" />

[Activity 生命周期：onDestroy()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#ondestroy)

Activity 销毁时执行，常见于关闭页面

### onResult(name, action, content)

有返回参数时执行，这里一般都是Lua页面返回的。

| 参数    | 说明                                                 |
| ------- | ---------------------------------------------------- |
| name    | 页面名称，Androlua 自动赋的值，多半为 `main`，不要管 |
| action  | 事件名称，如 `project_created_successfully`          |
| content | 返回的内容，目前只能接收一个内容                     |

::: tip
在新Lua页面中返回参数：

``` lua
activity.result({<action>，<content>})
```

:::

### refreshMenusState()

刷新菜单状态

## 管理器、工具 API

* [EditorsManager](./main/EditorsManager.md): 编辑器管理器
* FilesBrowserManager: 文件浏览器管理器
* FilesTabManager: 这是标签页管理器
* DecodeCenter: 解析中心。插件推荐使用此工具修改配置

### FilesBrowserManager <Badge text="table" vertical="middle" /> <Badge text="Manager" vertical="middle" />

这是文件浏览器管理器（侧滑）

未完待续

| 键             | 类型        | 说明                                       |
| -------------- | ----------- | ------------------------------------------ |
| providers      | table (map) | 提供者映射                                 |
| highlightIndex | number      | 高亮显示的项目索引（从 0 开始）            |
| openState      | boolean     | 侧滑打开状态                               |
| directoryFile  | File        | 当前文件浏览器文件夹，未打开工程时为 `nil` |

| 方法                                  | 说明                                                                                                               |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| isModuleRootPath(path)                | 判断是不是模块根路径                                                                                               |
| getNowModuleDirName(fileRelativePath) | 获取当前模块目录名称，如果当前路径不在模块内，则返回主模块名称<br> __fileRelativePath__ (string): 相对与项目的路径 |


### FilesTabManager <Badge text="table" vertical="middle" /> <Badge text="Manager" vertical="middle" />

这是标签页管理器，兼职管理文件的读取与保存

| 方法                                                                  | 说明                                   |
| --------------------------------------------------------------------- | -------------------------------------- |
| getScrollDbKeyByPath(path) <Badge text="v5.1.1+" vertical="middle" /> | 自动通过当前编辑器获取滚动的数据库的键 |


### ProjectManager <Badge text="table" vertical="middle" /> <Badge text="Manager" vertical="middle" />

这是项目管理器，只能管理单个项目，兼职提供文件路径的绝对路径转相对路径

| 方法                         | 说明                                                                       |
| ---------------------------- | -------------------------------------------------------------------------- |
| refreshProjectsPath(autoFix) | 刷新工程路径<br>__autoFix__ (boolean): 是否自动修复路径错误，默认为 `true` |

### LuaEditorHelper <Badge text="table" vertical="middle" /> <Badge text="Manager" vertical="middle" />

这是 LuaEditor 助手，可以方便处理很多东西

## 其他 API

### 快速检查文件是否相同

#### isSamePathFileByPath(filePath1,filePath2)

通过文件路径比较文件是否相同

| 参数      | 说明                       |
| --------- | -------------------------- |
| filePath1 | __string__: 第一个文件路径 |
| filePath2 | __string__: 第二个文件路径 |

#### isSamePathFile(file1,file2)

通过文件本身比较文件是否相同

| 参数  | 说明                 |
| ----- | -------------------- |
| file1 | __File__: 第一个文件 |
| file2 | __File__: 第二个文件 |

### 颜色类

#### formatColor2Hex(color)

将 number 类型的颜色值转换为字符串的16进制

| 参数  | 说明               |
| ----- | ------------------ |
| color | __number__: 颜色值 |

| 返回类型 | 说明   |
| -------- | ------ |
| string   | 颜色值 |

#### getColorAndHex(text)

获取文字内颜色的数值和16进制

| 参数 | 说明                     |
| ---- | ------------------------ |
| text | __number__: 待分析的文本 |

| 返回类型 | 说明   |
| -------- | ------ |
| number   | 颜色值 |
| string   | 颜色值 |

### editorLayouts <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" />

编辑器布局等配置

#### 格式说明

``` lua
EditorViewName={
  layout={ -- 编辑器布局
    -- ...
  },
  action={ -- 编辑器的各种事件
    undo="default",
    redo="default",
    format="default",
    search="default",
    getText="default",
    setText="default",
    -- ...
  },
  init=function(ids,config)
    -- 初始化事件
    -- ...
  end,
  onTypefaceChangeListener=function(ids,config,editor,typeface,boldTypeface,italicTypeface)
    -- typeface: 正常字体
    -- boldTypeface: 加粗字体
    -- italicTypeface: 意大利体（斜体）
    -- ...
  end,
  onSharedDataChangeListeners={
    editor_wordwrap=function(ids,config,editor,newValue)
      -- ...
    end,
    -- ...
  },
  supportScroll=false;-- 支持滚动
},
```

#### LuaEditor 说明

在 `LuaEditor` 下面，还有

``` lua
---将要添加到LuaEditor的关键词列表
---更改后需要执行 application.set("luaeditor_initialized", false) ，以便在下次进入页面时更新
---使用 activity.recreate() 重启页面
---index 为方便更改内容，请使用 string 类型，当然 number 类型也能用
---@type table<string, String[]>
keywordsList={
  --一些常用但不自带的类
  annotationsWords=String{"class","type","alias","param","return","field","generic","vararg","language","example"},
  otherWords=String{"PhotoView","LuaLexerIteratorBuilder"},
},

---@type table<string, String[]>
---@see keywordsList
packagesList={
  --otherPackages=Map{hello=String{"world"},jesse205=String{"nb"}},
},
```

::: warning
除此之外还有`jesse205Keywords`与`normalKeywords`，这些是编辑器默认的关键字，您不应该动这些东西
:::

### showSnackBar(text)

显示 SnackBar (底部提示)

| 参数 | 说明                   |
| ---- | ---------------------- |
| text | __string__: 显示的文字 |

### openFileITPS(path)

用外部应用打开文件

| 参数 | 说明                 |
| ---- | -------------------- |
| path | __string__: 文件路径 |

### runLuaFile(file,code)

在单独的页面运行Lua代码

| 参数 | 说明               |
| ---- | ------------------ |
| file | __File__: 文件对象 |
| code | __string__: 代码   |

::: warning 注意
当 `file` 不为 `nil` ，并且此文件存在时，则直接运行此文件，否则运行 `code` 中的代码
:::

### showSnackBar(text)

智能根据侧滑栏打开状态显示 SnackBar

| 参数 | 说明                   |
| ---- | ---------------------- |
| text | __string__: 提示的内容 |

### getTableIndexList(mTable)

获取table的索引列表

| 参数   | 说明                    |
| ------ | ----------------------- |
| mTable | __table__: 随便的 table |

| 返回类型     | 说明             |
| ------------ | ---------------- |
| table (list) | mTable的索引列表 |

### authorizeHWApplicationPermissions(uri) <Badge text="v5.1.0+" vertical="middle" />

目的是兼容华为文件管理的拖拽功能。

授予 Action 为 `android.intent.action.SEND` 并且 Flag 为 `268435456`的所有应用、`com.huawei.desktop.systemui` 和 `com.huawei.desktop.explorer` `uri` 的权限（自动获取类型）。

### safeLoadLayout(path,parent) <Badge text="v5.1.1+" vertical="middle" />

安全加载 lua 布局，避免污染全局变量

| 参数   | 说明                     |
| ------ | ------------------------ |
| path   | __string__: 随便的 table |
| parent | __ViewGroup__: 父布局类  |

| 返回类型 | 说明       |
| -------- | ---------- |
| View     | 生成的视图 |

### copyFilesFromDocumentFile(documentFile,targetPath) <Badge text="v5.1.1+" vertical="middle" />

复制文件，从 DocumentFile 内。目前文件夹只能复制 DocumentUi 的 uri

| 参数         | 说明                    |
| ------------ | ----------------------- |
| documentFile | __DocumentFile_: 原文件 |
| targetPath   | __string__: 目标文件夹  |

### runInTermux(cmd,args,config) <Badge text="v5.1.1+" vertical="middle" />

在 Termux 内运行代码

| 参数   | 说明                      |
| ------ | ------------------------- |
| cmd    | __string__: 运行的程序    |
| args   | __table(string[])__: 参数 |
| config | __table(map)__: 配置      |

### path2DocumentUri(path) <Badge text="v5.1.1+" vertical="middle" />

将路径转换为 DocumentUi的 uri

| 参数 | 说明             |
| ---- | ---------------- |
| path | __string__: 路径 |
