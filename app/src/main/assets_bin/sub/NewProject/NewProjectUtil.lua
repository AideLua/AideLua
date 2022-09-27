local NewProjectUtil={}
local TEMPLATES_DIR_PATH=NewProjectUtil2.TEMPLATES_DIR_PATH--模板路径
local PRJS_PATH=NewProjectUtil2.PRJS_PATH

NewProjectUtil.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectUtil.PRJS_PATH=PRJS_PATH

local errorCode2String={
  [1]=activity.getString(R.string.jesse205_edit_error_cannotBeEmpty),
  [2]=activity.getString(R.string.project_exists)
}
NewProjectUtil.errorCode2String=errorCode2String

--检查工程是否存在等
function NewProjectUtil.fastCheckAppNameError(appName)
  if appName=="" then
    return 1
   elseif File(PRJS_PATH.."/"..appName).exists() then
    return 2
  end
  return false
end

function NewProjectUtil.fastCheckPackageNameError(packageName)
  if packageName=="" then
    return 1
  end
  return false
end

function NewProjectUtil.checkAppName(appName,appNameLay,config)
  local appNameError=NewProjectUtil.fastCheckAppNameError(appName)
  if appNameError then
    appNameLay
    .setError(errorCode2String[appNameError])
    .setErrorEnabled(true)
   else
    appNameLay.setErrorEnabled(false)
  end
  if config then
    config.appNameError=appNameError
  end
  return appNameError
end
function NewProjectUtil.checkPackageName(packageName,packageNameLay,config)
  local packageNameError=NewProjectUtil.fastCheckPackageNameError(packageName)
  if packageNameError then
    packageNameLay
    .setError(errorCode2String[packageNameError])
    .setErrorEnabled(true)
   else
    packageNameLay.setErrorEnabled(false)
  end
  if config then
    config.packageNameError=packageNameError
  end
  return packageNameError
end

function NewProjectUtil.checkAppConfigError(appName,packageName,appNameLay,packageNameLay,config,createButton)
  local appNameError=NewProjectUtil.checkAppName(appName,appNameLay,config)
  local packageNameError=NewProjectUtil.checkPackageName(packageName,packageNameLay,config)

  if appNameError or packageNameError then
    createButton.setEnabled(false)
    return true
   else
    createButton.setEnabled(true)
    return false
  end
end

function NewProjectUtil.refreshCreateEnabled(config,createButton)
  if config.appNameError or config.packageNameError or config.helloWorld then
    createButton.setEnabled(false)
   else
    createButton.setEnabled(true)
  end
end
function NewProjectUtil.setSharedData(_type,key,value)
  return setSharedData("newproject_".._type..key,value)
end

function NewProjectUtil.getSharedData(_type,key)
  return getSharedData("newproject_".._type..key)
end


function NewProjectUtil.buildkeys(defaultKeys,config)
  local keys=table.clone(defaultKeys)
  local dependenciesEnd=keys.dependenciesEnd
  local keysLists={}
  local pluginsList={}
  local onBuildKeys=config.onBuildKeys
  if onBuildKeys then
    onBuildKeys(config.ids,config,keysLists)
  end

  for index,content in pairs(keysLists) do--遍历列表
    for index,content in pairs(content) do--遍历Keys
      local oldContentList=keys[index]
      local _type=type(oldContentList)
      if _type=="table" then
        for index,content in ipairs(content) do
          table.insert(oldContentList,content)
        end--将新的值追加到原列表
       else
        keys[index]=content--覆盖原有值
      end
    end
  end

  if keys.androidX then
    table.insert(dependenciesEnd,"api 'androidx.appcompat:appcompat:1.0.0'")
    table.insert(dependenciesEnd,"api 'com.google.android.material:material:1.0.0'")
  end
  --[[
  for index,content in pairs(openedCLibs) do
    table.insert(keysLists,content.keys)
    table.insert(pluginsList,index)
  end]]

  --[[
  keys.androidX=androidX
  keys.appName=appNameEdit.text
  keys.appPackageName=packageNameEdit.text
  keys.androluaVersion=androluaVersion[1]
  keys.androluaVersionCode=androluaVersion[2]
]]
  return keys
end

return NewProjectUtil
