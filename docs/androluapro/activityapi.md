# activity 部分 API 参考
* `setContentView(layout, env)`
    * 设置布局表 `layout` 为当前 `activity` 的主视图，`env` 是保存视图ID的表，默认是 `_G`
* `getGlobalData()`
    * 获取全局数据
* `setSharedData(key,value)`
    * 设置共享数据
* `getSharedData(key,def)`
    * 获取共享数据
* `getLuaPath()`
    * 返回当前脚本路径
* `getLuaPath(name)`
    * 返回脚本当前目录的给定文件名路径
* `getLuaPath(dir,name)`
    * 返回脚本当前目录的子目录给定文件名路径
* `getLuaExtPath(name)`
    * 返回Androlua在SD的工作目录给定文件名路径
* `getLuaExtPath(dir,name)`
    * 返回Androlua在SD的工作目录的子目录给定文件名路径
* `getLuaDir()`
    * 返回脚本当前目录
* `getLuaDir(name)`
    * 返回脚本当前目录的子目录
* `getLuaExtDir()`
    * 返回Androlua在SD的工作目录
* `getLuaExtDir(name)`
    * 返回Androlua在SD的工作目录的子目录
* `getWidth()`
    * 返回屏幕宽度
* `getHeight()`
    * 返回屏幕高度，不包括状态栏与导航栏
* `loadDex(path)`
    * 加载当前目录dex或jar，返回DexClassLoader
* `loadLib(path)`
    * 加载当前目录c模块，返回载入后模块的返回值(通常是包含模块函数的包)
* `registerReceiver(filter)`
    * 注册一个广播接收者，当再次调用该方法时将移除上次注册的过滤器
* `newActivity(req, path, enterAnim, exitAnim, arg)`
    * 打开一个新activity，运行路径为 `path` 的Lua文件，其他参数为可选，`arg` 为表，接受脚本为变长参数
* `result{...}`
    * 向来源activity返回数据，在源activity的 `onResult` 回调
* `newTask(func[, update], callback)`
    * 新建一个Task异步任务，在线程中执行 `func` 函数，其他两个参数可选，执行结束回调 `callback` ，在任务调用 `update` 函数时在UI线程回调该函数
    * 新建的Task在调用 `execute{}` 时通过表传入参数，在 `func` 以 `unpack` 形式接收，执行 `func` 可以返回多个值
* `newThread(func, arg)`
    * 新建一个线程，在线程中运行 `func` 函数，可以以表的形式传入 `arg` ，在 `func` 以 `unpack` 形式接收
    * 新建的线程调用 `start()` 方法运行，线程为含有loop线程，在当前activity结束后自动结束loop
* `newTimer(func, arg)`
    * 新建一个定时器，在线程中运行func函数，可以以表的形式传入arg，在 `func` 以 `unpack` 形式接收
    * 调用定时器的 `start(delay, period)` 开始定时器，`stop()` 停止定时器，`Enabled` 暂停恢复定时器，Period属性改变定时器间隔
