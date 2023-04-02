# 常见问题与解答

## 运行软件

### 运行软件显示 `为了您更好地调试软件，请导出 LuaActivity ，并打包项目并安装。`

这是因为 Aide Lua 是通过调用您的软件中 `LuaActivity` 直接运行的。所以需要您导出 `LuaActivity` 后打包项目并安装。

::: details 解决步骤

1. 打开 `app/src/main/AndroidManifest.xml`
2. 找到 `name` 为 `com.androlua.LuaActivity` 的Activity，添加 `android:exported="true"`
    ``` xml:no-line-numbers{5}
    <activity
        android:configChanges="keyboardHidden|orientation|screenSize"
        android:windowSoftInputMode="adjustResize|stateHidden"
        android:label="@string/app_name"
        android:exported="true"
        android:name="com.androlua.LuaActivity"/>
    ```
3. 在 AIDE Pro 中点击「运行」，然后点击「assembleRelease」，等待构建构建成功（显示 `BUILD SUCCESSFUL` 即构建成功）。

    ![](/images/guide/aide/assemble_release.jpg)

4. 在 Aide Lua 中点击「二次打包」，签名后安装新打包的 APK。（使用「二次打包并安装则不需要手动签名」

:::

## 构建 & 打包项目

### 什么情况下需要使用 AIDE 或 Gradle 重新构建

仅当修改了除 `assets_bin` 、`luaLibs`、`.aidelua` 以外的目录

> Aide Lua 的作用仅仅是提供 Lua 编辑器和将 Lua 文件整合到 `app.apk` 内，其他目录不归 Aide Lua 管，因此您需要重新构建一下。

### 打包应用总是无法找到 `app.apk`

请先使用 AIDE 刷新构建或使用 Gradle 构建。

### 构建项目时总是提示需要 Termux 运行权限

Aide Lua 本身不支持构建应用，所以您需要手动安装 Termux 并配置一系列开发环境后才能使用 Aide Lua 的「构建项目」

或者使用 [AIDE Pro](https://www.aidepro.top/) 或 [AndroidIDE](https://androidide.com/) 构建项目。

AIDE Pro 会自动下载 Gradle，更方便一些，但是 AndroidIDE 更高级一些。

## 插件

### 如何安装插件

__方法一__：从插件管理安装插件

__方法二__：从第三方文件管理安装插件

### 如何下载插件

您可以到 [Aide Lua 插件库](https://aidelua.github.io/plugins.html) 下载官方的插件
