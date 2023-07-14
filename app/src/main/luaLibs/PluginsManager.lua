import "com.jesse205.aidelua2.manager.LuaPluginsManager"

---插件管理器
---@class PluginsManager
---@field public _VERSION string 版本名
---@field public _VERSION_CODE string 版本号
---@field public PLUGINS_PATH_USER string 用户插件路径
---@field public PLUGINS_PATH_SYSTEM string 内置插件路径
---@field public PLUGINS_PATHS string[] 插件所有路径列表
local PluginsManager = {}
PluginsManager._VERSION = "4.0.0 (dev)"
PluginsManager._VERSION_CODE = 40001

local PLUGINS_PATH_USER = AppPath.AppMediaDir .. "/plugins"
local PLUGINS_PATH_SYSTEM = AppPath.AppDataDir .. "/plugins"
local PLUGINS_PATHS = {
    PLUGINS_PATH_USER,
    PLUGINS_PATH_SYSTEM,
}
local PLUGINS_DATA_PATH = AppPath.AppMediaDir .. "/data/plugins"
PluginsManager.PLUGINS_PATH_USER = PLUGINS_PATH_USER
PluginsManager.PLUGINS_PATH_SYSTEM = PLUGINS_PATH_SYSTEM
PluginsManager.PLUGINS_PATHS = PLUGINS_PATHS
PluginsManager.PLUGINS_DATA_PATH = PLUGINS_DATA_PATH

-- ---已加载插件列表 pluginPackageName:pluginConfig
-- ---@type PluginConfig[]
-- local loadedPluginsMap = {}
-- PluginsManager.loadedPluginsMap = loadedPluginsMap

---已加载的插件配置字典
---@type table<string,PluginConfig>
local loadedPluginConfigsMap = {}
PluginsManager.loadedPluginConfigsMap = loadedPluginConfigsMap


local appPackageName = activity.getPackageName()
local appPackageInfo = activity.PackageManager.getPackageInfo(appPackageName, 0)
local appVersionCode = appPackageInfo.versionCode
local appTag = appTag
local activityName

---要克隆的变量
---@type string[]
local virtualEnvCloneList = { "android", "short", "tostring", "string",
    "activity", "func", "xpcall", "collectgarbage", "load",
    "import", "tointeger", "_VERSION", "loadstring", "loadmenu",
    "byte", "double", --[["_G",]] "boolean", "rawget", "this", "module",
    "tonumber", "ipairs", "getmetatable", "require",
    "setmetatable", "dump", "rawlen", "task", "float", "pcall",
    "setmetamethod", "luajava", "type", "select", "d", "getids",
    "loadfile", "math", "next", "loadbitmap", "loadlayout",
    "thread", "unpack", "io", "set", "long", "assert", "char", "enum",
    "printstack", "os", "timer", "debug", "rawset", "compile",
    "coroutine", "rawequal", "print", "bit32", "findtable",
    "call", "dofile", "pairs", "each", "package", "utf8", "table",
    "int", "error" }

---公共全局变量
---@type _ENV
local baseVirtualEnv = {
    _APP_G = _G, --页面全局变量
    PluginsManager = PluginsManager,
}

--每一个插件虚拟环境变量访问都能回滚到baseVirtualEnv，但是不能回归到_G
local virtualEnvMetatable = { __index = baseVirtualEnv }

for index = 1, #virtualEnvCloneList do
    local value = virtualEnvCloneList[index]
    baseVirtualEnv[value] = _ENV[value]
end

LuaPluginsManager.setAppTag(appTag)

---清空已启用插件的路径列表
function PluginsManager.clearEnabledPluginPaths()
    LuaPluginsManager.setEnabledPluginPaths(nil)
end

---获取已启用插件路径列表，第一次调用时检查所有插件
---@return String[] pathsJ 已启用插件路径列表
function PluginsManager.getEnabledPluginPaths()
    ---@type String[]
    local pathsJ = LuaPluginsManager.getEnabledPluginPaths()
    if pathsJ then
        --如果已存在列表，就不需要读取了
        return pathsJ
    end
    --没有已加载插件路径，开始遍历插件
    local paths = {}
    for pluginsDirPathKey = 1, #PLUGINS_PATHS do
        local pluginsDirPath = PLUGINS_PATHS[pluginsDirPathKey]
        --TODO: 检查插件状态并添加至列表
        table.insert(paths, pluginsDirPath)
    end
    pathsJ = String(paths)
    LuaPluginsManager.setEnabledPluginPaths(pathsJ)
    return pathsJ
end

---设置活动标识
---@param name string 设置活动名称
function PluginsManager.setActivityName(name)
    activityName = name
    baseVirtualEnv.activityName = name --虚拟环境中的值需要单独设置
end

---设置已启用插件的版本
---@param pluginPackageName string 插件包名
---@param versionCode number|false 软件版本号，true:默认启用，受targetcode控制 或false:停用插件
function PluginsManager.setEnabledVersion(pluginPackageName, versionCode)
    setSharedData("plugin_" .. pluginPackageName .. "_enabled", versionCode)
    return PluginsManager
end

---获取已启用插件的宿主版本
---@param pluginPackageName string 插件包名
---@return number|false enabledVersion 软件版本号，true:默认启用，受targetcode控制 或false:停用插件
function PluginsManager.getEnabledVersion(pluginPackageName)
    local enabledVersion = getSharedData("plugin_" .. pluginPackageName .. "_enabled")
    if enabledVersion == nil then
        enabledVersion = true
    end
    return enabledVersion
end

---设置插件启用状态
---储存值：number|boolean 软件版本号，true:默认启用，受targetcode控制 或false:停用插件
---@param pluginConfig table 插件配置
---@param enabled boolean 状态，自动判断
function PluginsManager.setEnabled(pluginConfig, enabled)
    local pluginPackageName = pluginConfig.packagename
    PluginsManager.setEnabledVersion(pluginPackageName, appVersionCode)
    return PluginsManager
end

function PluginsManager.getEnabled(pluginConfig)
    local pluginPackageName = pluginConfig.packagename
    local enabledVersion = PluginsManager.getEnabledVersion(pluginPackageName)
    local supports = pluginConfig.supported2
    if enabledVersion and appTag and supports then --只有当enabledVersion为true时才需要判断兼容版本
        local versionConfig = supports[appTag]
        if versionConfig then
            local minVerCode = versionConfig.mincode
            local targetVerCode = versionConfig.targetcode
            --进行版本校验，最低版本大于软件版本，或者目标版本小于软件版本并且没有强制启用
            if (minVerCode and minVerCode > appVersionCode)
                or (targetVerCode and targetVerCode < appVersionCode and enabledVersion ~= appVersionCode) then
                return false
            end
        end
    end
    return toboolean(enabledVersion)
end

---新建插件环境表
---@return table virtualEnv 虚拟环境表
function PluginsManager.newPluginEnv(virtualEnv)
    virtualEnv = virtualEnv or {}
    virtualEnv._G = virtualEnv
    virtualEnv._ENV = virtualEnv

    setmetatable(virtualEnv, virtualEnvMetatable)
    return virtualEnv
end

---加载插件配置，自动重复利用已加载的插件
---@param pluginPath string 插件路径
---@return table pluginConfig
function PluginsManager.loadPluginConfig(pluginPath)
    local configPath = pluginPath .. "/init.lua"
    local virtualEnv
    PluginsManager.newPluginEnv(virtualEnv)
end

function PluginsManager.loadPlugin(pluginPath)

end

return PluginsManager
