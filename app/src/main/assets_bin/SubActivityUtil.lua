local SubActivityUtil={}
---在 v5.1.1(51199) 添加

local existsStr=getString(R.string.file_exists)
local BASE_DIR_PATH="%s/%s/src/main/assets_bin/%s"
local DIR_NAME_MATCH="^([^/]-)/src/main/assets_bin/([^/]+)"
local DIR_NAMES_LIST={"sub","subActivity","subActivities","activity","activities"}

function SubActivityUtil.getDirPath(nowDir)
  local basePath=ProjectManager.nowPath--当前工程路径
  local fileRelativePath=ProjectManager.shortPath(nowDir.getPath(),true,basePath)
  local moduleName,dirName=fileRelativePath:match(DIR_NAME_MATCH)--首先一键匹配模块文件夹名和活动文件夹名
  if moduleName and not FilesBrowserManager.isModuleRootPath(nowDir.getPath().."/"..moduleName) then--非法模块名自动转为主模块
    moduleName=ProjectManager.nowConfig.mainModuleName
  end
  moduleName=moduleName or FilesBrowserManager.getNowModuleDirName(fileRelativePath) or ProjectManager.nowConfig.mainModuleName--获取不到就调用单独的获取API
  if not(dirName and table.find(DIR_NAMES_LIST,dirName)) then
    for index=1,#DIR_NAMES_LIST do
      local name=DIR_NAMES_LIST[index]
      local path=BASE_DIR_PATH:format(basePath,moduleName,name)
      if File(path).isDirectory() then
        return path,moduleName,name
      end
    end
    dirName=DIR_NAMES_LIST[1]--没有任何文件夹存在，默认使用第一个
  end
  return BASE_DIR_PATH:format(basePath,moduleName,dirName),moduleName,dirName
end

function SubActivityUtil.showCreateActivityDialog(template,nowDir)
  local basePath,moduleName,dirName=SubActivityUtil.getDirPath(nowDir)
  local edit,editLay
  local builder=EditDialogBuilder(activity)
  :setTitle(formatResStr(R.string.project_create_withName,{template.name}))
  :setHint(R.string.name)
  :setAllowNull(false)
  :setPositiveButton(R.string.create,function(dialog,text)
    local basePathWithName=basePath.."/"..text
    local baseFileWithName=File(basePathWithName)
    if baseFileWithName.exists() then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      baseFileWithName.mkdirs()
      for index,content in ipairs(template.files) do
        content.moduleName=text
        CreateFileUtil.createFile(basePathWithName.."/"..content.name,content)
      end
      editLay.setErrorEnabled(false)
      showSnackBar(R.string.create_success)
    end,
    function(err)
      editLay
      .setError(err:match(".+throws.+Exception: (.-)\n") or err)
      .setErrorEnabled(true)
      showErrorDialog(R.string.create_failed,err)
      errorState=true
    end)
    FilesBrowserManager.refresh(baseFileWithName)
    if errorState then
      return true--防止对话框关闭
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()
  local ids=builder.ids
  edit,editLay=ids.edit,ids.editLay
  editLay.setHelperText(("module: %s\nfolder: %s"):format(moduleName,dirName))
  edit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)--获取到的text是java类型的
      if text~="" then
        local basePathWithName=basePath.."/"..text
        local file=File(basePathWithName)
        if file.exists() then--文件不能存在
          editLay
          .setError(existsStr)
          .setErrorEnabled(true)
          return true
        end
        editLay.setErrorEnabled(false)
      end
    end
  })
end

function SubActivityUtil.showSelectTypeDialog(nowDir)
  local choice=activity.getSharedData("createactivity_type")
  local nowDir=nowDir or FilesBrowserManager.directoryFile
  local names={}
  local templates={}
  for index,content in ipairs(ActivityTemplates) do
    local enabledVar=content.enabledVar
    if not(enabledVar) or _G[enabledVar] then
      table.insert(names,getLocalLangObj(content.name,content.enName))
      table.insert(templates,content)
      if choice==content.id then
        choice=table.size(templates)-1
      end
    end
  end
  if type(choice)~="number" then--类型不为数字类型说明没有找到真正的选项，设置为0
    choice=0
  end
  AlertDialog.Builder(activity)
  .setTitle(R.string.newActivity)
  .setSingleChoiceItems(names,choice,{onClick=function(dialogInterface,index)
      choice=index
      activity.setSharedData("createactivity_type",templates[index+1].id)
  end})
  .setPositiveButton(android.R.string.ok,function()
    local template=templates[choice+1]
    if template then
      SubActivityUtil.showCreateActivityDialog(template,nowDir)
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

return SubActivityUtil
