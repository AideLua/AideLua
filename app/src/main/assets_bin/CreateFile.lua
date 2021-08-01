local ids
local dia
local cannotBeEmptyStr=activity.getString(R.string.edit_error_cannotBeEmpty)
local existsStr=activity.getString(R.string.file_exists)

local function createFileInfoDialog(config,nowDir)--文件名填写对话框
  local ids={}
  local dia=AlertDialog.Builder(this)
  .setTitle(formatResStr(R.string.project_create_withName,{config.name}))
  .setView(MyEditDialogLayout.load(nil,ids))
  .setPositiveButton(R.string.create,nil)
  .setNegativeButton(android.R.string.no,nil)
  .show()
  local edit,editLay=ids.edit,ids.editLay
  edit.requestFocus()--输入框取得焦点
  editLay.setHint(activity.getString(R.string.file_name))
  edit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)
      if text=="" then--文件名不能为空
        editLay
        .setError(cannotBeEmptyStr)
        .setErrorEnabled(true)
        return
      end
      editLay.setErrorEnabled(false)
    end
  })
  local function create()
    local editLay=ids.editLay
    local edit=ids.edit

    xpcall(function()
      local err
      local fileName=edit.text
      if not(fileName:find("%.")) then
        fileName=fileName.."."..config.fileType
      end
      if edit.text=="" then--文件名不能为空
        editLay
        .setError(cannotBeEmptyStr)
        .setErrorEnabled(true)
        return
      end
      local filePath=rel2AbsPath(fileName,nowDir.getPath())
      local file=File(filePath)
      fileName=file.getName()
      if file.exists() then--文件不能存在
        editLay
        .setError(existsStr)
        .setErrorEnabled(true)
        return
      end
      local moduleName=fileName:match("(.+)%.") or fileName
      local shoredModuleName=moduleName:gsub("%.","_"):gsub("%[",""):gsub("%]",""):gsub("%:","_")
      if table.find(LuaReservedCharacters,shoredModuleName) then
        shoredModuleName=shoredModuleName.."_"
      end
      file.getParentFile().mkdirs()
      file.createNewFile()
      local fileContent=config.defaultContent:gsub("{{ShoredModuleName}}",shoredModuleName):gsub("{{ModuleName}}",moduleName)
      io.open(filePath,"w"):write(fileContent):close()
      showSnackBar(R.string.create_success)
      editLay.setErrorEnabled(false)
      openFile(file)
      refresh(nowDir)
      dia.dismiss()
    end,
    function(err)
      showErrorDialog(R.string.create_failed,err)
    end)
  end
  dia.getButton(AlertDialog.BUTTON_POSITIVE).onClick=create
  ids.edit.onEditorAction=create
end

local function createFileDialog(nowDir)--模版选择对话框
  local choice=activity.getSharedData("LastCreateFileType") or 0
  local nowDir=nowDir or NowDirectory
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
  .setNegativeButton(android.R.string.no,nil)
  .show()
end

return createFileDialog