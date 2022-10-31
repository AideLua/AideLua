# Aide Lua 使用文档
## 简介
[![QQ 群](https://img.shields.io/badge/加入-QQ_群-0099FF?logo=TencentQQ&style=flat-square)](https://jq.qq.com/?_wv=1027&k=41q8mp8y)
[![QQ 频道](https://img.shields.io/badge/加入-QQ_频道-0099FF?logo=TencentQQ&style=flat-square)](https://pd.qq.com/s/ncghvc)
[![Gitee 发行版](https://img.shields.io/badge/Gitee-发行版-C71D23?logo=gitee&style=flat-square)](https://gitee.com/Jesse205/AideLua/releases)

Aide Lua 是一款依赖 Aide 的 Lua 编辑器<br>
Aide Lua 可以让您在移动设备上也能享受高级的、快速的软件开发

[![杰西205/Aide Lua](https://gitee.com/Jesse205/AideLua/widgets/widget_card.svg?colors=4183c4,ffffff,ffffff,e3e9ed,666666,9b9b9b)](https://gitee.com/Jesse205/AideLua)

## 提示
1. 本文档部分说明格式为 “__变量名__ (数据类型): 说明” 、 “__数据类型__: 说明”
2. 标有 <Badge type="danger" text="X" vertical="middle" /> 的表示已废除，相关 API 已被删除
3. 标有 <Badge type="danger" text="*" vertical="middle" /> 的表示必须文件、方法 或 变量

## 下载
[〖Aide 高级设置版〗](https://www.lanzouy.com/b00zdhbeb)

1. [__Gitee 下载 (推荐，更新及时)__](https://gitee.com/Jesse205/AideLua/releases)
2. [天翼云盘 (可能更新不及时)](https://cloud.189.cn/t/ZZ7RzijyqiUv)
3. [腾讯微云 (可能更新不及时)](https://share.weiyun.com/oLiNtxMR)
4. [百度网盘 (可能今天下不完)](https://pan.baidu.com/s/1j1RwisPR8iq1fPS3O_fl7Q) ，密码jxnb
5. [123云盘 (可能更新不及时)](https://www.123pan.com/s/G7a9-Yzck)

## 使用须知
1. 本软件默认开启自动保存代码且无法关闭（自动保存触发条件：切换到其他应用、点击二次打包以及打包运行、打开其他文件、关闭文件、打开侧滑（大屏除外）、点击标签栏等）
2. 此软件不能用来开发大型项目
3. 此软件必须搭配编译器，不管你用的是真 Gradle 还是假 Gradle（AIDE 属于假 Gradle）
4. 要实现直接运行项目，必须导出 `LuaActivity`（默认是导出的），并成功安装项目软件（先用 AIDE 打包，然后用 Aide Lua 打包，最后安装）

## 使用教程
由于 AIDE 的特殊性，请下载 __AIDE高级设置版__ 进行操作

### 快速入门
#### 一、配置AIDE
1. 进入 `设置`-`高级设置`-`工程相关`
2. 关闭 启用 `alert调试文件` ，打开 `重定义Apk构建路径`
3. 重启 AIDE

#### 二、初次打包
1. 在 AideLua 点击新建项目，在填写与选择完成后点击 `新建`
2. 用 AIDE 打开项目，点击 `构建刷新`
3. 点击 AideLua 的 `二次打包并安装` 按钮（或 `二次打包` ，但需手动签名）并安装，测试是否可以正常打包并运行
4. 点击 AideLua 的 `运行` 按钮，测试是否正常通过已安装的应用调试

## 注意事项
1. AIDE 必须使用 `AIDE高级设置版本` ，否则无法打开 `重定义Apk路径`
2. AIDE 必须打开 `重定义Apk路径` ，否则会导致 APK 错误
3. AIDE 最好关闭 `adrt调试文件` 
4. 不是必须用 AIDE 编译，也可以使用 Android Studio 编译

## 开放源代码许可
[https://gitee.com/Jesse205/AideLua/blob/master/app/src/main/assets_bin/licences](https://gitee.com/Jesse205/AideLua/blob/master/app/src/main/assets_bin/licences)
