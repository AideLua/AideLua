未完待续
# 新建项目

Aide Lua 提供了两种项目。您可以选择不同的项目模板新建项目

## AndroLua+ 项目

::: tip
您可以使用 [ALua 转 AideLua 工具](https://www.123pan.com/s/G7a9-c1ek)将现有 AndroLua+ 工程转换为 Aide Lua 项目
:::

### 配置版本

这是模板配置版本。您可以选择不同的配置版本。一些配置可能包含BUG，您需要及时更新配置版本

* __aide(7.2.1)__: 为 AIDE 定制，Gradle 为 7.2.1 版本

### AndroLua 版本

您可以在这项配置里面选择您喜欢的版本。版本格式为 `AndroLua版本(修订版本)(架构)` （新格式与旧格式不一致，请注意辨别）。

* __5.0.18(1.1)(armeabi-v7a,arm64-v8a)__: 推荐使用的版本。此版本同时拥有 32 位和 64 位 abi。

### 复杂功能（复杂库）

复杂库不是什么专业名字。这个词仅在 Aide Lua 内作为一种库的统称出现

复杂库可以自动更改工程结构、主模块配置，您需要谨慎勾选。

你可以长按 Chip 来查看帮助文件。一些jar可能比较老，请到 GitHub 及时更新版本

::: warning
尽量不要勾选 `Jesse205库` ，因为这是为 Jesse205 专门定制的复杂库（已经不能算是库了），不同人的习惯不相同。但是您可以参考，并复制该库资源。
:::

::: tip
您也可以自行添加属于你自己的复杂库。早期版本的复杂库通过单独的添加复杂库到程序资源目录来实现，这种的弊端就是更新应用会覆盖或者删除已添加的复杂库。
在 `v5.1.0` 以后，您可以通过制作插件来添加属于你自己的复杂库
:::

### Jar 库

这里包含常用的Jar库。你可以长按 Chip 来查看帮助文件。一些jar可能比较老，请到 GitHub 及时更新版本

### Lua & so 库（简单库）

这里是 AndroLua+ 自带的库和单独添加比较常用的库。

## LuaJ++ 项目

暂时不支持LuaJ++项目。作者无法成功运行 LuaJ++ 的 Demo。

::: details 错误信息
``` txt:no-line-numbers
Process: com.aidelua.luajpptest
PID: 27581
Flags: 0x38a8be44
Package: com.aidelua.luajpptest v1099 (1.0)
Foreground: Yes
Lifetime: 0s
Build: HONOR/BLN-AL10/HWBLN-H:8.0.0/HONORBLN-AL10/541(C00):user/release-keys

java.lang.NoClassDefFoundError: Failed resolution of: Lres/Hex;
	at org.luaj.lib.Utf8Lib.$d2j$hex$e2972372$decode_I(:16)
	at org.luaj.lib.Utf8Lib.<clinit>(Unknown Source:10)
	at org.luaj.lib.jse.JsePlatform.standardGlobals(Unknown Source:93)
	at com.androlua.LuaActivity.onCreate(Unknown Source:163)
	at com.androlua.Welcome.onCreate(Unknown Source:0)
	at android.app.Activity.performCreate(Activity.java:7383)
	at android.app.Instrumentation.callActivityOnCreate(Instrumentation.java:1218)
	at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3256)
	at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3411)
	at android.app.ActivityThread.-wrap12(Unknown Source:0)
	at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1994)
	at android.os.Handler.dispatchMessage(Handler.java:108)
	at android.os.Looper.loop(Looper.java:166)
	at android.app.ActivityThread.main(ActivityThread.java:7529)
	at java.lang.reflect.Method.invoke(Native Method)
	at com.android.internal.os.Zygote$MethodAndArgsCaller.run(Zygote.java:245)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:921)
Caused by: java.lang.ClassNotFoundException: Didn't find class "res.Hex" on path: DexPathList[[zip file "/data/app/com.aidelua.luajpptest-_S2BlgbGmVYUMpmUUGRaDw==/base.apk"],nativeLibraryDirectories=[/data/app/com.aidelua.luajpptest-_S2BlgbGmVYUMpmUUGRaDw==/lib/arm64, /system/lib64, /vendor/lib64, /product/lib64]]
	at dalvik.system.BaseDexClassLoader.findClass(BaseDexClassLoader.java:93)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:379)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:312)
	... 17 more
-mainthread -loghandler
```
:::

如果您成功解决此问题并运行 Demo，欢迎提交pl！

## 参考链接

[工程介绍](/project/README.md) <br>
[项目模板介绍](/project/template/README.md)
