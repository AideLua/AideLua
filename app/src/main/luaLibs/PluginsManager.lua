local PluginsManager={}
PluginsManager._VERSION="4.0.0 (dev)"
PluginsManager._VERSIONCODE=40001

local PLUGINS_PATH = AppPath.AppMediaDir .. "/plugins"
local PLUGINS_DATA_PATH = AppPath.AppMediaDir .. "/data/plugins"
PluginsManager.PLUGINS_PATH = PLUGINS_PATH
PluginsManager.PLUGINS_DATA_PATH = PLUGINS_DATA_PATH

--已加载插件列表 pluginPackageName:pluginConfig
local loadedPluginsMap={}
PluginsManager.loadedPluginsMap=loadedPluginsMap

local appPackageName = activity.getPackageName()
local appPackageInfo = activity.PackageManager.getPackageInfo(appPackageName, 0)
local appVersionCode = appPackageInfo.versionCode

local activityName,setEnabled

function PluginsManager.clearOpenedPluginPaths()
  application.set("plugin_enabledpaths",nil)
end

---设置活动标识
function PluginsManager.setActivityName(name)
  activityName = name
  return PluginsManager
end

---设置插件启用状态
---@param pluginPackageName string 插件包名
---@param versionCode number|boolean 插件版本号，true（强制启用，无视targetcode）或false（停用插件
function PluginsManager.setEnabled(pluginPackageName, versionCode)
  setSharedData("plugin_" .. pluginPackageName .. "_enabled", versionCode)
  return PluginsManager
end


return PluginsManager
