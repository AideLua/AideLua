---Jesse205 框架
---@class Jesse205
local jesse205 = {}
_G.jesse205 = jesse205
jesse205._VERSION = "13.0.0 (alpha) (Pro)"     -- 库版本名
jesse205._VERSION_CODE = 130001                -- 库版本号
jesse205._ENV = _ENV                           -- Jesse205局部变量
--jesse205.themeType = "Jesse205"              -- 主题类型
jesse205.LIBRARY_PACKAGE_NAME = "com.jesse205" -- 库包名

local LIBRARY_PACKAGE_NAME = jesse205.LIBRARY_PACKAGE_NAME

require "import" -- 导入import
import "loadlayout2"
import "lazyimport"
local import_ = _G["import"] -- 防止编辑器报错
local appName, loadingDia
local phoneLanguage

---Java类提示
-- require "JavaClassHint"

-- 惰性导入？

local fastImport = {
    Bitmap = "android.graphics.Bitmap",
    LayoutTransition = "android.animation.LayoutTransition",
    StatService = "com.baidu.mobstat.StatService",
    AppPath = LIBRARY_PACKAGE_NAME .. ".app.AppPath",
    PermissionUtil = LIBRARY_PACKAGE_NAME .. ".app.PermissionUtil",
    MyStyleUtil = LIBRARY_PACKAGE_NAME .. ".util.MyStyleUtil",
    MyToast = LIBRARY_PACKAGE_NAME .. ".util.MyToast",
    getNetErrorStr = LIBRARY_PACKAGE_NAME .. ".util.getNetErrorStr",
    MyAnimationUtil = LIBRARY_PACKAGE_NAME .. ".util.MyAnimationUtil",
    ScreenUtil = LIBRARY_PACKAGE_NAME .. ".util.ScreenUtil",
    FileUtil = LIBRARY_PACKAGE_NAME .. ".util.FileUtil",
    ClearContentHelper = LIBRARY_PACKAGE_NAME .. ".helper.ClearContentHelper",
    -- 导入各种风格的控件
    StyleWidget = LIBRARY_PACKAGE_NAME .. ".widget.StyleWidget",
    MaterialButton_TextButton = LIBRARY_PACKAGE_NAME .. ".widget.StyleWidget",
    MaterialButton_OutlinedButton = LIBRARY_PACKAGE_NAME .. ".widget.StyleWidget",
    MaterialButton_TextButton_Normal = LIBRARY_PACKAGE_NAME .. ".widget.StyleWidget",
    MaterialButton_TextButton_Icon = LIBRARY_PACKAGE_NAME .. ".widget.StyleWidget",
    -- 导入各种布局表
    MyTextInputLayout = LIBRARY_PACKAGE_NAME .. ".layout.MyTextInputLayout",
    AnimationHelper = LIBRARY_PACKAGE_NAME .. ".helper.AnimationHelper",
    DialogHelper = LIBRARY_PACKAGE_NAME .. ".helper.DialogHelper",
    ThemeManager = LIBRARY_PACKAGE_NAME .. ".manager.ThemeManager"
}

for index, content in pairs(fastImport) do
    lazyimport(content, nil, index)
end

-- 根本就不是class的key，因此直接取全局变量即可
---@enum
local normalkeys = {
    this = true,
    activity = true,
    application = true,
    resources = true,
    useCustomAppToolbar = true,
    decorView = true,
    darkNavigationBar = true,
    darkStatusBar = true,
    notLoadTheme = true,
    initApp = true,
    R = true,
    jesse205 = true,
    _G = true,
    mainLay = true,
    LastActionBarElevation = true
}

jesse205.normalkeys = normalkeys

local oldMetatable = getmetatable(_G)
local newMetatable = {
    __index = function(self, key)
        if normalkeys[key] then
            return rawget(_G, key)
        else
            return oldMetatable.__index(self, key)
        end
    end
}
setmetatable(_G, newMetatable)

application = activity.getApplication()

-- 当前context
local context = activity or service
jesse205.context = context

-- 软件名
appName = application.get("appName")
if appName == nil then
    appName = context.getApplicationInfo().loadLabel(context.getPackageManager())
    application.set("appName", appName)
end
local packageName = activity.getPackageName()
jesse205.appName = appName
jesse205.packageName = packageName

resources = context.getResources() -- 当前resources
R = luajava.bindClass(packageName .. ".R")
BuildConfig = luajava.bindClass(packageName .. ".BuildConfig")

if activity then
    window = activity.getWindow()
else
    -- 没有activity不加载主题
    notLoadTheme = true
end

-- JavaAPI转LuaAPI
local activity2luaApi = { "newActivity", "getSupportActionBar", "getSharedData", "setSharedData", "getString",
    "getPackageName" }
for _, content in ipairs(activity2luaApi) do
    _G[content] = function(...)
        return context[content](...) -- 直接赋值会出错
    end
end
activity2luaApi = nil

lazyimport "android.os.Environment"
lazyimport "android.content.res.Configuration"

require "com.jesse205.lua.math"   -- 导入更强大的math
require "com.jesse205.lua.string" -- 导入更强大的string

-- 导入常用的包
import "androidx.appcompat.widget.*"
import "androidx.appcompat.app.*"

lazyimport "android.os.Build"
lazyimport "android.view.View" -- 加载主题要用
import "android.app.*"
import "android.os.*"
import "android.view.*"
import "android.widget.*"
lazyimport "android.view.inputmethod.InputMethodManager"

lazyimport "androidx.appcompat.app.AlertDialog"

lazyimport "android.widget.TextView"
lazyimport "android.widget.LinearLayout"
lazyimport "android.widget.FrameLayout"
lazyimport "android.widget.ScrollView"
lazyimport "androidx.appcompat.widget.AppCompatTextView"
lazyimport "androidx.appcompat.widget.AppCompatImageView"
lazyimport "androidx.appcompat.widget.LinearLayoutCompat"
lazyimport "androidx.coordinatorlayout.widget.CoordinatorLayout"

-- 导入常用类
lazyimport "android.graphics.Bitmap"
lazyimport "android.graphics.Color"
lazyimport "android.graphics.Typeface"
lazyimport "android.graphics.drawable.GradientDrawable"

lazyimport "androidx.core.app.ActivityCompat"
lazyimport "androidx.core.content.ContextCompat"
lazyimport "androidx.core.view.MenuItemCompat"

lazyimport "androidx.coordinatorlayout.widget.CoordinatorLayout"
lazyimport "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
lazyimport "androidx.cardview.widget.CardView"

lazyimport "com.jesse205.widget.MyRecyclerView"
lazyimport "androidx.recyclerview.widget.RecyclerView"
lazyimport "androidx.recyclerview.widget.StaggeredGridLayoutManager"
lazyimport "androidx.recyclerview.widget.LinearLayoutManager"

lazyimport "com.lua.custrecycleradapter.AdapterCreator" -- 导入LuaCustRecyclerAdapter及相关类
lazyimport "com.lua.custrecycleradapter.LuaCustRecyclerAdapter"
lazyimport "com.lua.custrecycleradapter.LuaCustRecyclerHolder"

lazyimport "android.net.Uri"
lazyimport "android.content.Intent"
lazyimport "android.content.Context"
lazyimport "android.content.res.ColorStateList"
lazyimport "android.content.pm.PackageManager"

-- 导入常用的Material类
lazyimport "com.google.android.material.card.MaterialCardView"             -- 卡片
lazyimport "com.google.android.material.button.MaterialButton"             -- 按钮
lazyimport "com.google.android.material.dialog.MaterialAlertDialogBuilder" -- 对话框
lazyimport "com.google.android.material.textview.MaterialTextView"         -- 文字

-- 导入IO
lazyimport "java.io.File"

lazyimport "com.bumptech.glide.Glide"                                       -- 导入Glide

inputMethodService = context.getSystemService(Context.INPUT_METHOD_SERVICE) -- 获取输入法服务


--- 自动获取当地语言的对象
---@param zh string 中文字符串
---@param en string 英文字符串
function getLocalLangObj(zh, en)
    if not (phoneLanguage) then
        import "java.util.Locale"
        phoneLanguage = Locale.getDefault().getLanguage()
    end
    if phoneLanguage == "zh" then
        return zh or en
    else
        return en or zh
    end
end

---自动识别资源id和字符串，并自动获取字符串
---@param text string|number
function autoId2str(text)
    local _type = type(text)
    if _type == "number" then
        return getString(text)
    else
        return text
    end
end

-- 复制文字
function copyText(text)
    context.getSystemService(Context.CLIPBOARD_SERVICE).setText(text)
end

-- 通过id格式化字符串
function formatResStr(id, values)
    return String.format(getString(id), values)
end

--- 在浏览器打开链接
---@param url string 网页链接
function openInBrowser(url)
    local intent = Intent("android.intent.action.VIEW", Uri.parse(url))
    if intent.resolveActivity(context.getPackageManager()) then
        context.startActivity(intent)
    end
end

openUrl = openInBrowser -- 通常情况下，应用不自带内置浏览器

--- 相对路径转绝对路径
---@param path string 要转换的相对路径
---@param localPath string 相对的目录
function rel2AbsPath(path, localPath)
    if path:sub(1, 1) == "/" then
        return path
    else
        return localPath .. "/" .. path
    end
end

--- 将value转换为boolean类型
---@param value any 任何东西
function toboolean(value)
    return not not value
end

--- 进入Lua子页面
---@param name string 子活动名称
function newSubActivity(name, ...)
    assert(name:sub(1, 1) ~= "/", "name must not start with \"/\"")
    local nowDirFile = File(context.getLuaDir())
    local parentDirFile = nowDirFile.getParentFile()
    local basePath
    if nowDirFile.getName() == "sub" then
        basePath = "."
    elseif parentDirFile.getName() == "sub" then
        basePath = parentDirFile.getPath()
    else
        basePath = "sub"
    end
    if name:find("/") then
        newActivity(basePath .. "/" .. name, ...)
    else
        newActivity(basePath .. "/" .. name .. "/main.lua", ...)
    end
    luajava.clear(nowDirFile)
    luajava.clear(parentDirFile)
end

-- 好用的加载中对话框

--- 智能显示加载对话框
---@param message string 信息
---@param title string 标题
---@param cancelable boolean 是否可以取消
function showLoadingDia(message, title, cancelable)
    if not (loadingDia) then
        import "android.app.ProgressDialog"
        loadingDia = ProgressDialog(context)
        loadingDia.setProgressStyle(ProgressDialog.STYLE_SPINNER)                  -- 进度条类型
        loadingDia.setTitle(title or context.getString(R.string.jesse205_loading)) -- 标题
        loadingDia.setCancelable(cancelable or false)                              -- 是否可以取消
        loadingDia.setCanceledOnTouchOutside(cancelable or false)                  -- 是否可以点击外面取消
        loadingDia.setOnCancelListener({
            onCancel = function()
                loadingDia = nil -- 如果取消了，就把 loadingDia 赋值为空，视为没有正在展示的加载中对话框
            end
        })
        loadingDia.show()
    end
    loadingDia.setMessage(message or context.getString(R.string.jesse205_loading))
end

--- 关闭对话框
function closeLoadingDia()
    if loadingDia then
        loadingDia.dismiss()
        luajava.clear(loadingDia)
        loadingDia = nil
    end
end

function getNowLoadingDia()
    return loadingDia
end

--- 显示简单对话框，只有确定的那种
---@param title string 标题
---@param message string 信息
function showSimpleDialog(title, message)
    return MaterialAlertDialogBuilder(context)
        .setTitle(title)
        .setMessage(message)
        .setPositiveButton(android.R.string.ok, nil)
        .show()
end

function showErrorDialog(title, message)
    local dialog = MaterialAlertDialogBuilder(context)
        .setTitle(title)
        .setMessage(message)
        .setPositiveButton(android.R.string.ok, nil)
        .setNegativeButton(R.string.jesse205_copy, nil)
        .show()
    DialogHelper.enableTextIsSelectable(dialog)
    dialog.getButton(AlertDialog.BUTTON_NEGATIVE).onClick = function()
        MyToast.copyText(message)
    end
end

--- 自动初始化一个LayoutTransition
function newLayoutTransition()
    return LayoutTransition()
        .enableTransitionType(LayoutTransition.CHANGING)
        .setDuration(200)
end

-- 以下为复写事件
function onError(title, message)
    pcall(function()
        -- 保存到文件。有报错说明软件有问题，必须解决掉。
        local path = "/sdcard/Androlua/crash/" .. packageName .. ".txt"
        local content = tostring(title) .. os.date(" %Y-%m-%d %H:%M:%S") .. "\n" .. tostring(message) .. "\n\n"
        io.open(path, "a"):write(content):close()
    end)
    -- 报错重写
    pcall(function()
        showErrorDialog(tostring(title), tostring(message)) -- 显示成对话框，解决安卓12的toast限制问题
    end)
end

if initApp then
    -- 初始化APP
    require("com.jesse205.app.initApp")
end

-- 加载主题
-- 在get某东西（ActionBar等）前必须把主题搞定
if not notLoadTheme then
    import "res"
    theme = {
        color = {
            Ripple = {},
            Light = {},
            Dark = {},
            ActionBar = {}
        },
        number = {
            id = {},
            Dimension = {}
        },
        boolean = {}
    }
    --local colors, dimens
    local color = theme.color
    local ripple = color.Ripple
    local light = color.Light
    local dark = color.Dark
    local number = theme.number
    local dimension = number.Dimension

    setmetatable(color, {
        -- 普通颜色
        __index = function(self, key)
            print("警告:调用了theme.color", key)
            local value = resources.getColor(R.color["jesse205_" .. string.lower(key)])
            rawset(self, key, value)
            return value
        end
    })
    setmetatable(ripple, {
        -- 波纹颜色
        __index = function(self, key)
            print("警告:调用了theme.ripple", key)
            local value = resources.getColor(R.color["jesse205_" .. string.lower(key) .. "_ripple"])
            rawset(self, key, value)
            return value
        end
    })
    setmetatable(light, {
        -- 偏亮颜色
        __index = function(self, key)
            print("警告:调用了theme.color", key)
            local value = resources.getColor(R.color["jesse205_" .. string.lower(key) .. "_light"])
            rawset(self, key, value)
            return value
        end
    })
    setmetatable(dark, {
        -- 偏暗颜色
        __index = function(self, key)
            print("警告:调用了theme.color", key)
            local value = resources.getColor(R.color["jesse205_" .. string.lower(key) .. "_dark"])
            rawset(self, key, value)
            return value
        end
    })
    setmetatable(number, {
        -- 数字
        __index = function(self, key)
            print("警告:调用了theme.number", key)
            local value = resources.getInteger(R.integer["jesse205_" .. string.lower(key)])
            rawset(self, key, value)
            return value
        end
    })
    setmetatable(dimension, {
        -- 数字
        __index = function(self, key)
            print("警告:调用了theme.number", key)
            local value = resources.getDimension(R.dimen["jesse205_" .. string.lower(key)])
            rawset(self, key, value)
            return value
        end
    })
    import "android.app.ActivityManager"
    import "com.jesse205.app.ThemeUtil"
    ThemeUtil.refreshUI()
end

-- 导入共享代码
require("AppSharedCode")

return jesse205
