# 结构说明

* 主页面管理器
* 主页面助手

## 文件结构

``` text
AideLuaPro: 项目根目录
|- .aidelua: Aide Lua 配置目录
|- docs: 文档说明文件夹
|- app: 主模块
|  |- plugins: 官方插件存放目录
|  |- tools: 用户辅助工具
|  |- typetest: 类型测试文件夹，AideLua进入这个文件夹即可测试文件显示、编辑是否正常工作
|
|- images: 图片资源文件夹
|
|- CHANGELOG.md: 变更日志
|- README.md: 说明文件（中文）
|- README_en.md: 说明文件（英文）
|- yarn_install_termux.sh: 执行 yarn install，重定向文件夹到 data 目录以适配安卓端

```

## lua 目录文件结构

* assets：lua 资源目录
  * sub：子页面目录
  * manager: 主页面管理器目录
    * file: 和文件相关的管理器目录
  * config: 存放一些基础的配置等目录，比如文件颜色
  * licences: 许可证存放目录
    * 文件命名: `产品名小写英文_license.txt` 或 `开源许可证名.txt`
* luaLibs：lua 库目录
