# 项目模板介绍

## 文件说明

Aide Lua 的模板支持字模板。因此您编写的时候可以套娃。

::: details 这是我们的模板结构

``` 文件树:no-line-numbers
templates   <-- 模板根文件夹
│  config.lua   <-- * 模板配置文件
│  keys.txt   <-- 用于格式化的字符串说明
│  pageConfigs.aly   <-- * 模板页面文件
│  keysFormatter.aly   <-- * key的格式化器字典
│
├─AndroLua   <-- AndroLua+ 子模板文件夹（名字可以随意起）
│  │  config.lua   <-- * 子模版配置文件
│  │
│  └─baseTemplate   <-- 子模版基础资源文件夹
│     │  androidx.zip   <-- 子模板 AndroidX 项目资源文件（自动识别）
│     │  baseTemplate.zip   <-- 子模版基础资源文件
│     │  normal.zip   <-- 子模版非 AndroidX 资源文件（自动识别）
│     │
│     └─androluaTemplate   <-- 页面 AndroLua+ 模块的模板
│         └─5.0.18(1.1)(armeabi-v7a,arm64-v8a)   <-- 模块版本号对应的文件夹
│               androidx.zip   <-- 模块的 AndroidX 资源文件（自动识别）
│               baseTemplate.zip   <-- 模块基础资源文件
│               normal.zip   <-- 模块的非 AndroidX 资源文件（自动识别）
│
├─baseTemplate   <-- 模版基础资源文件夹
│  │  baseTemplate.zip   <-- 模版基础资源文件
│  │  ...
│  │
│  └─appTemplate   <-- 页面通用模块的模板
│      └─aide(2.1)   <-- 模块版本号对应的文件夹
│              baseTemplate.zip   <-- 模块基础资源文件
│              ...
│
└─LuaJ   <-- LuaJ++ 子模板文件夹
       ...
```

:::

### config.lua

### pageConfigs.aly

### baseTemplate/

存放基本模板的地方

| 文件 | 说明 |
| ---- | ---- |
| baseTemplate.zip | 基本模板文件 |
| androidx.zip | 基本AndroidX模板文件|
| normal.zip | 基本非AndroidX模板文件 |

## 载入原理

## 从插件中加载模板

## 相关链接

* [工程介绍](/project/README.md)
* [新建项目](/functiom/newproject.md)
