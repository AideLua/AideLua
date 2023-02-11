local cannotBeEmptyStr=getString(R.string.jesse205_edit_error_cannotBeEmpty)
local existsStr=getString(R.string.file_exists)

function deleteFileDialog(name,file)
  local dialog=AlertDialog.Builder(this)
  .setTitle(formatResStr(R.string.delete_withName,{name}))
  --.setIcon(R.drawable.ic_delete_outline_colored)
  .setMessage(activity.getString(R.string.delete_warning))
  .setPositiveButton(android.R.string.ok,function()
    local succeed=LuaUtil.rmDir(file)
    if succeed then
      FilesBrowserManager.refresh()
      showSnackBar(R.string.delete_succeed)
      local config=FilesTabManager.openedFiles[string.lower(file.getPath())]
      if config then
        config.deleted=true
        FilesTabManager.closeFile(string.lower(file.getPath()))
      end
     else
      showSnackBar(R.string.delete_failed)
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
  local okButton=dialog.getButton(AlertDialog.BUTTON_POSITIVE)
  okButton.setTextColor(theme.color.Red)
  okButton.setRippleColor(ColorStateList({{}},{theme.color.Ripple.Red}))
end

function createDirsDialog(nowDir)--创建文件夹对话框
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(R.string.directory_create)
  :setHint(R.string.directory_name)
  :setAllowNull(false)
  :setPositiveButton(R.string.create,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local relativePath=text
    local nowPath=nowDir.getPath()
    local filePath=fixPath(rel2AbsPath(relativePath,nowPath))
    --local nowRelativePath=ProjectManager.shortPath(filePath,true,nowPath)
    --local nowCreatedName=nowRelativePath:match("^[^/]+")
    local file=File(filePath)
    if file.exists() then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      file.mkdirs()
      showSnackBar(R.string.create_success)
      FilesBrowserManager.refresh(nowDir,filePath)
      --dialog.dismiss()
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

function renameDialog(oldFile)--重命名对话框
  local fileName=oldFile.getName()
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(R.string.rename)
  :setText(fileName)
  :setHint(R.string.name)
  :setAllowNull(false)
  :setPositiveButton(R.string.rename,function(dialog,text)
    local editLay=builder.ids.editLay
    local errorState
    local relativePath=text

    local oldParentFile=oldFile.getParentFile()
    local oldFilePath=oldFile.getPath()
    local lowerOldFilePath=string.lower(oldFilePath)

    local newFilePath=fixPath(rel2AbsPath(relativePath,oldParentFile.getPath()))
    local newFile=File(newFilePath)
    local newParentFile=newFile.getParentFile()
    local lowerNewFilePath=string.lower(newFilePath)

    local isSelfFile=lowerNewFilePath==lowerOldFilePath
    if newFilePath==oldFilePath then--没改就退出
      return
    end
    if newFile.exists() and not(isSelfFile) then--文件不能存在
      editLay
      .setError(existsStr)
      .setErrorEnabled(true)
      return true
    end
    editLay.setErrorEnabled(false)
    xpcall(function()
      newParentFile.mkdirs()
      FilesTabManager.saveFile(lowerOldFilePath)
      if isSelfFile then--大小写直接修改无效，使用临时文件
        local tempFilePath=AppPath.Temp.."/"..os.time()
        os.rename(oldFilePath, tempFilePath)
        os.rename(tempFilePath, newFilePath)
       else
        os.rename(oldFilePath, newFilePath)
      end
      FilesTabManager.changePath(lowerOldFilePath,newFilePath)

      showSnackBar(R.string.rename_success)
      FilesBrowserManager.refresh(newParentFile,newFile.getName())
    end,
    function(err)
      showErrorDialog(R.string.rename_fail,err)
      errorState=true
    end)
    if errorState then
      return true
    end
  end,true,true)
  :setNegativeButton(android.R.string.cancel,nil)
  builder:show()
  local _,splitEnd=utf8.find(fileName,".+%.")
  if splitEnd then
    splitEnd=splitEnd-1
  end
  builder.ids.edit.setSelection(0,splitEnd or utf8.len(fileName))
end