# 快速入门

AndroLua 是一个使用 Lua 语法编写可以使用安卓 API 的轻型脚本编程工具，使用它可以快速编写安卓应用。

第一次打开程序默认创建 `new.lua` ，并添加以下代码

``` lua
require "import"
import "android.widget."
import "android.view."
```

`require "import"` 是导入 `import` 模块，该模块集成了很多实用的函数，可以大幅度减轻写代码负担，详细函数说明参考程序帮助。

`import "android.widget.*"` 是导入 Java 包。

这里导入了 `android` 的 `widget` 和 `view` 两个包。

导入包后使用类是很容易的，新建类实例和调用 Lua 的函数一样。

比如新建一个 TextView

``` lua
textView=TextView(activity)
```

`activity` 表示当前活动的 `context`。

同理新建按钮

``` lua
button=Button(activity)
```

给视图设置属性也非常简单

``` lua
button.text="按钮"
button.backgroundColor=0xff0000ff -- 这里必须使用 number 类型
```

添加视图事件回调函数

``` lua
button.onClick=function(view)
  print(view)
end
```

函数参数 `view` 是视图本身。

安卓的视图需要添加到布局才能显示到活动，一般我们常用 [`LinearLayout`](https://developer.android.google.cn/develop/ui/views/layout/linear)

``` lua
layout=LinearLayout(activity)
```

用 `addView` 添加视图

``` lua
layout.addView(button)
```

最后调用 `activity` 的 `setContentView()` 方法显示内容

``` lua
activity.setContentView(layout)
```

这里演示 Androlua 基本用法，通常我们需要新建一个工程来开发，代码的用法是相同的，具体细节请详细阅读后面的内容。