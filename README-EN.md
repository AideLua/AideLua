# Aide Lua
[![license](https://img.shields.io/github/license/Jesse205/AideLua)](LICENSE)
[![releases](https://img.shields.io/github/v/tag/Jesse205/AideLua?color=C71D23&label=releases&logo=gitee)](https://gitee.com/Jesse205/AideLua/releases)

[![QQ group: 628045718](https://img.shields.io/badge/QQ_group-628045718-0099FF?logo=tencentqq)](https://jq.qq.com/?_wv=1027&k=41q8mp8y)
[![QQ channel: t37c1u1nmw](https://img.shields.io/badge/QQ_channel-t37c1u1nmw-0099FF?logo=tencentqq)](https://pd.qq.com/s/ncghvc)

[![Gitee repository](https://img.shields.io/badge/Gitee-repository-C71D23?logo=gitee)](https://gitee.com/Jesse205/AideLua/)
[![Github repository](https://img.shields.io/badge/Github-repository-0969DA?logo=github)](https://github.com/Jesse205/AideLua)
[![document](https://img.shields.io/badge/documents-Chinese-3F51B5)](https://jesse205.github.io/AideLua/)

![cover](images/ic_cover-aidelua.png)

###### Language:
[中文](README.md) | [English](README-EN.md)

## Alert
If you need to use the source code, please go to the [releases (Github)](https://github.com/Jesse205/AideLua/releases/latest) page to download.

Please not to change the repository directly in Github, because Github's repository is mirrored by Gitee。

## Introduction
Aide Lua is a Lua editor relying on Aide<br>
Aide Lua allows you to enjoy advanced and rapid software development on mobile devices<br>
Aide Lua can help you transfer from Androlua+to AIDE and then to Android Studio=

## Download
### Gradle for AIDE Pro
[![189 Cloud (Offical)](https://img.shields.io/badge/189_Cloud-Offical-DF9C1F?style=flat-square)](https://cloud.189.cn/t/jAFR7vAVniuu)
[![123 Pan (Image)](https://img.shields.io/badge/123_Pan-Image-597dfc)](https://www.123pan.com/s/G7a9-c9ek)

### AIDE Pro
[![Offical (Recommend)](https://img.shields.io/badge/Offical_website-Recommend-28B6F6)](https://aidepro.netlify.app/)
[![Lanzou (Offical)](https://img.shields.io/badge/Lanzou-v2.6.45-FF6600?logo=icloud&logoColor=white)](https://www.lanzouy.com/b00zdhbeb)

### Aide Lua Pro
[![Gitee Releases)](https://img.shields.io/github/v/tag/Jesse205/AideLua?color=C71D23&label=Gitee+Releases&logo=gitee)](https://gitee.com/Jesse205/AideLua/releases/latest)

#### Other channels (may not be updated in time)
[![123 Pan](https://img.shields.io/badge/123_Pan--597dfc)](https://www.123pan.com/s/G7a9-Yzck)
[![189 Cloud](https://img.shields.io/badge/189_Cloud--DF9C1F)](https://cloud.189.cn/t/ZZ7RzijyqiUv)
[![Weiyun](https://img.shields.io/badge/Weiyun--2980ff)](https://share.weiyun.com/oLiNtxMR)
[![Baidu Netdisk](https://img.shields.io/badge/Baidu_Netdisk-jxnb-06a7ff)](https://pan.baidu.com/s/1j1RwisPR8iq1fPS3O_fl7Q?pwd=jxnb)

## Build project (including derivative projects)
1. Clone this project locally: `git clone https://gitee.com/Jesse205/AideLua.git` .
2. Build with Gradle: `gradle build` .
3. Copy to `internal storage/AppProjects/<your project>` on your Android device.
4. Download the Aide Lua distribution, go to Aide Lua and select the project you just copied, then click `menu-projects... -repack and install` .

## Instructions
1. By default, this software enables automatic code saving and cannot be closed (trigger conditions for automatic saving: switching to other applications, clicking on secondary packaging and packaging operation, opening files, and closing files)
2. This software cannot be used to develop large projects
3. This software must be matched with a compiler, no matter whether you use a real gradle or a false gradle (AIDE belongs to a false gradle)
4. To run the project directly, you must export `LuaActivity` (the default is export), __and successfully installed the project software (first packaged with AIDE, then packaged with Aide Lua, and finally installed)__.

## How to receive update push
Watch this project.

## Documents
[Video](https://space.bilibili.com/1229937144)
[Text](https://jesse205.github.io/AideLua/)

Due to the particularity of AIDE, please download [__AIDE Pro__](https://aidepro.top/) to operate.

### Quick Get Start
#### 1. Configuring AIDE
1. Enter `Settings - Advanced Settings - Project Related`.
2. Close `Enable adrt debug file`, open `Redefine Apk build path`, `启用Gradle` (You do not need to open this item if you do not use Gradle)
3. Restart AIDE.

#### 2. Initial packaging
1. Click New Project in AideLua, and click `New` after filling in and selecting.
2. Open the project with AIDE and click `Build Refresh` (Or 'run', 'gradle assembleRelease', recommended).
3. Click the `repack and install` button of AideLua (or `repack`, but manual signature is required) and install it. Test whether it can be packaged and run normally.
4. Click the `Run` button of AideLua to test whether the installed application debugging passes normally.

## Matters Needing Attention
1. AIDE must use the `AIDE Pro`, otherwise it cannot be opened `Redefine the Apk path` .
2. AIDE must open `Redefine apk path`, otherwise APK error will be caused.
3. AIDE Better Close `adrt Debug File` .
4. It is not necessary to compile with AIDE, but it can also be compiled with Android Studio

## Open Source License
[https://gitee.com/Jesse205/AideLua/blob/master/app/src/main/assets_bin/licences](https://gitee.com/Jesse205/AideLua/blob/master/app/src/main/assets_bin/licences)
