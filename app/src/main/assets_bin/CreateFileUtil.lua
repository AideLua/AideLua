local CreateFileUtil={}
local ids
local dia
local cannotBeEmptyStr=getString(R.string.jesse205_edit_error_cannotBeEmpty)
local existsStr=getString(R.string.file_exists)

--根据文件名和扩展名获取用户真正想创建的文件名
local function buildReallyFileName(name,extensionName)
  if extensionName and not(name:find("%.[^/]*$")) then
    return name.."."..extensionName
  end
  return name
end

function CreateFileUtil.showCreateFileDialog(config,nowDir)--文件名填写对话框
  local builder
  local fileExtension=config.fileExtension
  builder=EditDialogBuilder(activity)
  :setTitle(formatResStr(R.string.project_create_withName,{config.name}))
  :setHint(R.string.file_name)
  :setAllowNull(false)
  :setPositiveButton(R.string.create,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local fileName=buildReallyFileName(text,fileExtension)
    local filePath=rel2AbsPath(fileName,nowDir.getPath())
    local file=File(filePath)
    if file.exists() then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      local moduleName=fileName:match("(.+)%.") or fileName
      local shoredModuleName=(moduleName:match("/(.+)") or moduleName):gsub("%.","_"):gsub("%[",""):gsub("%]",""):gsub("%:","_")
      if table.find(LuaReservedCharacters,shoredModuleName) then
        shoredModuleName=shoredModuleName.."_"
      end
      file.getParentFile().mkdirs()
      file.createNewFile()
      local fileContent=config.defaultContent:gsub("{{ShoredModuleName}}",shoredModuleName):gsub("{{ModuleName}}",moduleName)
      io.open(filePath,"w"):write(fileContent):close()
      editLay.setErrorEnabled(false)
      showSnackBar(R.string.create_success)
      FilesBrowserManager.refresh(nowDir)
    end,
    function(err)
      showErrorDialog(R.string.create_failed,err)
      errorState=true
    end)
    if errorState then
      return true
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()
  local ids=builder.ids
  local edit,editLay=ids.edit,ids.editLay
  editLay.setHelperText("."..fileExtension)

  local lastErtor=false--如果在关闭错误之后立马设置帮助文字，就会导致帮助文字不显示。所以需要判断一下。
  edit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)--获取到的text是java类型的
      if text~="" then
        local fileName=buildReallyFileName(text,fileExtension)
        if lastErtor then
          editLay
          .setHelperTextEnabled(false)
          .setHelperTextEnabled(true)
        end
        editLay.setHelperText(fileName)
        lastErtor=false
       else
        lastErtor=true
      end
    end
  })
end

function CreateFileUtil.showSelectTypeDialog(nowDir)--模版选择对话框
  local choice=activity.getSharedData("createfile_type")
  local nowDir=nowDir or FilesBrowserManager.directoryFile
  local names={}
  local templates={}
  for index,content in ipairs(FileTemplates) do
    local enabledVar=content.enabledVar
    if not(enabledVar) or _G[enabledVar] then
      table.insert(names,getLocalLangObj(content.name,content.enName))
      table.insert(templates,content)
      if choice==content.id then
        choice=table.size(templates)-1
      end
    end
  end
  if type(choice)~="number" then
    choice=0
  end

  AlertDialog.Builder(activity)
  .setTitle(R.string.file_create)
  .setSingleChoiceItems(names,choice,{onClick=function(dialogInterface,index)
      choice=index
      activity.setSharedData("createfile_type",templates[index+1].name)
  end})
  .setPositiveButton(android.R.string.ok,function()
    local template=templates[choice+1]
    if template then
      CreateFileUtil.showCreateFileDialog(template,nowDir)
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

return CreateFileUtil