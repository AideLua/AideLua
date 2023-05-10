# AndroLua+ 资源获取工具

[![license](https://img.shields.io/github/license/AideLua/AndroLuaResGetter?style=flat-square)](https://gitee.com/AideLua/AndroLuaResGetter/blob/master/LICENSE)
[![Gitee 发行版](https://img.shields.io/github/v/tag/AideLua/AndroLuaResGetter?color=C71D23&label=发行版&logo=gitee&style=flat-square)](https://gitee.com/AideLua/AndroLuaResGetter/releases/latest)
[![作者: Jesse205](https://img.shields.io/badge/作者-Jesse205-1A73E8?style=flat-square)](https://gitee.com/Jesse205)

[![Gitee 仓库](https://img.shields.io/badge/Gitee-仓库-C71D23?logo=gitee&style=flat-square)](https://gitee.com/AideLua/AndroLuaResGetter)
[![Github 仓库](https://img.shields.io/badge/Github-仓库-0969DA?logo=github&style=flat-square)](https://github.com/AideLua/AndroLuaResGetter)

## 介绍

在 AndroLua+ 中很方便地获取资源数据

## 软件架构

* __res.lua__: res 模块

## 安装教程

1. 复制 `res.lua` 到 `<项目>/app/src/main/luaLibs` 内
2. 在 `main.lua` 内导入 `import` 模块: `require "import"`
3. 导入 `res` 模块: `import "res"`

## 名词说明

* __ResGetterHolder__: 也就是 `res`
* __ResGetterTypeHolder__: 也就是 `res.xxx` ，持有具体的资源类型，比如 `color`
* __ResGetterAttrHolder__: 也就是 `res.xxx.attr` ，只是声明接下来获取的资源内容要从主题中获取

## 使用说明

访问规则：`res.<类型>[.attr].<名称>`

使用 `res.xxx` 使用全局变量 `R` 内容，一般为 `com.androlua.R`

> 如果您使用 Gradle 构建应用，可以先添加 `R=luajava.bindClass(activity.getPackageName()..".R")` 使用主模块中的 `<包名>.R` 。

使用 `android.res.xxx` 则会指定为全局变量 `android.R` 的 R 类，一般为 `android.R`

您也可以使用 `res(id).xxx` 指定使用的主题 ID，使用 `res(rClass).xxx` 指定使用的 R 类（v1.0 (alpha4)+）

注意：

1. 部分资源在获取后会缓存，您可能需要执行 `res:clearCache()` 来清除这个 ResGetterHolder 下的所有缓存
2. 图片资源等默认不会缓存。您可以 `res.setSupportCacheGetterMap(getterText,state)` 来启用这些资源的缓存
3. res 模块暂时只支持主 ResGetterHolder 通过 `res:clearCache()` 调用，其他的请使用 `res.clearCache(otherRes)` 调用各种方法

示例（以 AndroLuaX 为例）：

``` lua
-- 设置支持图片的缓存，请谨慎使用，因为这种方式可能导致状态，还会造成内存泄露
-- 详情：https://blog.csdn.net/wytwyt123456/article/details/106355429
res.setSupportCacheGetterMap("getDrawable",true)

-- 获取 colorPrimary 颜色值
-- R.attr.colorPrimary
colorPrimary = res.color.attr.colorPrimary

-- 获取 android 的 colorPrimary 颜色值
-- android.R.attr.colorPrimary
colorPrimaryAndroid = android.res.color.attr.colorPrimary

-- 获取当前主题的 actionBarTheme 主题ID
-- R.attr.actionBarTheme
actionBarThemeId = res.id.attr.actionBarTheme

-- 获取当前主题 actionBarTheme 中的 colorControlNormal 颜色值
-- R.attr.actionBarTheme
-- R.attr.colorControlNormal
actionBarColorControlNormal = res(res.id.attr.actionBarTheme).color.attr.colorControlNormal

-- 获取 seed 颜色
-- R.color.seed
seedColor = res.color.seed

-- 获取 android 的 holo_blue_light 颜色
-- android.R.color.holo_blue_light
holoBlueLightColor = android.res.color.holo_blue_light

-- 使用 EMUI 的 R 类
androidhwext={R=luajava.bindClass("androidhwext.R")}

androidhwext.res=res(androidhwext.R)
-- 或者
androidhwext.res=res.getOrNewResWithRClass(androidhwext.R)
```
