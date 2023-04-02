# LuaActivity

LuaActivity 继承自 `android.app.Activity`，因此您可以使用 Activity 的全部方法

AndroLua+ 的每一个 lua 页面都是 LuaActivity 以及他的子类。

AndroLua+ 的每一个 lua 页面都对应一个 Lua 脚本

在 Lua 脚本中，变量 `activity` 与 `this` 都是当前页面都 LuaActivity 实例对象，因此您可以很方便的使用安卓各种api。

比如：
:::: code-group
::: code-group-item activity

``` lua
import "android.view.View"
import "android.widget.LinearLayout"

-- 创建一个TextView
textView = TextView(activity)
textView.setText("Hello World")
-- 创建一个布局，并把view添加到布局内
layout = LinearLayout(activity)
layout.addView(textView)
-- 将layout加载到根view上
activity.setContentView(layout)
```

:::
::: code-group-item this

``` lua
import "android.view.View"
import "android.widget.LinearLayout"

-- 创建一个TextView
textView = TextView(this)
textView.setText("Hello World")
-- 创建一个布局，并把view添加到布局内
layout = LinearLayout(this)
layout.addView(textView)
-- 将layout加载到根view上
this.setContentView(layout)
```

:::
::::

::: tip 注意
在 Task 线程中，`this` 指的是 `LuaAsyncTask` 的实例对象。
:::
## 方法 | Method

### getLuaDir()

获取Lua运行路径

### newActivity()

进入一个新的 Lua 页面