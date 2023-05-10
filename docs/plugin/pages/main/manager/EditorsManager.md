待修改
# EditorsManager <Badge text="table" vertical="middle" /> <Badge text="Manager" vertical="middle" />

| 键 | 类型 | 说明 |
| ---- | ---- | ---- |
| editor | View | 编辑器视图 |
| [editorConfig](#editorlayouts) | table (map) | 编辑器配置 |
| editorType | string | 编辑器名称（有时也叫做编辑器类型） |
| [actions](#editorsmanager-actions) | table (map) | 编辑器事件映射 |
| [actionsWithEditor](#editorsmanager-actionswitheditor) <Badge text="v5.1.1+" vertical="middle" /> | table (map) | 编辑器事件映射，支持指定编辑器 |
| openNewContent(filePath,fileType,decoder) | function | 打开新内容 <br> __filePath__ (string): 文件路径 <br> __fileType__ (string): 文件扩展名 <br> __decoder__ (metatable(map)): 文件解析工具 |
| startSearch() | function | 启动搜索 |
| save2Tab() | function | 保存到标签 |
| checkEditorSupport(name) | function | 检查编辑器是否支持功能 <br> __name__ (string): 功能名称 |
| isEditor() | function | 是不是可编辑的编辑器 |
| switchPreview(state) | function | 切换预览 <br> __state__ (boolean): 状态 |
| switchLanguage(language) | function | 切换语言 <br> __language__ (Object): 语言 |
| switchEditor(editorType) | function | 切换编辑器 <br> __editorType__ (string): 编辑器类型|
| [symbolBar](#editorsmanager-symbolbar) | table (map) | 符号栏 |
| [typefaceChangeListeners](#editorsmanager-typefacechangelisteners) <Badge text="v5.0.4+" vertical="middle" /> | table (list) | 编辑器字体监听器 |
| [sharedDataChangeListeners](#editorsmanager-shareddatachangelisteners) <Badge text="v5.1.0+" vertical="middle" /> | table (map) | 软件配置监听器 |
| refreshEditorScrollState() | function | 刷新编辑器滚动状态，包括阴影。 |
| magnifier <Badge text="v5.1.0+" vertical="middle" /> |  table (map) | 放大镜管理器 |

## EditorsManager.typefaceChangeListeners <Badge text="table" vertical="middle" /> <Badge text="List" vertical="middle" /> <Badge text="Listener" vertical="middle" /> <Badge text="v5.0.4+" vertical="middle" />

编辑器字体监听器

格式：
``` lua
{
    function(typeface, boldTypeface, italicTypeface)
        -- typeface: 支持字体
        -- boldTypeface: 粗体
        -- italicTypeface: 斜体 (意大利体)

        -- 这里开始写你的代码
    end,
    -- ...
}
```

::: tip
在编辑器初始化时，一般不需要您刻意地把 `onTypefaceChangeListener` 添加到此列表。因为 EditorsManager 会自动帮您完成添加。
:::


## EditorsManager.sharedDataChangeListeners <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" /> <Badge text="Listener" vertical="middle" /> <Badge text="v5.1.0+" vertical="middle" />
编辑器字体监听器

格式：
``` lua
{
    key1={
      function(newValue)
        -- newValue: 新值
        -- 这里开始写你的代码
      end,
      -- ...
    },
    key2={
      function(newValue)
        -- newValue: 新值
        -- 这里开始写你的代码
      end,
      -- ...
    }
    -- ...
}
```

::: tip
在编辑器初始化时，一般不需要您刻意地把 `onSharedDataChangeListeners` 添加到此列表。因为 EditorsManager 会自动帮您完成添加。
:::

## EditorsManager.actions <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" />

| 键 | 类型 | 返回类型 | 说明 |
| ---- | ---- | ---- | --- |
| undo() | function | / | 撤销 |
| redo() | function | / | 重做 |
| format() | function | / |格式化 |
| commented() | function | / |注释 |
| getText() | function | string | 获取编辑器文字内容 |
| setText() | function | / | 设置编辑器文字内容 |
| check(show) | function | / | 代码查错 <br> __show__ (string): 展示结果 |
| paste(text) | function | / | 粘贴文字内容 <br> __text__ (string): 文字内容 |
| setTextSize(size) | function | / | 设置文字大小 <br> __size__ (number): 文字大小 |
| search(text,gotoNext) | function | / | 搜索 <br> __text__ (number): 搜索内容 <br> __gotoNext__ (boolean): 是否搜索下一个 |
| getSelectedText() | function | string | 获取已选择的文字 |
| ... | function | ... | 此 table 已设置为 metatable，因此您可以像调用 View 一样调用编辑器 |

::: tip
如果调用 `getXxx` 类型以外的 API 时，第一个返回值为编辑器是否支持该功能的 Boolean 值

对于编辑器插件开发者，您需要在自定义事件内返回 `true` ，表示编辑器支持此功能
:::
## EditorsManager.actionsWithEditor <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" /> <Badge text="v5.1.1+" vertical="middle" />

和 [`EditorsManager.actions`](#editorsManager-actions) 差不多，唯一的区别是他的方法们首个参数为 `editorConfig` ，以指定编辑器。

## EditorsManager.symbolBar <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" />

| 键 | 类型 | 说明 |
| ---- | ---- | ---- |
| getReallPasteText(view) <Badge text="v5.1.0+" vertical="middle" /> | function | 获取符号栏要粘贴到文字 |
| onButtonClickListener(view) <Badge text="v5.1.0+" vertical="middle" /> | function (listener)| 符号栏按钮点击时输入符号 |
| onButtonLongClickListener(view) <Badge type="danger" text="仅 v5.1.0" vertical="middle" />  | function (listener)| 符号栏按钮长按时显示预览 |
| psButtonClick(view) <Badge type="danger" text="v5.1.0 废除" vertical="middle" /> | function (listener)| 符号栏按钮点击时输入符号点击事件 |
| newPsButton(text,config) | function | 初始化一个符号栏按钮 <br> __config__ (table): 按钮配置 <Badge text="v5.1.0+" vertical="middle" /> |
| refresh(state) | function | 刷新符号栏状态 <br> __state__ (boolean): 开关状态 |
| symbols <Badge text="v5.1.0+" vertical="middle" /> | table (list) | 按钮配置 |

## EditorsManager.magnifier <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" /> <Badge text="v5.1.0+" vertical="middle" />

* __类型__：MagnifierManager
