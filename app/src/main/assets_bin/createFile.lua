local ids
local dia
local cannotBeEmptyStr=getString(R.string.jesse205_edit_error_cannotBeEmpty)
local existsStr=getString(R.string.file_exists)

local function createFileInfoDialog(config,nowDir)--文件名填写对话框
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(formatResStr(R.string.project_create_withName,{config.name}))
  :setHint(R.string.file_name)
  :setAllowNull(false)
  :setPositiveButton(R.string.create,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local fileName=text
    local fileExtension=config.fileExtension
    if fileExtension and not(fileName:find("%.([^/]*)")) then
      fileName=fileName.."."..fileExtension
    end
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
      --openFile(file)
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
end

local function createFileDialog(nowDir)--模版选择对话框
  local choice=activity.getSharedData("LastCreateFileType") or 0
  local nowDir=nowDir or FilesBrowserManager.directoryFile
  local names={}
  for index,content in ipairs(FileTemplates) do
    table.insert(names,content.name)
  end
  AlertDialog.Builder(activity)
  .setTitle(R.string.file_create)
  .setSingleChoiceItems(names,choice,{onClick=function(dialogInterface,index)
      choice=index
      activity.setSharedData("LastCreateFileType",index)
  end})
  .setPositiveButton(android.R.string.ok,function()
    local template=FileTemplates[choice+1]
    if template then
      createFileInfoDialog(template,nowDir)
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

return createFileDialog