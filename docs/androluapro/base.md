# 软件基本操作
## 工程结构
* `init.lua` 工程配置文件
* `icon.png` 工程图标文件
* `main.lua` 工程主入口文件
* `layout.aly` 工程默认创建的布局文件
### init.lua 配置
| 键 | 类型 | 说明 |
| ---- | ---- | ---- |
| appname | `string` | 应用名 |
| appver | `string` | 版本名 |
| appcode | `string` | 版本号 |
| packagename | `string` | 应用包名 |
| appsdk | `string` | 等你来补充 |
| path_pattern | `string` | 等你来补充 |
| theme | `string` | 主 Activity 默认主题 |
| app_key | `string` | 等你来补充 |
| app_channel | `string` | 等你来补充 |
| developer | `string` | 等你来补充 |
| description | `string` | 应用描述 |
| debugmode | `boolean` | 调试模式，影响 `print` 与报错的提示显示 |
| user_permission | `table (list)` | 权限列表，不加 `android.permission` |

[命名包 (Naming a Package)](https://docs.oracle.com/javase/tutorial/java/package/namingpkgs.html)

## 菜单功能
* __三角形__ 运行：执行当前工程
* __左箭头__ 撤销：撤销输入的内容
* __右箭头__ 重做：恢复撤销的内容
* __打开__：打开文件，在文件列表长按可删除文件
* __最近__：显示最近打开过的文件

## 文件
* __保存__：保存当前文件
* __新建__：新建lua代码文件或者aly布局文件，代码文件与布局文件文件名不可以相同
* __编译__：把当前文件编译为luac文件，通常用不到

## 工程
* __代开__：在工程列表打开工程
* __打包__：将当前工程编译为apk，默认使用debug签名
* __新建__：新建一个工程
* __导出__：将当前工程备份为alp文件
* __属性__：编辑当前工程的属性，如 名称 权限等

## 代码
* __格式化__：重新缩进当前文件使其更加便于阅读
* __导入分析__：分析当前文件及引用文件需要导入的java类
* __查错__：检查当前文件是否有语法错误

## 转到
* __搜索__：搜索指定内容位置
* __转到__：按行号跳转
* __导航__：按函数跳转

## 插件
* 使用安装的插件

## 其他
* __布局助手__：在编辑器打开 aly 文件时用于设计布局，目前功能尚不完善
* __日志__：查看程序运行时的日志
* __java浏览器__：用于查看 Java 类的方法
* __手册__：离线版 Lua 官方手册
* __联系作者__：加入官方 QQ 群与作者交流
* __捐赠__：使用支付宝捐赠作者，使软件更好的发展下去
