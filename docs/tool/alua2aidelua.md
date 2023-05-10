# ALua 转 AideLua 工程

将 AndroLua+ 的工程一键转换为 Aide Lua 项目

* 版本号：v1.2
* 工具类型：应用程序
* 开发者：杰西205
* 工程版本：v5.1.1

## 工具下载

发行版文件：

* [123 云盘](https://www.123pan.com/s/G7a9-c1ek)

源码文件：

* [123 云盘](https://www.123pan.com/s/G7a9-c1ek)
* [Gitee 附件](https://gitee.com/AideLua/AideLua/attach_files/1334992/download)

## 使用方法

1. 选择或者将 *.alp 文件填入“ALP工程路径”编辑框中
2. 选择或填写导出路径
3. 点击“开始转换”按钮

## 注意事项

* 转换后的工程不带 AndroidX，因此您需要从已启用 AndroidX 的项目内复制 `androlua` 模块并在 `gradle.properties`文件内开启 `android.useAndroidX`。
* 转换后默认添加全部支持库。您需要手动删除部分支持库

## 更新日志

### v1.2

1. 修复ALP文件解压失败时没有删除临时文件的bug
2. 修复icon.png未转换的问题（welcome.png 已弃用，因为此方法呈现出来的效果不好）
3. 修复权限错误问题
4. 修复严重的错误
5. 修复版本号错误
