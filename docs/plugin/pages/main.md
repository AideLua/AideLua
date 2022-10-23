未完待续
## config/events/main.aly
主页面事件存放文件
### 事件说明
#### onCreate(savedInstanceState)
Activity 生命周期：onCreate

这是页面创建时候执行的事件 <br>
此时软件即将自动打开上一次或者传入的工程，以及刷新 `toggle` 状态

| 参数 | 说明 |
| ---- | --- |
| savedInstanceState | __Bundle__: 如果 Activity 在先前被关闭后被重新初始化，那么这个 Bundle 包含它最近在 onSaveInstanceState(Bundle) 中提供的数据。注意：默认值为空。|

| 返回类型 | 说明 |
| ---- | --- |
| boolean | 如果返回 `true` 则停止执行接下来的操作（如：自动打开工程等）。 |

代码执行顺序：
> 执行插件事件 - 判断返回值，检测并打开项目 - 同步 `toggle` 状态

::: warning 注意
返回值在版本 `v5.0.3(50399)` 添加

在 `v5.0.3(50399)` 之前，代码执行顺序为：
> 检测并打开项目 - 执行插件事件 - 同步 `toggle` 状态
:::

#### onCreateOptionsMenu(menu)
这是创建菜单时执行的事件

| 参数 | 说明 |
| ---- | --- |
| menu | __Menu__: 你在其中放置项目的选项菜单。|

代码执行顺序：
> 添加自带菜单 - 执行插件事件

#### onOptionsItemSelected(item)
这是菜单被点击时执行的事件

| 参数 | 说明 |
| ---- | --- |
| item | __MenuItem__: 被选中的菜单项。此值不能为空。|

代码执行顺序：
> 添加自带菜单 - 执行插件事件 - 标记 `LoadedMenu` 为 `true` - 刷新菜单状态

::: warning
Aide Lua 未使用标准的菜单更新方式，因此您使用 `activity.invalidateOptionsMenu()` 无法刷新菜单显示
:::

#### onKeyShortcut(keyCode, event)
按键被按
当一个快捷键事件没有被 Activity 中的任何视图处理时被调用。覆盖此方法以实现 Activity 的全局按键快捷方式。按键快捷方式也可以通过设置菜单项的快捷方式属性来实现。

| 参数 | 说明 |
| ---- | --- |
| keyCode| __int__: event.getKeyCode() 中的值。 |
| event | __KeyEvent__: 按键事件的描述。 |

| 返回类型 | 说明 |
| ---- | --- |
| boolean | 如果返回 `true` 则停止执行接下来的操作（响应自带快捷键）。 |

代码执行顺序：
> 执行插件事件 - 判断返回值，执行自带快捷键

::: warning 注意
返回值在版本 `v5.0.4(50499)` 添加

在 `v5.0.4(50499)` 之前，代码执行顺序为：
> 执行自带快捷键 - 执行插件事件
:::

#### onConfigurationChanged(config)
配置文件发生改变，常见于屏幕旋转

#### onResume()
常见于返回到页面

#### onDestroy()
Activity销毁时执行，常见于关闭页面

#### onResult(name, action, content)
 有返回参数时执行
 
#### refreshMenusState()
刷新菜单状态

### 页面API
#### EditorsManager `table` `Manager`
| 键 | 类型 | 说明 |
| ---- | ---- | ---- |
| \[x\] keyWords | 忘了 | 编辑器提示关键词列表 |
| \[x\] jesse205KeyWords | 忘了 | Jesse205库关键词列表 |
| \[x\] fileType2Language | 忘了 | 文件类型转语言索引列表 |
| [actions](#editorsmanager-actions-table-manager) | table (map) | 编辑器事件列表 |
| openNewContent(filePath,fileType,decoder) | function | 打开新内容 <br> __filePath__ (string): 文件路径 <br> __fileType__ (string): 文件扩展名 <br> __decoder__ (metatable(map)): 文件解析工具 |
| startSearch() | function | 启动搜索 |
| save2Tab() | function | 保存到标签 |
| checkEditorSupport(name) | function | 检查编辑器是否支持功能 <br> __name__ (string): 功能名称 |
| isEditor() | function | 是不是可编辑的编辑器 |
| switchPreview(state) | function | 切换预览 <br> __state__ (boolean): 状态 |
| switchLanguage(language) | function | 切换语言 <br> __language__ (Object): 语言 |
| switchEditor(editorType) | function | 切换编辑器 <br> __editorType__ (string): 编辑器类型|
| [symbolBar](#editorsmanager-symbolbar-table-manager) | table (class) | 符号栏 |

##### EditorsManager.actions `table` `Manager`
| 键 | 类型 | 返回类型 | 说明 |
| ---- | ---- | ---- | --- |
| undo() | function | / | 撤销 |
| redo() | function | / | 重做 |
| format() | function | / |格式化 |
| commented() | function | / |注释 |
| getText() | function | string" | 获取编辑器文字内容 |
| setText() | function | / | 设置编辑器文字内容 |
| check(show) | function | / | 代码查错 <br> __show__ (string): 展示结果 |
| paste(text) | function | / | 粘贴文字内容 <br> __text__ (string): 文字内容 |
| setTextSize(size) | function | / | 设置文字大小 <br> __size__ (number): 文字大小 |
| search(text,gotoNext) | function | / | 搜索 <br> __text__ (number): 搜索内容 <br> __gotoNext__ (boolean): 是否搜索下一个 |

##### EditorsManager.symbolBar `table` `Util`
| 键 | 类型 | 说明 |
| ---- | ---- | ---- |
| psButtonClick(view) | function (listener)| 符号栏按钮点击时输入符号点击事件 |
| newPsButton(text) | function | 初始化一个符号栏按钮 |
| refreshSymbolBar(state) | function | 刷新符号栏状态 <br> _state__ (boolean): 开关状态 |

#### FilesBrowserManager `table` `Manager`

#### FilesTabManager `table` `Manager`

#### ProjectManager `table` `Manager`

#### 其他API
##### showSnackBar(text)
显示 SnackBar (底部提示)

| 参数 | 说明 |
| ---- | --- |
| text | __string__: 显示的文字

##### openFileITPS(path)
用外部应用打开文件

| 参数 | 说明 |
| ---- | --- |
| path | __string__: 文件路径|
