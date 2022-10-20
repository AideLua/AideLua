# 部分函数参考
* AndroLua 库函数在 `import` 模块，为便于使用都是全局变量。
* `a` 表示参数，`[a]` 可选，`(...)` 表示不定参数 <br>
    * 函数调用在只有一个参数且参数为字符串或表时可以省略括号。
* 表示方法
    * `s` 表示 字符串 类型
    * `i` 表示 整数 类型
    * `n` 表示 浮点数 或 整数 类型
    * `t` 表示 表类 型
    * `b` 表示 布尔 类型
    * `o` 表示 Java对象 类型
    * `f` 为 Lua函数
    * `--` 表示注释。

## each(o)
* 参数：`o` 实现Iterable接口的Java对象
* 返回：用于Lua迭代的闭包
* 作用：Java集合迭代器

## enum(o)
* 参数：`o` 实现Enumeration接口的Java对象
* 返回：用于Lua迭代的闭包
* 作用：Java集合迭代器

## import(s)
* 参数：`s` 要载入的包或类的名称
* 返回：载入的类或模块
* 作用：载入包或类或Lua模块
``` lua
import "http" --载入http模块
import "android.widget.*" --载入android.widget包
import "android.widget.Button" --载入android.widget.Button类
import "android.view.View$OnClickListener" --载入android.view.View.OnClickListener内部类
```

## loadlayout(t [,t2])
* 参数：`t` 要载入的布局表，`t2` 保存view的表
* 返回：布局最外层view
* 作用：载入布局表，生成view
``` lua
layout={
    LinearLayout,
    layout_width="fill",
    {
        TextView,
        text="Androlua",
        id="tv"
    }
}
main={}
activity.setContentView(loadlayout(layout,main))
print(main.tv.getText())
```

## loadbitmap(s)
* 参数：`s` 要载入图片的地址，支持相对地址，绝对地址与网址
* 返回：bitmap对象
* 作用：载入图片
* 注意：载入网络图片需要在线程中进行

## task(s [,...], f)
* 参数：`s` 任务中运行的代码或函数，`...` 任务传入参数，`f` 回调函数
* 返回：无返回值
* 作用：在异步线程运行Lua代码，执行完毕在主线程调用回调函数
* 注意：参数类型包括 布尔，数值，字符串，Java对象，不允许Lua对象
``` lua
function func(a,b)
    require "import"
    print(a,b)
    return a+b
end
task(func,1,2,print)
```

## thread(s[,...])
* 参数：`s` 线程中运行的lua代码或脚本的相对路径(不加扩展名)或函数，`...` 线程初始化参数
* 返回：返回线程对象
* 作用：开启一个线程运行Lua代码
* 注意：线程需要调用quit方法结束线程
``` lua
func=[[
a,b=...
function add()
    call("print",a+b)
end
]]
t=thread(func,1,2)
t.add()
```

## timer(s,i1,i2[,...])
* 参数：`s` 定时器运行的代码或函数，`i1` 前延时，`i2` 定时器间隔，`...` 定时器初始化参数
* 返回：定时器对象
* 作用：创建定时器重复执行函数
``` lua
function f(a)
    function run()
        print(a)
        a=a+1
    end
end

t=timer(f,0,1000,1)
t.enabled=false--暂停定时器
t.enabled=true--重新定时器
t.stop()--停止定时器
```

## luajava.bindClass(s)
* 参数：`s` class的完整名称，支持基本类型
* 返回：Java class对象
* 作用：载入Java class
``` lua
Button=luajava.bindClass("android.widget.Button")
int=luajava.bindClass("int")
```

## luajava.createProxy(s,t)
* 参数：`s` 接口的完整名称，`t` 接口函数表
* 返回：Java接口对象
* 作用：创建Java接口
``` lua
onclick=luajava.createProxy("android.view.View$OnClickListener",{onClick=function(v)print(v)end})
```

## luajava.createArray(s,t)
* 参数：`s` 类的完整名称，支持基本类型，`t` 要转化为Java数组的表
* 返回：创建的Java数组对象
* 作用：创建Java数组
``` lua
arr=luajava.createArray("int",{1,2,3,4})
```

## luajava.newInstance(s [,...])
* 参数：`s` 类的完整名称，`...` 构建方法的参数
* 作用：创建Java类的实例
``` lua
b=luajava.newInstance("android.widget.Button",activity)
```

## luajava.new(o[,...])
* 参数：`o` Java类对象，`...` 参数
* 返回：类的实例或数组对象或接口对象
* 作用：创建一个类实例或数组对象或接口对象
* 注意：当只有一个参数且为表类型时，如果类对象为interface创建接口，为class创建数组，参数为其他情况创建实例
``` lua
b=luajava.new(Button,activity)
onclick=luajava.new(OnClickListener,{onClick=function(v)print(v)end})
arr=luajava.new(int,{1,2,3})
```
(示例中假设已载入相关类)

## luajava.coding(s [,s2 [, s3]])
* 参数：`s` 要转换编码的Lua字符串，`s2` 字符串的原始编码，`s3` 字符串的目标编码
* 返回：转码后的Lua字符串
* 作用：转换字符串编码
* 注意：默认进行GBK转UTF8

## luajava.clear(o)
* 参数：`o` Java对象
* 返回：无
* 作用：销毁Java对象
* 注意：仅用于销毁临时对象

## luajava.astable(o)
* 参数：`o` Java对象
* 返回：Lua表
* 作用：转换Java的Array List或Map为Lua表

## luajava.tostring(o)
* 参数：`o` Java对象
* 返回：Lua字符串
* 作用：相当于 `o.toString()`
