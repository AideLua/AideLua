local cannotBeEmptyStr=activity.getString(R.string.edit_error_cannotBeEmpty)
local existsStr=activity.getString(R.string.file_exists)

function deleteFileDialog(name,file)
  AlertDialog.Builder(this)
  .setTitle(formatResStr(R.string.delete_withName,{name}))
  .setMessage(activity.getString(R.string.delete_warning))
  .setPositiveButton(android.R.string.ok,function()
    local succeed=LuaUtil.rmDir(file)
    if succeed then
      showSnackBar(R.string.delete_succeed)
      if OpenedFile then
        closeFileAndTabByPath(file.getPath(),true)
      end
     else
      showSnackBar(R.string.delete_failed)
    end
    refresh()
  end)
  .setNegativeButton(android.R.string.no,nil)
  .show()
end

function createDirsDialog(nowDir)--创建文件夹对话框
  local ids={}
  local dia=AlertDialog.Builder(this)
  .setTitle(R.string.directory_create)
  .setView(MyEditDialogLayout.load(nil,ids))
  .setPositiveButton(R.string.create,nil)
  .setNegativeButton(android.R.string.no,nil)
  .show()

  local edit,editLay=ids.edit,ids.editLay
  edit.requestFocus()--输入框取得焦点
  editLay.setHint(activity.getString(R.string.directory_name))
  edit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)
      if text=="" then--文件夹名不能为空
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
      if fileName=="" then--文件夹名不能为空
        editLay
        .setError(cannotBeEmptyStr)
        .setErrorEnabled(true)
        return
      end
      local filePath=rel2AbsPath(fileName,nowDir.getPath())
      local file=File(filePath)
      if file.exists() then--文件不能存在
        editLay
        .setError(existsStr)
        .setErrorEnabled(true)
        return
      end
      editLay.setErrorEnabled(false)
      file.mkdirs()
      showSnackBar(R.string.create_success)
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

function renameDialog(file)--重命名对话框
  local ids={}
  local dia=AlertDialog.Builder(this)
  .setTitle(R.string.rename)
  .setView(MyEditDialogLayout.load(nil,ids))
  .setPositiveButton(R.string.rename,nil)
  .setNegativeButton(android.R.string.no,nil)
  .show()

  local edit,editLay=ids.edit,ids.editLay
  edit.requestFocus()--输入框取得焦点
  local fileName=file.getName()
  local parentFile=file.getParentFile()

  editLay.setHint(activity.getString(R.string.name))
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

  local function rename()
    local editLay=ids.editLay
    local edit=ids.edit

    xpcall(function()
      local err
      local newName=edit.text
      if newName=="" then--文件夹名不能为空
        editLay
        .setError(cannotBeEmptyStr)
        .setErrorEnabled(true)
        return
      end
      editLay.setErrorEnabled(false)
      local newFilePath=rel2AbsPath(newName,parentFile.getPath())
      local oldFilePath=file.getPath()
      local lowerOldFilePath=string.lower(oldFilePath)
      os.rename(oldFilePath, newFilePath)
      local tabTag=FilesTabList[lowerOldFilePath]
      if tabTag then
        local tab=tag.tab
        local newFile=File(newFilePath)
        local fileType=ProjectUtil.getFileTypeByName(newName)
        if string.lower(NowFile.getPath())==string.lower(newFilePath) then
          NowFile=newFile
          NowFileType=fileType
        end
        FilesTabList[string.lower(newFilePath)]=tabTag
        FilesTabList[lowerOldFilePath]=nil
        tabTag.fileType=fileType
        tabTag.file=newFile
        tabTag.shortFilePath=shortPath(newFilePath,true,ProjectsPath)
        tab.setText(newName)--设置显示的文字
        if oldTabIcon and notSafeModeEnable then
          tab.setIcon(ProjectUtil.getFileIconResIdByType(fileType))
        end
        initFileTabView(tab,tabTag)
      end

      showSnackBar(R.string.rename_success)
      refresh(parentFile)
      dia.dismiss()
    end,
    function(err)
      showErrorDialog(R.string.rename_fail,err)
    end)
  end
  dia.getButton(AlertDialog.BUTTON_POSITIVE).onClick=rename
  edit.onEditorAction=rename
  edit.text=fileName
  local _,splitEnd=utf8.find(fileName,".+%.")
  if splitEnd then
    splitEnd=splitEnd-1
  end
  edit.setSelection(0,splitEnd or utf8.len(fileName))
end