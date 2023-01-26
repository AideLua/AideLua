# 主页面 Main
## 侧滑栏设计
在像手机这样如此小的屏幕，同时展示编辑器与文件浏览器是很不现实的。

因此我们在屏幕宽度小于 `800dp` 时，将文件浏览器独立出来，并放到侧滑栏内。
![](/images/ui/main/filebrowser_narrow.jpg)
<p class="pictureName">[图片] 屏幕宽度小于 800dp 时</p>

![](/images/ui/main/filebrowser_wide.jpg)
<p class="pictureName">[图片] 屏幕宽度大于或等于 800dp 时</p>

## 文件标签栏
### 查看文件路径
为了查看文件标签栏内文件的路径，我们将 Tooltip 设置为文件路径。
``` lua{9}
-- app/src/main/assets_bin/FilesTabManager.lua: 154
local function initFileTabView(tab, fileConfig)
  local view = tab.view
  fileConfig.view = view
  view.setPadding(math.dp2int(8), math.dp2int(4), math.dp2int(8), math.dp2int(4))
  view.setGravity(Gravity.LEFT | Gravity.CENTER)
  view.tag = fileConfig

  TooltipCompat.setTooltipText(view, fileConfig.shortFilePath)
  local imageView = view.getChildAt(0)
  local textView = view.getChildAt(1)
  fileConfig.imageView = imageView
  fileConfig.textView = textView
  imageView.setPadding(math.dp2int(2), math.dp2int(2), math.dp2int(2), 0)
  textView.setAllCaps(false) -- 关闭全部大写
  .setTextSize(12)
  applyTabMenu(view,fileConfig)
end
```
::: tip
在低于 Android 8.0 时，Tooltip可能会设置不成功，因为在接下的代码中重新设置了 `onLongClick`
:::

在桌面端，当指针悬停在标签上时显示 Tooltip。
<p class="pictureName">[图片] 鼠标指针悬停在标签上</p>

在移动端，当用户长按文件标签时显示 Tooltip
![](/images/ui/main/tab_hover_finger.jpg)
<p class="pictureName">[图片] 标签被长按</p>

当然，也可以通过上拉来快速显示 Tooltip。在用户上拉后，文件标签将播放向上旋转动画，使用户意识到触发了上滑操作。
![](/images/ui/main/tab_slideup.gif)
<p class="pictureName">[动图] 上滑标签</p>


### 下拉菜单
为了简化关闭流程（ `菜单 > 文件 > 关闭文件` ），我们在文件标签上加入了下拉菜单。

用户可以通过下拉文件标签来调出下拉菜单，同时文件标签将播放向下旋转动画，使用户意识到触发了下拉操作
<p class="pictureName">[动图] 下拉标签</p>

为考虑部分用户的习惯，当用户触发下拉菜单后不会立即进入滑动选择，而是当持续时间超过 600ms 或下拉中途返回后进入滑动选择模式
<p class="pictureName">[动图] 下拉标签后停顿</p>

<p class="pictureName">[动图] 下拉标签后返回</p>

::: tip
暂时未考虑鼠标右键弹出菜单
:::

## 符号栏
符号栏为方便触屏用户快速输入符号而设计。

### 自动化
Aide Lua 的符号栏会自动根据用户是否选择了文字而适当改变点击后插入的内容

Aide Lua 的内容变化不会复杂，只有两种状态：已选中和未选中

当用户已选中文字时，插入的内容会自动包裹选中的文字。

假如当前选择了 `hello`，符号 `(` 和 `)` 插入的内容会自动变为 `(hello)` 。

![](/images/ui/main/psbar_normal.jpg)
<p class="pictureName">[图片] 未选中时插入的内容</p>

![](/images/ui/main/psbar_selected.jpg)
<p class="pictureName">[图片] 已选中时插入的内容</p>

::: tip
该特性目前只支持 Lua Editor，也就是只支持 `lua` 和 `aly` 文件
:::
### 手势
符号栏仅有一个向右滑动打开侧滑栏的手势
![](/images/ui/main/psbar_scroll_right.jpg)
<p class="pictureName">[图片] 在任意位置向右滑动</p>
