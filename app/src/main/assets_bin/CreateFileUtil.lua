import "config.fileTemplates"
---@deprecated
local CreateFileUtil={}

---不能为空的字符串
---@type string
local cannotBeEmptyStr=getString(R.string.jesse205_edit_error_cannotBeEmpty)

---文件已存在的字符串
---@type string
local existsStr=getString(R.string.file_exists)

---Lua关键字列表
---@type table
local LuaReservedCharacters = {"switch", "if", "then", "and", "break", "do", "else", "elseif", "end", "false", "for",
  "function", "in", "local", "nil", "not", "or", "repeat", "return", "true", "until", "while","goto"} -- lua关键字

---根据文件名和扩展名获取用户真正想创建的文件路径
---@param name string 用户输入的名称
---@param extensionName string 扩展名
---@return string path 返回文件路径
local function buildReallyFilePath(name,extensionName)
  local path=name
  if extensionName and not(path:find("%.[^/]*$")) then
    return path.."."..extensionName
  end
  return path
end

---创建文件
---@param path string 文件路径
---@param config table 文件配置
function CreateFileUtil.createFile(path,config)
  local file=File(path)
  local name=file.getName()
  local moduleName=config.moduleName or name:match("(.+)%.") or name
  local shoredModuleName=moduleName:gsub("%.","_"):gsub("%[",""):gsub("%]",""):gsub("%:","_")
  if table.find(LuaReservedCharacters,shoredModuleName) then
    shoredModuleName="_"..shoredModuleName
  end
  file.getParentFile().mkdirs()
  file.createNewFile()
  local fileContent=config.content:gsub("{{ShoredModuleName}}",shoredModuleName):gsub("{{ModuleName}}",moduleName)
  io.open(path,"w"):write(fileContent):close()
end

---展示创建文件对话框
---@param config table 模板配置
---@param nowDir File 当前文件夹对象，用于判断文件是否存在
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
    local relativePath=buildReallyFilePath(text,fileExtension)
    local filePath=fixPath(rel2AbsPath(relativePath,nowDir.getPath()))
    local file=File(filePath)
    if file.exists() then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      CreateFileUtil.createFile(filePath,config)
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
    FilesBrowserManager.refresh(file.getParentFile(),filePath)
    if errorState then
      return true--防止对话框关闭
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()

  local ids=builder.ids
  local edit,editLay=ids.edit,ids.editLay
  local lastErtor=false--如果在关闭错误之后立马设置帮助文字，就会导致帮助文字不显示。所以需要判断一下。

  editLay.setHelperText(formatResStr(R.string.file_viewName_content,{"."..fileExtension}))--设置初始显示的名字，因为刚进入时没有提示错误
  edit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)--获取到的text是java类型的，所以要转换成string
      if text~="" then
        local fileName=File(buildReallyFilePath(text,fileExtension)).getName()
        if lastErtor then
          editLay
          .setHelperTextEnabled(false)
          .setHelperTextEnabled(true)
        end
        editLay.setHelperText(formatResStr(R.string.file_viewName_content,{fileName}))
        lastErtor=false
       else
        lastErtor=true
      end
    end
  })
end

---展示选择类型对话框
---@param nowDir File 文件夹对象
function CreateFileUtil.showSelectTypeDialog(nowDir)--模版选择对话框
  local choice=activity.getSharedData("createfile_type")
  local nowDir=nowDir or FilesBrowserManager.directoryFile
  local names={}
  local templates={}
  for index,content in ipairs(fileTemplates) do
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

  MaterialAlertDialogBuilder(activity)
  .setTitle(R.string.file_create)
  .setSingleChoiceItems(names,choice,function(dialogInterface,index)
      choice=index
      activity.setSharedData("createfile_type",templates[index+1].id)
  end)
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