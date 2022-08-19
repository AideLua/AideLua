--检查是不是路径相同的文件
function isSamePathFileByPath(filePath1,filePath2)--通过文件路径
  return string.lower(filePath1)==string.lower(filePath2)
end
function isSamePathFile(file1,file2)--通过文件本身
  return isSamePathFileByPath(file1.getPath(),file2.getPath())
end
function createVirtualClass(normalTable)
  local smartTable={}
  local metatable={__index=function(self,key)
      if normalTable[key] then
        return normalTable[key]
       else
        local getter="get"..key:gsub("^%l",string.upper)
        if normalTable[getter] then
          return normalTable[getter]()
        end
      end
  end}
  setmetatable(smartTable,metatable)
  return smartTable,metatable
end

function runLuaFile(file,code)
  if file and file.isFile() then
    newActivity(file.getPath())
   else
    newSubActivity("RunCode",{code})
  end
end

--自动识别显示toast的方式进行显示
function showSnackBar(text)
  if drawer.isDrawerOpen(Gravity.LEFT) then
    return MyToast(text,mainLay)
   else
    return MyToast(text,editorGroup)
  end
end

function isBinaryFile(filePath)
  local ioFile = io.open(filePath, "r")
  if ioFile then
    local code=ioFile:read("*all")
    ioFile:close()
    if code~="" then
      local c=string.byte(code)
      if c <= 0x1c and c>= 0x1a and c~=" " and c~="\t" then
        return true
      end
    end
    return code
   else
    return nil
  end
end

function safeCloneTable(oldTable,newTable)
  for index,content in pairs(oldTable) do
    if newTable[index]==nil then
      newTable[index]=oldTable[index]
    end
  end
end


--刷新Menu状态
function refreshMenusState()
  if LoadedMenu then
    local fileOpenState,projectOpenState=FilesTabManager.openState,ProjectManager.openState
    local menus={
      {StateByFileMenus,fileOpenState},
      {StateByProjectMenus,projectOpenState},
      {StateByFileAndEditorMenus,fileOpenState and IsEdtor},
      {StateByEditorMenus,IsEdtor},
    }
    for index,content in pairs(menus)do
      for index,menu in ipairs(content[1]) do
        menu.setEnabled(toboolean(content[2]))
      end
    end

    PluginsUtil.callElevents("refreshMenusState")
  end
end


--用外部应用打开文件
function openFileITPS(path)
  import "android.webkit.MimeTypeMap"
  --import "android.content.Intent"
  --import "android.net.Uri"
  --import "java.io.File"
  local file=File(path)
  local name=file.getName()
  local extensionName=ProjectUtil.getFileTypeByName(name)
  local mime=MimeTypeMap.getSingleton().getMimeTypeFromExtension(extensionName)
  if mime then
    local intent=Intent()
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.setAction(Intent.ACTION_VIEW)
    intent.setType(mime)
    intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    --intent.putExtra(Intent.EXTRA_STREAM, activity.getUriForFile(file))
    intent.setDataAndType(activity.getUriForFile(file),mime)
    activity.startActivity(Intent.createChooser(intent,name))
  end
end

WindmillTools={
  手册=2,
  ["Java API"]=3,
  ["Http 调试"]=4,
}

function startWindmillActivity(toolName)
  local success=pcall(function()
    local uri = Uri.parse("wm://tool:"..WindmillTools[toolName])
    local intent = Intent(Intent.ACTION_VIEW, uri)
    activity.startActivity(intent)
  end)
  if not(success) then
    openUrl("https://www.coolapk.com/apk/com.agyer.windmill")
  end
end

--公共Activity
local sharedActivityPath=AppPath.Sdcard.."/Android/media/%s/.aidelua/activities/%s"

function updateSharedActivity(name,sdActivityDir)
  LuaUtil.copyDir(File(activity.getLuaDir("sub/"..name)),sdActivityDir)
end

function checkSharedActivity(name,packageName)
  local sdActivityPath=sharedActivityPath:format(packageName,name)--AppPath.AppShareCacheDir.."/activities/"..name
  local sdActivityMainPath=sdActivityPath.."/main.lua"
  local sdActivityDir=File(sdActivityPath)
  local sdActivityMainFile=File(sdActivityMainPath)
  local exists=sdActivityDir.exists()
  local mainExists=sdActivityMainFile.isFile()
  if not(mainExists) or getSharedData("sharedactivity_"..name)~=lastUpdateTime then
    if exists then
      LuaUtil.rmDir(sdActivityDir)
    end
    updateSharedActivity(name,sdActivityDir)
  end
  return sdActivityMainPath
end

function refreshSubTitle()
  if ProjectManager.openState then
    local appName=ProjectManager.nowConfig.appName
    if ScreenWidthDp then
      if ScreenWidthDp<360 then
        actionBar.setSubtitle(appName)
       elseif ScreenWidthDp<380 then
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_360dp,{appName}))
       elseif ScreenWidthDp<390 then
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_380dp,{appName}))
       else
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_390dp,{appName}))
      end
     else
      actionBar.setSubtitle(appName)
    end
   else
    actionBar.setSubtitle(R.string.project_no_open)
  end
end


function getFileTypeByName(name)
  local _type=name:match(".+%.(.+)")
  if _type then
    return string.lower(_type)
  end
end



function screenToViewX(_textField,x)
  return x-_textField.getPaddingLeft()+_textField.getScrollX()
end
function screenToViewY(_textField,y)
  return y-_textField.getPaddingTop()+_textField.getScrollY()
end

function isNearChar(bounds,x,y)
  local TOUCH_SLOP=12
  return (y >= (bounds.top - TOUCH_SLOP)
  and y < (bounds.bottom + TOUCH_SLOP*2)
  and x >= (bounds.left - TOUCH_SLOP)
  and x < (bounds.right + TOUCH_SLOP))
end

function isNearChar2(relativeCaretX,relativeCaretY,x,y)
  local TOUCH_SLOP=EditorsManager.editor.getTextSize()+10
  --print(TOUCH_SLOP)
  return (y >= (relativeCaretY - TOUCH_SLOP)
  and y < (relativeCaretY + TOUCH_SLOP+100)
  and x >= (relativeCaretX - TOUCH_SLOP-40)
  and x < (relativeCaretX + TOUCH_SLOP+40))
end

local _clipboardActionMode=nil
function onEditorSelectionChangedListener(view,status,start,end_)
  if not(_clipboardActionMode) and status and not(Searching) then
    local actionMode=luajava.new(ActionMode.Callback,
    {
      onCreateActionMode=function(mode,menu)
        _clipboardActionMode=mode
        mode.setTitle(android.R.string.selectTextMode)

        local inflater=mode.getMenuInflater()
        inflater.inflate(R.menu.menu_editor,menu)
        return true
      end,
      onActionItemClicked=function(mode,item)
        local id=item.getItemId()
        if id==R.id.menu_selectAll then
          view.selectAll()
         elseif id==R.id.menu_cut then
          view.cut()
         elseif id==R.id.menu_copy then
          view.copy()
         elseif id==R.id.menu_paste then
          view.paste()
         elseif id==R.id.menu_code_commented then
          EditorsManager.actions.commented(view)
         elseif id==R.id.menu_code_viewApi then
          local selectedText=view.getSelectedText()
          newSubActivity("JavaApi",{selectedText})
        end
        return false;
      end,
      onDestroyActionMode=function(mode)
        view.selectText(false)
        --print("取消选择失败")
        _clipboardActionMode=nil
      end,
    })
    activity.startSupportActionMode(actionMode)
   elseif _clipboardActionMode and not(status) then
    _clipboardActionMode.finish()
    _clipboardActionMode=nil
  end
end





