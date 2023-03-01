未完待续
# viewclass.aly <Badge text="文件" vertical="middle" /> <Badge text="table" vertical="middle" /> <Badge text="Map" vertical="middle" />

::: details 本页内容
[[toc]]
:::

`config/events/viewclass.aly` : 设置页面事件存放文件

## 事件说明

### onCreate(savedInstanceState) <Badge text="生命周期" vertical="middle" />

[Activity 生命周期：onCreate()](https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn#oncreate)

这是页面创建时候执行的事件 <br>

| 参数 | 说明 |
| ---- | --- |
| savedInstanceState | __Bundle__: 如果 Activity 在先前被关闭后被重新初始化，那么这个 Bundle 包含它最近在 onSaveInstanceState(Bundle) 中提供的数据。注意：默认值为空。|
