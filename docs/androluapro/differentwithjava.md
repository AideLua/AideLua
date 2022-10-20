# 与标准 java 的不同
## Java 有，Androlua 没有
* 没有 `new` 关键字，使用函数调用形式构建实例
* 没有类型声明，使用 `local` 声明局部变量
* 不使用 `{}` ，使用 `do end` 结构
* 不使用 `try` ，使用 `pcall` 和 `xpcall`


## Androlua 有，Java 没有
* 基于 getter / setter 的方法简写
* 创建有初始内容的 list 和 map
* 使用键访问 list 和 map 内容
* 不必实现接口的所有方法，且可以使用简化形式
* 灵活的动态布局
