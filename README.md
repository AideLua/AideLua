# Aide Lua
![icon](https://gitee.com/Jesse205/AideLua/raw/master/ic_launcher-aidelua.png)

## 简介
Aide Lua 是一款依赖 Aide 的 Lua 编辑器

## 下载
[Aide 高级设置版](https://www.lanzoui.com/b00zdhbeb)

1.[Gitee下载](https://gitee.com/Jesse205/AideLua/releases)

2.[天翼云盘](https://cloud.189.cn/t/ZZ7RzijyqiUv)

3.[腾讯微云](https://share.weiyun.com/oLiNtxMR)

4.[百度网盘](https://pan.baidu.com/s/1j1RwisPR8iq1fPS3O_fl7Q)，密码jxnb

## 使用教程
[视频教程](https://b23.tv/nvVHoa)

####一、配置AIDE
  1.

  2.

  3.

  4.

####二、初次打包
  1. 在AideLua点击新建项目，在填写与选择完成后点击“新建”

  2. 用AIDE打开项目，点击“构建刷新”

  3. 点击AideLua的“打包运行”按钮（或“二次打包”，手动签名）并安装，测试是否可以正常打包

  4. 点击AideLua的“运行”按钮，测试是否正常通过已安装的应用调试

## 注意事项
  1. AIDE最好使用AIDE高级设置版本

  2. AIDE最好打开重定义Apk路径

  3. AIDE最好关闭adrt调试文件

  4. 不是必须用AIDE编译，只不过用AIDE编译会更好一些

## 高级玩法
.aidelua/config.lua用法
| 键(key) | 类型 | 推荐值（[...]为已省略或自定义的内容） | 默认值 | 说明 |
| ---- | ---- | ---- | ---- | ---- |
| tool | table | {[...]} | {} | 二次打包工具信息 |
| tool.version | string | "1.1" | "1.0" | 二次打包工具的版本号 |
| appName | string | / | / | 应用名（仅供AideLua显示） |
| packageName | string | / | / | 应用包名（仅供AideLua显示和更好的调试） |
| include | table | {"project:app",[...]"project:androlua"} | / | 要编译lua的库，第一个为主程序 |
| main (已废除) | string | "app" | "app" | 主程序（仅1.0版本） |
| compileLua | boolean | true | true | 编译Lua |
| icon | table/string | {[...]} | / (智能判断) | 项目图标配置（仅供AideLua显示，相对路径为项目路径） |
| icon.day | string | "ic_launcher-aidelua.png" | / (智能判断) | 亮色模式图标 |
| icon.night | string | "ic_launcher_night-aidelua.png" | / (智能判断) | 亮色模式图标 |

