未完待续
## config/events/main.aly
主页面事件存放文件
### 事件说明
#### onCreate(savedInstanceState)
Activity生命周期：onCreate

这是页面创建时候执行的事件 <br>
此时软件即将自动打开上一次或者传入的工程，以及刷新 toggle 状态

| 参数 | 说明 |
| ---- | --- |
| savedInstanceState | __Bundle__: 如果 Activity 在先前被关闭后被重新初始化，那么这个 Bundle 包含它最近在 onSaveInstanceState(Bundle) 中提供的数据。注意：默认值为空。|

| 返回类型 | 说明 |
| ---- | --- |
| boolean | 是否继续执行操作，如：自动打开工程等。 |

#### onCreateOptionsMenu(menu)
这是创建菜单时执行的事件

| 参数 | 说明 |
| ---- | --- |
| menu | __Menu__: 你在其中放置项目的选项菜单。|

#### onOptionsItemSelected(item)
这是菜单被点击时执行的事件

| 参数 | 说明 |
| ---- | --- |
| item | __MenuItem__: 被选中的菜单项。此值不能为空。|

#### onKeyShortcut(keyCode, event)
按键被按

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
