local PluginsManager = {}
PluginsManager._VERSION = "4.0.0 (dev)"
PluginsManager._VERSION_CODE = 40001

local PLUGINS_PATH_USER=AppPath.AppMediaDir .. "/plugins"
local PLUGINS_PATH_SYSTEM=AppPath.AppDataDir .. "/plugins"
local PLUGINS_PATHS = {
  PLUGINS_PATH_USER,
  PLUGINS_PATH_SYSTEM,
}
local PLUGINS_DATA_PATH = AppPath.AppMediaDir .. "/data/plugins"
PluginsManager.PLUGINS_PATH_USER = PLUGINS_PATH_USER
PluginsManager.PLUGINS_PATH_SYSTEM = PLUGINS_PATH_SYSTEM
PluginsManager.PLUGINS_PATHS = PLUGINS_PATHS
PluginsManager.PLUGINS_DATA_PATH = PLUGINS_DATA_PATH

--已加载插件列表 pluginPackageName:pluginConfig
local loadedPluginsMap = {}
PluginsManager.loadedPluginsMap = loadedPluginsMap

--path:pluginConfig
local loadedPluginConfigsMap = {}
PluginsManager.loadedPluginConfigsMap = loadedPluginConfigsMap


local appPackageName = activity.getPackageName()
local appPackageInfo = activity.PackageManager.getPackageInfo(appPackageName, 0)
local appVersionCode = appPackageInfo.versionCode
local apptype=apptype
local activityName

function PluginsManager.clearOpenedPluginPaths()
  application.set("plugin_enabledPaths", nil)
end

function PluginsManager.getOpenedPluginPaths()
  local paths = application.get("plugin_enabledPaths")
  if paths then
    return paths
  end
  paths={}
  for pluginsDirPathKey=1,#PLUGINS_PATHS do
    local pluginsDirPath=PLUGINS_PATHS[pluginsDirPathKey]
  end
end

---设置活动标识
function PluginsManager.setActivityName(name)
  activityName = name
  return PluginsManager
end

---@param versionCode number|boolean 软件版本号，true:默认启用，受targetcode控制 或false:停用插件
function PluginsManager.setEnabledVersion(pluginPackageName,versionCode)
  setSharedData("plugin_" .. pluginPackageName .. "_enabled", versionCode)
  return PluginsManager
end

function PluginsManager.getEnabledVersion(pluginPackageName)
  local enabledVersion=getSharedData("plugin_" .. pluginPackageName .. "_enabled")
  if enabledVersion == nil then
    enabledVersion=true
  end
  return enabledVersion
end

---设置插件启用状态
---储存值：number|boolean 软件版本号，true:默认启用，受targetcode控制 或false:停用插件
---@param pluginPackageName string 插件包名
---@param enabled boolean 状态，自动判断
function PluginsManager.setEnabled(pluginConfig,enabled)
  local pluginPackageName=pluginConfig.packagename
  local enabledVersionCode=
  PluginsManager.setEnabledVersion(pluginPackageName,versionCode)
  return PluginsManager
end

function PluginsManager.getEnabled(pluginConfig)
  local pluginPackageName=pluginConfig.packagename
  local enabledVersion=PluginsManager.getEnabledVersion(pluginPackageName)
  local supports=pluginConfig.supported2
  if enabledVersion and apptype and supports then--只有当enabledVersion为true时才需要判断兼容版本
    local versionConfig=supports[apptype]
    if versionConfig then
      local minVerCode = versionConfig.mincode
      local targetVerCode = versionConfig.targetcode
      --进行版本校验
      if (minVerCode and minVerCode > appVersionCode)
        or (targetVerCode and targetVerCode < appVersionCode and enabledVersion ~= appVersionCode) then
        return false
      end
    end
  end
  return toboolean(enabledVersion)
end

function PluginsManager.getAvailable(packageName)
  local path = getPluginPath(packageName)
  if not (File(path).isDirectory()) then
    return false
  end
  return PluginsManager.getEnabled(packageName)
end

local virtualEnvCloneList={"android","short","tostring","string",
  "activity","func","xpcall","collectgarbage","load",
  "import","tointeger","_VERSION","loadstring","loadmenu",
  "byte","double",--[["_G",]]"boolean","rawget","this","module",
  "tonumber","ipairs","getmetatable","require",
  "setmetatable","dump","rawlen","task","float","pcall",
  "setmetamethod","luajava","type","select","d","getids",
  "loadfile","math","next","loadbitmap","loadlayout",
  "thread","unpack","io","set","long","assert","char","enum",
  "printstack","os","timer","debug","rawset","compile",
  "coroutine","rawequal","print","bit32","findtable",
  "call","dofile","pairs","each","package","utf8","table",
  "int","error"}

local baseVirtualEnv={
  _APP_G=_G,
}

local virtualEnvMetatable={__index=baseVirtualEnv}

for index=1,#virtualEnvCloneList do
  local value=baseVirtualEnv[index]
  baseVirtualEnv[value]=_ENV[value]
end

---新建插件环境表
function PluginsManager.newPluginEnv()

  local virtualEnv={}
  virtualEnv._G=virtualEnv
  virtualEnv._ENV=virtualEnv

  setmetatable(virtualEnv,virtualEnvMetatable)
  return virtualEnv
end

function PluginsManager.loadPluginConfig(pluginPath)

  local configPath=pluginPath.."/init.lua"
  local virtualEnv=PluginsManager.newPluginEnv()

end

function PluginsManager.loadPlugin(pluginPath)

end


return PluginsManager
