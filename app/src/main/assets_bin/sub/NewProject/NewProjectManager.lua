local NewProjectManager={}
local TEMPLATES_DIR_PATH=NewProjectUtil2.TEMPLATES_DIR_PATH--模板路径
local PRJS_PATH=NewProjectUtil2.PRJS_PATH--工程存放路径

NewProjectManager.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectManager.PRJS_PATH=PRJS_PATH

--将错误代码转为文字
local errorCode2String={
  [1]=activity.getString(R.string.jesse205_edit_error_cannotBeEmpty),
  [2]=activity.getString(R.string.project_exists)
}
NewProjectManager.errorCode2String=errorCode2String

function NewProjectManager.loadTemplate(path)
  local config=getConfigFromFile(path.."/config.lua")
  local subTemplateConfigsMap=config.subTemplateConfigsMap or {}
  local pageConfigs=assert(loadfile(path.."/pageConfigs.aly"))()
  local templateType=config.templateType
  templateMap[templateType]=config
  local configSuper={
    templateType=templateType,--模板类型
    templateConfig=config,--模板配置
    subTemplateConfigsMap=subTemplateConfigsMap,--子模板地图
    templateDirPath=path,--模板路径
  }
  local configMetatable={__index=configSuper}
  setmetatable(config,configMetatable)

  for index=1,#pageConfigs do
    local pageConfig=pageConfigs[index]
    setmetatable(pageConfig,configMetatable)
    local subTemplateName=pageConfig.subTemplateName
    pageConfig.subTemplateConfig=subTemplateConfigsMap[subTemplateName]--子模板配置
    pageConfig.subTemplateDirPath=path.."/"..subTemplateName--子模板路径
    table.insert(pageConfigsList,pageConfig)--添加到页面列表
  end
end

--仅检查工程是否存在，应用名为空等
function NewProjectManager.fastCheckAppNameError(appName)
  if appName=="" then
    return 1
   elseif File(PRJS_PATH.."/"..appName).exists() then
    return 2
  end
  return false
end

--仅检查包名为空等
function NewProjectManager.fastCheckPackageNameError(packageName)
  if packageName=="" then
    return 1
  end
  return false
end

--检查应用名，自动提示给用户，自动保存错误信息
function NewProjectManager.checkAppName(appName,appNameLay,config)
  local appNameError=NewProjectManager.fastCheckAppNameError(appName)
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

--同上
function NewProjectManager.checkPackageName(packageName,packageNameLay,config)
  local packageNameError=NewProjectManager.fastCheckPackageNameError(packageName)
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

--上面两个一块检查，包括创建按钮的状态
function NewProjectManager.checkAppConfigError(appName,packageName,appNameLay,packageNameLay,config)
  local appNameError=NewProjectManager.checkAppName(appName,appNameLay,config)
  local packageNameError=NewProjectManager.checkPackageName(packageName,packageNameLay,config)

  if appNameError or packageNameError then
    createButton.setEnabled(false)
    return true
   else
    createButton.setEnabled(true)
    return false
  end
end

--仅刷新创建按钮启用状态
function NewProjectManager.refreshCreateEnabled(config)
  if config.appNameError or config.packageNameError or config.helloWorld then
    createButton.setEnabled(false)
   else
    createButton.setEnabled(true)
  end
end

--为了方便存储数据
function NewProjectManager.setSharedData(_type,key,value)
  return setSharedData("newproject_".._type..key,value)
end

function NewProjectManager.getSharedData(_type,key)
  return getSharedData("newproject_".._type..key)
end

--刷新启用状态，比如AndroidX
function NewProjectManager.refreshState(refreshType,state,chipList)
  local notState=not(state)
  if refreshType=="androidx" then
    for index=1,#chipList do
      local chip=chipList[index]
      local content=chip.tag
      local support=content.support
      --local chip=content.chip
      if support then
        if (support=="androidx" and state) or (support=="normal" and notState) then
          chip.setEnabled(true)
          .setChecked(content.checked or false)
         elseif (support=="androidx" and notState) or (support=="normal" and state) then
          chip.setEnabled(false)
          .setChecked(false)
        end
      end
    end
  end
end



function NewProjectManager.onChipCheckChangedListener(view,isChecked)
  local config=view.tag
  local viewIndex=config.viewIndex
  local enabledList=config.enabledList
  if view.isEnabled() then
    setSharedData("newproject_"..config.path,isChecked)
    config.checked=isChecked
  end
  if isChecked then
    enabledList[viewIndex]=config
   else
    enabledList[viewIndex]=nil
  end
end


--构建一个键，需要格式化的文件的列表
function NewProjectManager.buildConfig(pageConfig)
  local keys=table.clone(pageConfig.defaultKeys or {})
  local formatList=table.clone(pageConfig.defaultFormatList or {})
  local unzipList=table.clone(pageConfig.defaultUnzipList or {})
  local dependenciesEnd=keys.dependenciesEnd
  local keysLists={}--这是准备整合到keys的列表
  local pluginsList={}
  local androidX=pageConfig.androidxState
  keys.androidX=androidX
  --NewProjectManager.getBaseTemplateZipPathList(TEMPLATES_DIR_PATH,androidX,"app","aide(2.1)")
  if androidX then--启用AndroiX后自动追加
    table.insert(dependenciesEnd,"api 'androidx.appcompat:appcompat:1.0.0'")
    table.insert(dependenciesEnd,"api 'com.google.android.material:material:1.0.0'")
  end

  local onBuildConfig=pageConfig.onBuildConfig
  if onBuildConfig then
    onBuildConfig(pageConfig.ids,pageConfig,keysLists,formatList,unzipList)
  end

  --把keysLists整合到keys
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


  return keys,formatList,unzipList
end

return NewProjectManager
