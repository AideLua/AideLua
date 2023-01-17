# 用户交互
Aide Lua 为用户提供更好的用户交互体验

## 页面
* [主页面 Main](main.md)
* 新建工程 NewProject
* 设置 Settings
* 关于 About

## 全局特性
### 标题栏阴影动态展示
当用户在页面上当前位置不是第一的话，应用将显示工具栏阴影，以凸现层级，告知用户当前未滑动到顶部。

当阴影发生变化时，软件将使用过渡动画切换阴影状态。
![](/images/ui/autoshadow/toolbar_hide.jpg)
<p class="pictureName">[图片] 列表已到顶部</p>

![](/images/ui/autoshadow/toolbar_show.jpg)
<p class="pictureName">[图片] 列表未到顶部</p>

### 合适的宽度
当用户在纯列表/网格页面，软件会自动调整列表到合适的宽度。
#### 列表
在列表中，调整整个列表的宽度。
![](/images/ui/autowidth/list_normal.jpg)
<p class="pictureName">[图片] 小宽度</p>

![](/images/ui/autowidth/list_wide.jpg)
<p class="pictureName">[图片] 大宽度</p>

::: tip
在大宽度模式下，滑动列表的两侧依旧可以滚动列表。<br>
如果您发现此操作无法被响应，那么这是一个 Bug，欢迎向我们[提供反馈](https://gitee.com/Jesse205/AideLua/issues)。
![](/images/ui/autowidth/list_wide_scroll.gif)
<p class="pictureName">[动图] 滑动外部可滚动列表</p>
:::

#### 网格
在网格中，则调整单个格子的宽度。
![](/images/ui/autowidth/grid_normal.jpg)
<p class="pictureName">[图片] 小宽度</p>

![](/images/ui/autowidth/grid_wide.jpg)
<p class="pictureName">[图片] 大宽度</p>
