local NewProjectUtil={}
local TEMPLATES_DIR_PATH=NewProjectUtil2.TEMPLATES_DIR_PATH--模板路径
local PRJS_PATH=NewProjectUtil2.PRJS_PATH--工程存放路径

NewProjectUtil.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectUtil.PRJS_PATH=PRJS_PATH

--将错误代码转为文字
local errorCode2String={
  [1]=activity.getString(R.string.jesse205_edit_error_cannotBeEmpty),
  [2]=activity.getString(R.string.project_exists)
}
NewProjectUtil.errorCode2String=errorCode2String

--仅检查工程是否存在，应用名为空等
function NewProjectUtil.fastCheckAppNameError(appName)
  if appName=="" then
    return 1
   elseif File(PRJS_PATH.."/"..appName).exists() then
    return 2
  end
  return false
end

--仅检查包名为空等
function NewProjectUtil.fastCheckPackageNameError(packageName)
  if packageName=="" then
    return 1
  end
  return false
end

--检查应用名，自动提示给用户，自动保存错误信息
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

--同上
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

--上面两个一块检查，包括创建按钮的状态
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

--仅刷新创建按钮启用状态
function NewProjectUtil.refreshCreateEnabled(config,createButton)
  if config.appNameError or config.packageNameError or config.helloWorld then
    createButton.setEnabled(false)
   else
    createButton.setEnabled(true)
  end
end

--为了方便存储数据
function NewProjectUtil.setSharedData(_type,key,value)
  return setSharedData("newproject_".._type..key,value)
end

function NewProjectUtil.getSharedData(_type,key)
  return getSharedData("newproject_".._type..key)
end

--刷新启用状态，比如AndroidX
function NewProjectUtil.refreshState(refreshType,state,chipList)
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

function NewProjectUtil.addTemplate()
end


function NewProjectUtil.onChipCheckChanged(view,isChecked)
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

function NewProjectUtil.getBaseTemplateZipPathList(basePath,androidx,_type,ver)
  local path=rel2AbsPath(basePath,TEMPLATES_DIR_PATH)
  if _type then
    path=path.."/".._type.."Template"
    if ver then
      path=path.."/"..path
    end
  end
  path=path.."/"
  local list={path.."baseTemplate.zip"}
  if androidx then
    table.insert(list,list.."android.zip")
   else
    table.insert(list,list.."normal.zip")
  end
  return list
end

--构建一个键，需要格式化的文件的列表
function NewProjectUtil.buildConfig(defaultKeys,defaultFormatList,defaultUnzipList,config)
  local keys=table.clone(defaultKeys)
  local formatList=table.clone(defaultFormatList)
  local unzipList=table.clone(defaultUnzipList)
  local dependenciesEnd=keys.dependenciesEnd
  local keysLists={}--这是准备整合到keys的列表
  local pluginsList={}
  local androidX=config.androidxState
  keys.androidX=androidX
  NewProjectUtil.getBaseTemplateZipPathList(TEMPLATES_DIR_PATH,androidX,"app",ver)
  if androidX then--启用AndroiX后自动追加
    table.insert(dependenciesEnd,"api 'androidx.appcompat:appcompat:1.0.0'")
    table.insert(dependenciesEnd,"api 'com.google.android.material:material:1.0.0'")
  end

  local onBuildConfig=config.onBuildConfig
  if onBuildConfig then
    onBuildConfig(config.ids,config,keysLists,formatList,unzipList)
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

return NewProjectUtil
