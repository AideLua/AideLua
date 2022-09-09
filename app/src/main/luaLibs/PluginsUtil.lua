local PluginsUtil = {}
local plugins

local activityName
local setEnabled, getEnabled, loadPlugins, getPluginPath, getPluginDataPath, getAvailable

local PLUGINS_PATH = AppPath.AppShareDir .. "/plugins"
local PLUGINS_DATA_PATH = AppPath.AppShareDir .. "/data/plugins"
PluginsUtil.PLUGINS_PATH = PLUGINS_PATH
PluginsUtil.PLUGINS_DATA_PATH = PLUGINS_DATA_PATH
PluginsUtil._VERSION="3.0"

local appPackageName = activity.getPackageName()
local PackInfo = activity.PackageManager.getPackageInfo(appPackageName, 0)
local versionCode = PackInfo.versionCode


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
        showErrorDialog("Plugin"..plugins.eventsName2[name][index].."error",err)
      end, activityName, ...)
      if result~=nil then
        finalResult=result
      end
    end
  end
  if events2 then
    for index, content in ipairs(events2) do
      local state,result=xpcall(content, function(err)
        showErrorDialog("Plugin"..plugins.eventsName2[name][index].."error",err)
      end, ...)
      if result~=nil then
        finalResult=result
      end
    end
  end
  return finalResult
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

local function getPluginsEventsAndName(pluginsEvents,pluginsEventsName,name)
  local eventsList=pluginsEvents[name]
  local eventsNameList=pluginsEventsName[name]
  if eventsList==nil then
    eventsList={}
    eventsNameList={}
    pluginsEvents[name]=eventsList
    pluginsEventsName[name]=eventsNameList
  end
  return eventsList,eventsNameList
end

local pluginEnvTable={
  getPluginPath=getPluginPath,
  getPluginDataPath=getPluginDataPath,

}
setmetatable(pluginEnvTable,{__index=_G})

function loadPlugins()
  plugins = {}
  local pluginsEvents = {}
  local pluginsEventsName = {}
  local pluginsEvents2 = {}
  local pluginsEventsName2 = {}
  local pluginsActivities = {}
  local pluginsActivitiesName = {}
  plugins.events = pluginsEvents
  plugins.eventsName = pluginsEventsName
  plugins.events2 = pluginsEvents2
  plugins.eventsName2 = pluginsEventsName2
  plugins.activities = pluginsActivities
  plugins.activitiesName = pluginsActivitiesName

  local pluginsFile = File(PLUGINS_PATH)
  if pluginsFile.isDirectory() then -- 存在插件文件夹
    local fileList = pluginsFile.listFiles()
    for index = 0, #fileList - 1 do
      local file = fileList[index]
      local path = file.getPath()
      local dirName = file.getName()

      local defaultEnabled = getEnabled(dirName)

      if defaultEnabled then -- 检测是否开启
        local initPath = path .. "/init.lua"
        local mainPath = path .. "/main.lua"
        local configDirPath = path .. "/config"
        local eventsDirPath = configDirPath .. "/events"

        if File(initPath).isFile() then -- 存在init.lua
          xpcall(function()
            local config = getConfigFromFile(initPath) -- init.lua内容
            config.pluginPath = path
            setmetatable(config, {__index = pluginEnvTable})--设置环境变量
            local minVerCode = config.minemastercode
            local targetVerCode = config.targetmastercode
            --进行版本校验
            if (not (minVerCode) or minVerCode <= versionCode) and
              (not (targetVerCode) or targetVerCode >= versionCode or defaultEnabled == versionCode) then -- 版本号在允许的范围之内或者强制启用
              local thirdPlugins = config.thirdplugins
              local err = false
              if thirdPlugins then
                for index, content in ipairs(thirdPlugins) do
                  if not (getAvailable(content)) then
                    print("Plugin", dirName, "error: Plugin", content, "not found.")
                    err = true
                  end
                end
              end
              --没有问题
              if err == false then
                local name = ("%s (%s)"):format(config.appname, config.packagename or dirName)
                local fileEvents=config.events
                if fileEvents then
                  for index,content in pairs(fileEvents) do
                    local eventsList,eventsNameList=getPluginsEventsAndName(pluginsEvents,pluginsEventsName,index)
                    table.insert(eventsList,content)
                    table.insert(eventsNameList,name)
                  end
                end
                if activityName then
                  local eventsAlyPath = eventsDirPath .. "/" .. activityName .. ".aly"
                  if File(eventsAlyPath).isFile() then
                    local fileEvents = assert(loadfile(eventsAlyPath, "bt", config))()
                    for index, content in pairs(fileEvents) do
                      local eventsList,eventsNameList=getPluginsEventsAndName(pluginsEvents2,pluginsEventsName2,index)
                      table.insert(eventsList,content)
                      table.insert(eventsNameList,name)
                    end
                  end
                end

                --可以使用单独的页面打开
                if File(mainPath).isFile() then
                  table.insert(pluginsActivities, mainPath)
                  table.insert(pluginsActivitiesName, config.appname or config.packagename or dirName)
                end

              end
            end
          end,
          function(err) -- 语法错误，或者其他问题
            showErrorDialog("Plugin"..dirName.."error",err)
          end)
          -- else--init.lua不存在
          -- print("Plugin",dirName,"error: init.lua missing.")
        end
      end
    end

  end
  return PluginsUtil
end
PluginsUtil.loadPlugins = loadPlugins

return PluginsUtil
