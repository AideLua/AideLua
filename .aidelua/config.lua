--- 工具属性
tool = {
  version = "1.1",
}
appName = "Aide Lua Pro" -- 应用名称
packageName = "com.jesse205.aidelua2" -- 应用包名
--versionName = "1.0test" -- 重写APK的版本名 (暂不支持)
--versionCode = 1000 -- 重写APK的版本号 (暂不支持)

debugActivity = "com.jesse205.app.activity.RunActivity" --运行Lua的Activity
key = "JXNB" --运行Lua时传入的key，用于校验

include = { "project:app", "project:Jesse205Library", "project:androlua" } -- 导入，第一个为主模块
compileLua = false -- 编译Lua
useZipalign = false --优化APK

---图标
---相对路径位于工程根目录下
icon = {
  day = "app/src/main/ic_launcher-playstore.png", -- 图标
  night = "app/src/main/ic_launcher_night-playstore.png", -- 暗色模式图标
}


