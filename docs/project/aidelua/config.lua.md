# .aidelua/config.lua
::: tip
`[...]` 为已省略或自定义的内容
:::

| 键(key) | 类型 | 推荐值 | 默认值 | 说明 |
| ---- | ---- | ---- | ---- | ---- |
| tool | table | {[...]} | {} | 二次打包工具信息 |
| tool.version | string | "1.1" | "1.1" | 二次打包工具的版本号 |
| appName | string | / | / | 应用名（仅供AideLua显示） |
| packageName | string | / | / | 应用包名（仅供AideLua显示和更好的调试） |
| debugActivity | string | / | "com.androlua.LuaActivity" | 调试的Activity名(不是标签)（仅供AideLua更好的调试） |
| include | table | {"project:app",[...]"project:androlua"} | / | 要编译lua的库，第一个为主程序 |
| main (已废除) | string | "app" | "app" | 主程序（仅1.0版本） |
| compileLua | boolean | true | true | 编译Lua |
| icon | table/string | {[...]} | / (智能判断) | 项目图标配置（仅供AideLua显示，相对路径为项目路径） |
| icon.day | string | "ic_launcher-aidelua.png" | / (智能判断) | 亮色模式图标 |
| icon.night | string | "ic_launcher_night-aidelua.png" | / (智能判断) | 深色模式图标 |
| projectMainPath | string | / | "app/src/main/assets_bin" | 主项目路径 |
