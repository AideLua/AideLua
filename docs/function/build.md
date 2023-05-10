未完待续

# 构建项目

要二次打包，就先要构建项目

您可以选择使用 [Termux](https://github.com/termux/termux-app) 原生方法、[AIDE Pro](https://www.aidepro.top/) 或者 Android IDE 来构建项目

Aide Lua 的构建项目是通过调用 Termux 来实现的。因此，您需要手动配置环境。

## Termux 方法构建

Termux 是个虚拟终端应用，可以运行命令行工具，比如 `gradle` 。

Aide Lua 将终端应用写死为 `com.termux` ，因此您必须使用此包名的终端应用才可以直接从 Aide Lua 构建应用。

Termux 有三个官方下载渠道

* [F-Droid](https://f-droid.org/zh_Hans/packages/com.termux/)
* [GitHub Releases](https://github.com/termux/termux-app/releases)
* [Google Play 商店](https://play.google.com/store/apps/details?id=com.termux)（已弃用）

:::warning
由于 Android 10 的问题，Termux 及其插件不再在 Google Play 商店上更新。为 Android >= 7 发布的最后一个版本是 `v0.101` 。强烈建议不要再从 Play 商店安装 Termux 应用程序了。
:::

### 一、安装 Gradle 与 Java

* [使用Termux构建Android Studio项目](https://www.coolapk.com/feed/19454309?shareKey=ODEwZWY2ZDg0YjQ3NjNjZjRlNTc~&shareUid=1432137&shareFrom=com.coolapk.market_13.0.1)

### 二、允许第三方应用执行命令

1. 下载 [质感文件](https://www.coolapk.com/apk/me.zhanghai.android.files) 与 [App Manager](https://f-droid.org/packages/io.github.muntashirakon.AppManager/)
2. 打开 AOSP 的“文件”应用程序
    ``` sh:no-line-numbers
    # 对于部分隐藏了“文件”应用程序的定制系统，您可以在 Termux 执行以下命令启动“文件”应用程序
    am start com.android.documentsui/.LauncherActivity
    ```
3. 在“浏览其他应用中的文件”板块中选择“Termux”
4. 进入 `.termux` 目录，使用“意图拦截器”打开 `termux.properties` 文件
5. 将「MIME 类型」修改为 `text/plain` 
6. 选择「发送编辑过的意图」，然后选择质感文件的「文本编辑器」
7. 将 12 行左右的 `# allow-external-apps = true` 取消注释并保存文件
    ``` sh:no-line-numbers{4}
    ### Allow external applications to execute arbitrary commands within Termux.
    ### This potentially could be a security issue, so option is disabled by
    ### default. Uncomment to enable.
    allow-external-apps = true

    ### Default working directory that will be used when launching the app.
    # default-working-directory = /data/data/com.termux/files/home
    ```
::: tip
如果您的文件管理器可以直接打开 `termux.properties` 文件，您就可以忽略 (5) 和 (6) 步，直接使用您的文件管理器打开此文件。
:::
::: warning
请不要使用「MT管理器」 `v2.13.0` 之前的版本打开此文件。因为某些原因可能无法保存。
:::

### 三、授予 Aide Lua 权限

首先，其次，最后。

## AIDE Pro 构建

您可以到 [AIDE Pro 官网](https://www.aidepro.top/)下载此软件。

AIDE Pro 可以使用两种构建工具：

* 默认构建器
* Gradle

### 默认构建器

::: warning
使用默认构建器，您**必须打开「重定义Apk构建路径」**，否则您将在多个工程间使用同一个底包。
:::

::: warning
默认的构建器可能存在 bug，请谨慎使用。
:::

### Gradle

