* 打开了部分兼容选项，`module` ，`unpack` ，`bit32`
* 增加 `switch` `case` `default` `continue` 关键字
* 增加 `when` 单行判断关键字
* 增加 `defer` 延时执行关键字
* 增加 `lambda` 简单匿名函数关键字
* 增加 `a=[]` 形式创建数组需要形式
* 支持省略写法，可不写 `then` ，`do` ，`in`
* 支持使用关键字作为表键
---
* 增加 `string.gfind` 函数，用于递归返回匹配位置
---
* 增加 `table.clear` 函数，清空表
* 增加 `table.clone` 函数，克隆表
* 增加 `table.const` 函数，常量表禁止修改
* 增加 `table.find` 函数，查找指定值的键
* 增加 `table.gfind` 函数，迭代查找指定值的键
* 增加 `table.size` 函数，获取表所有元素的总数
---
* 增加 `io.readall` 函数，读取整个文件
* 增加 `io.ls` 函数，读取文件夹文件名列表
* 增加 `io.mkdir` 函数，创建文件夹
* 增加 `io.info` 函数，获取文件信息
* 增加 `io.isdir` 函数，判断是否为文件夹
---
* 修改 `os.date` 函数，支持64位时间
---
* 增加 `tointeger` 函数，强制将数值转为整数
* 修改 `tonumber` 函数，支持转换 Java 对象
