# 关于打包

新建工程或在脚本目录新建 `init.lua` 文件。

写入以下内容，即可将文件夹下所有 lua 文件打包，`main.lua` 为程序人口。

``` lua
appname="demo"
appver="1.0"
packagename="com.androlua.demo"
```

目录下 `icon.png` 替换图标，`welcome.png` 替换启动图。

打包使用debug签名。

::: warning 注意
Aide Lua 不支持这种操作，
:::