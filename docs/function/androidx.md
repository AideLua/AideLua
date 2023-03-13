未完待续
# AndroidX

## 启用 AndroidX

您可以在新建项目时勾选 AndroidX 开关，也可以选择手动启用 AndroidX。以下内容为手动启用 AndroidX 的方法：

1. 在 `gradle.properties` 修改并设置 `android.useAndroidX` 和 `android.enableJetifier` 为 `true`

``` prop{4,6}
# AndroidX package structure to make it clearer which packages are bundled with the
# Android operating system, and which are packaged with your app"s APK
# https://developer.android.com/topic/libraries/support-library/androidx-rn
android.useAndroidX=true
# Automatically convert third-party libraries to use AndroidX
android.enableJetifier=true

android.enableResourceOptimizations=false
```
