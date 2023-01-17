local PluginsUtil = {}
local plugins
local enabledPluginPaths

local activityName
local setEnabled, getEnabled, getReallyEnabled, loadPlugins,
getPluginPath, getPluginDataPath, getAvailable,
getPluginsEventsAndName,getConfig,onPluginError


local PLUGINS_PATH = AppPath.AppMediaDir .. "/plugins"
local PLUGINS_DATA_PATH = AppPath.AppMediaDir .. "/data/plugins"
PluginsUtil.PLUGINS_PATH = PLUGINS_PATH
PluginsUtil.PLUGINS_DATA_PATH = PLUGINS_DATA_PATH
PluginsUtil._VERSION="3.1"

local appPackageName = activity.getPackageName()
local packInfo = activity.PackageManager.getPackageInfo(appPackageName, 0)
local versionCode = packInfo.versionCode


function PluginsUtil.callElevents(name, ...)
  --if activityName then
  if plugins == nil then
    loadPlugins()
  end
  local events = plugins.events[name]--公共事件
  local events2 = plugins.events2[name]--页面事件
  local finalResult
  if events then
    for index, content in ipairs(events) do
      local state,result=xpcall(content, function(err)
        onPluginError(plugins.eventsName[name][index],plugins.eventsPackageName[name][index],err,name.." (Global)")
      end, activityName, ...)
      if result~=nil then
        finalResult=result or finalResult
      end
    end
  end
  if events2 then
    for index, content in ipairs(events2) do
      local state,result=xpcall(content, function(err)
        onPluginError(plugins.eventsName2[name][index],plugins.eventsPackageName2[name][index],err,name)
      end, ...)
      if result~=nil then
        finalResult=result or finalResult
      end
    end
  end
  return finalResult
end

function PluginsUtil.clearOpenedPluginPaths()
  application.set("plugin_enabledpaths",nil)
end

function PluginsUtil.getPlugins()
  return plugins
end

function PluginsUtil.setPlugins(newPlugins)
  plugins = newPlugins
  return PluginsUtil
end

--设置活动标识
function PluginsUtil.setActivityName(name)
  activityName = name
  return PluginsUtil
end

function setEnabled(packageName, state)
  setSharedData("plugin_" .. packageName .. "_enabled", state)
  return PluginsUtil
end
PluginsUtil.setEnabled = setEnabled

function getEnabled(packageName)
  local state = getSharedData("plugin_" .. packageName .. "_enabled")
  if state == nil then
    setEnabled(packageName, true)
    return true
   else
    return state or false
  end
end
PluginsUtil.getEnabled = getEnabled

--获取是不是真正启用了
function getReallyEnabled(enabled,config)
  local supports=config.supported2
  if apptype and supports then
    local versionConfig=supports[apptype]
    if versionConfig then
      local minVerCode = versionConfig.mincode
      local targetVerCode = versionConfig.targetcode
      --进行版本校验
      if (minVerCode and minVerCode > versionCode) or (targetVerCode and targetVerCode < versionCode and enabled ~= versionCode) then
        return false
      end
    end
  end
  return true
end
PluginsUtil.getReallyEnabled = getReallyEnabled


--获取插件目录，如果文件夹名与真正的packageName请手动输入文件夹名
function getPluginPath(packageName)
  return PLUGINS_PATH .. "/" .. packageName
end
PluginsUtil.getPluginPath = getPluginPath

--获取插件数据目录
function getPluginDataPath(packageName)
  return PLUGINS_DATA_PATH .. "/" .. packageName
end
PluginsUtil.getPluginDataPath=getPluginDataPath


--获取插件是否可用
function getAvailable(packageName)
  local path = getPluginPath(packageName)
  if not (File(path).isDirectory()) then
    return false
  end
  return getEnabled(packageName)
end
PluginsUtil.getAvailable = getAvailable

--获取函数的插件事件与名字列表
function getPluginsEventsAndName(pluginsEvents,pluginsEventsName,pluginsEventsPackageName,name)
  local eventsList=pluginsEvents[name]
  local eventsNameList=pluginsEventsName[name]
  local eventsPackageNameList=pluginsEventsPackageName[name]
  if eventsList==nil then
    eventsList={}
    eventsNameList={}
    eventsPackageNameList={}
    pluginsEvents[name]=eventsList
    pluginsEventsName[name]=eventsNameList
    pluginsEventsPackageName[name]=eventsPackageNameList
  end
  return eventsList,eventsNameList,eventsPackageNameList
end

local pluginEnvTable={
  getPluginPath=getPluginPath,
  getPluginDataPath=getPluginDataPath,
}
setmetatable(pluginEnvTable,{__index=_G})

local pluginEnvMetaTable={__index = pluginEnvTable}

function getConfig(configs,path)
  local config=configs[path]
  if not(config) then
    config = getConfigFromFile(path .. "/init.lua") -- init.lua内容
    config.pluginPath = path
    setmetatable(config, pluginEnvMetaTable)--设置环境变量
    configs[path]=config
  end
  return config
end

function onPluginError(titleName,packageName,message,funcName)
  showErrorDialog("Plugin "..titleName.." error",message)
  pcall(function()
    io.open("/sdcard/Androlua/crash/"..activity.getPackageName().."_"..packageName..".txt","a"):write(funcName..os.date(" %Y-%m-%d %H:%M:%S").."\n"..message.."\n\n"):close()
  end)
end


function loadPlugins()
  plugins = {}
  --已启用的插件列表
  enabledPluginPaths=application.get("plugin_enabledpaths")
  --插件全局事件
  local pluginsEvents = {}
  local pluginsEventsName = {}
  local pluginsEventsPackageName = {}
  --插件独立事件
  local pluginsEvents2 = {}
  local pluginsEventsName2 = {}
  local pluginsEventsPackageName2 = {}
  --插件页面
  local pluginsActivities = {}
  local pluginsActivitiesName = {}
  --配置
  local configs={}
  plugins.events = pluginsEvents
  plugins.eventsName = pluginsEventsName
  plugins.eventsPackageName = pluginsEventsPackageName
  plugins.events2 = pluginsEvents2
  plugins.eventsName2 = pluginsEventsName2
  plugins.eventsPackageName2 = pluginsEventsPackageName2
  plugins.activities = pluginsActivities
  plugins.activitiesName = pluginsActivitiesName
  plugins.configs=configs
  --没有保存的值，就刷新一遍
  if not(enabledPluginPaths) then
    enabledPluginPaths={}
    local pluginsFile = File(PLUGINS_PATH)
    if pluginsFile.isDirectory() then -- 存在插件文件夹
      local fileList = pluginsFile.listFiles()
      for index = 0, #fileList - 1 do
        local file = fileList[index]
        local path = file.getPath()
        local dirName = file.getName()
        --获取当前状态
        local defaultEnabled = getEnabled(dirName)
        if defaultEnabled then -- 检测是否开启
          local initPath = path .. "/init.lua"
          if File(initPath).isFile() then -- 存在init.lua
            xpcall(function()
              --获取config
              --下面的步骤和getConfig执行的结果完全一样，但出于性能考虑，重复写一套
              local config = getConfigFromFile(initPath) -- init.lua内容
              config.pluginPath = path
              setmetatable(config, {__index = pluginEnvTable})--设置环境变量
              configs[path]=config
              --判断版本号有没有超出限制
              if getReallyEnabled(defaultEnabled,config) then
                local err=false
                local thirdPlugins = config.thirdplugins
                if thirdPlugins then--存在需要的第三方插件库
                  for index, content in ipairs(thirdPlugins) do
                    if not (getAvailable(content)) then--如果存在不可用的
                      print("Plugin", dirName, "error: Plugin", content, "not found.")
                      err = true
                    end
                  end
                end
                --没有问题
                if err == false then
                  table.insert(enabledPluginPaths,path)
                end
              end
            end,
            function(err) -- 语法错误，或者其他问题
              onPluginError(dirName,dirName,err,"init.lua")
            end)
          end
        end
      end
    end
    enabledPluginPaths=String(enabledPluginPaths)
    application.set("plugin_enabledpaths",enabledPluginPaths)
  end

  for index=0,#enabledPluginPaths-1 do
    local path=enabledPluginPaths[index]
    local file=File(path)
    local dirName = file.getName()
    local config=getConfig(configs,path)

    --main.lua 路径
    local mainPath = path .. "/main.lua"

    --config 文件夹路径
    local configDirPath = path .. "/config"
    --events 文件夹路径
    local eventsDirPath = configDirPath .. "/events"

    --MyPlugin(com.mycompany.myplugin)
    local name = ("%s (%s)"):format(config.appname, config.packagename or dirName)
    local fileEvents=config.events
    if fileEvents then
      for index,content in pairs(fileEvents) do
        local eventsList,eventsNameList,eventsPackageNameList=getPluginsEventsAndName(pluginsEvents,pluginsEventsName,pluginsEventsPackageName,index)
        table.insert(eventsList,content)
        table.insert(eventsNameList,name)
        table.insert(eventsPackageNameList,config.packagename)
      end
    end
    if activityName then
      local eventsAlyPath = eventsDirPath .. "/" .. activityName .. ".aly"
      if File(eventsAlyPath).isFile() then
        local fileEvents = assert(loadfile(eventsAlyPath, "bt", config))()
        for index, content in pairs(fileEvents) do
          local eventsList,eventsNameList,eventsPackageNameList=getPluginsEventsAndName(pluginsEvents2,pluginsEventsName2,pluginsEventsPackageName2,index)
          table.insert(eventsList,content)
          table.insert(eventsNameList,name)
          table.insert(eventsPackageNameList,config.packagename)
        end
      end
    end

    --可以使用单独的页面打开
    if File(mainPath).isFile() then
      table.insert(pluginsActivities, mainPath)
      table.insert(pluginsActivitiesName, config.appname or config.packagename or dirName)
    end
  end


  return PluginsUtil
end
PluginsUtil.loadPlugins = loadPlugins

return PluginsUtil
