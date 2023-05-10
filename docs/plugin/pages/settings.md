# settings.aly <Badge text="文件" vertical="middle" /> <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" />

::: details 本页内容
[[toc]]
:::

`pages/settings.lua` : 设置页面配置文件

## 事件说明

### onCreate(savedInstanceState) <Badge text="生命周期" vertical="middle" />

[Activity 生命周期：onCreate()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#oncreate)

这是页面创建时候执行的事件 <br>

| 参数               | 说明                                                                                                                                            |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| savedInstanceState | __Bundle__: 如果 Activity 在先前被关闭后被重新初始化，那么这个 Bundle 包含它最近在 onSaveInstanceState(Bundle) 中提供的数据。注意：默认值为空。 |

### onLoadItemList(items)

列表加载事件，此处您可以添加您的插件的设置项

| 参数  | 说明                                   |
| ----- | -------------------------------------- |
| items | __table__ (list): 插件专属的设置项列表 |


### onItemClick(views,key,data)

点击项目事件

| 参数  | 说明                        |
| ----- | --------------------------- |
| views | __table__ (map): 视图映射   |
| key   | __string__: 设置项的 `key`  |
| data  | __table__ (map): 设置项映射 |

## 设置项说明

这是一个简单的设置项示例：

``` lua
--在 `onLoadItemList(items)` 事件中
--创建一个设置项
item={
  SettingsLayUtil.ITEM_NOSUMMARY;
  icon="";
  title="设置项标题";
  key="plugin_item";
  newPage=false;
}
--将新创建的设置项添加到列表内
table.insert(items,item)
```

当然通常不会创建一个新的 `item` 变量，因此会这么写

``` lua
--在 `onLoadItemList(items)` 事件中
table.insert(items,{
  SettingsLayUtil.ITEM_NOSUMMARY;
  icon="";
  title="设置项标题";
  key="plugin_item";
  newPage=false;
})
```

| 键      | 说明                                                                                                                                     |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `[1]`   | item 第一项，是一个 `number` 类型的类型ID                                                                                                |
| icon    | __string__: 图标路径，建议使用绝对路径                                                                                                   |
| title   | __string__: 设置项标题                                                                                                                   |
| summary | __string__: 设置项介绍                                                                                                                   |
| key     | __string__: 设置项标识，相当于设置项的ID                                                                                                 |
| newPage | __boolean__; __string__: 新页面标识，`true` 表示新页面，`"newApp"` 表示新APP，`false` 表示保持当前页面。此键仅用于设置右侧图标显示的类型 |


:::: details 这是受支持的类型

| 字段                  | 数字 | 说明                         |
| --------------------- | ---- | ---------------------------- |
| TITLE                 | 1    | 标题项                       |
| ITEM                  | 2    | 设置项，带有标题和介绍       |
| ITEM_NOSUMMARY        | 3    | 设置项，仅带有标题           |
| ITEM_SWITCH           | 4    | 设置项，带有标题、介绍和开关 |
| ITEM_SWITCH_NOSUMMARY | 5    | 设置项，带有标题和开关       |
| ITEM_AVATAR           | 6    | 设置项，但是图标为大图       |
| ITEM_ONLYSUMMARY      | 7    | 设置项，仅带有标题           |


::: tip
除标题外，每个项目都带有一个图标
:::
::::

::: warning
请避免直接使用数字类型，因为不同软件版本所代表的设置项类型可能不一样

所有的字段都在 `SettingsLayUtil` 中，请使用 `SettingsLayUtil.XXX` 的形式获取类型ID，如：`SettingsLayUtil.ITEM_NOSUMMARY`
:::

::: tip
您可以使用 `getPluginPath(packagename)` 获取当前插件存放路径，以确定图标存放路径

比如您的插件有一个图标
``` 文件树:no-line-numbers
我的插件
  ├ ...
  ├ init.lua
  └ icon.png <--
```
您可以使用 `getPluginPath(packagename).."/icon.png"` 得到 `icon.png` 的路径
:::
