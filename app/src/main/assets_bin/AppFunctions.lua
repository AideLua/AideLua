--此文件内为此页面的部分函数
--检查是不是路径相同的文件
function isSamePathFileByPath(filePath1,filePath2)--通过文件路径
  return string.lower(filePath1)==string.lower(filePath2)
end
function isSamePathFile(file1,file2)--通过文件本身
  return isSamePathFileByPath(file1.getPath(),file2.getPath())
end
function createVirtualClass(normalTable)
  local smartTable={}
  local metatable={
    __index=function(self,key)
      if normalTable[key] then
        return normalTable[key]
       else
        local getter="get"..key:gsub("^%l",string.upper)
        if normalTable[getter] then
          return normalTable[getter]()
        end
      end
    end,
    __newindex=function(self,key,value)
      normalTable[key]=value
    end
  }
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
  if FilesBrowserManager.openState and nowDevice ~= "pc" then
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
    local isEditor=EditorsManager.checkEditorSupport("getText")
    local menus={
      {StateByFileMenus,fileOpenState},
      {StateByProjectMenus,projectOpenState},
      {StateByFileAndEditorMenus,fileOpenState and isEditor},
      {StateByEditorMenus,isEditor},
      {StateByNotBadPrjMenus,not(projectOpenState and ProjectManager.nowConfig.badPrj)}
    }
    for index,content in pairs(menus)do
      for index,menu in ipairs(content[1]) do
        menu.setEnabled(toboolean(content[2]))
      end
    end
    PluginsUtil.callElevents("refreshMenusState")
  end
end

function refreshMagnifier()
  editor_magnify = getSharedData("editor_magnify")

  if not(magnifier) and editor_magnify then
    pcall(function()--放大镜
      import "android.widget.Magnifier"
      magnifier=Magnifier(editorGroup)
      magnifierUpdateTi=Ticker()--放大镜的定时器，定时刷新放大镜
      magnifierUpdateTi.setPeriod(200)
      magnifierUpdateTi.onTick=function()
        magnifier.update()
      end
      magnifierUpdateTi.setEnabled(false)--先禁用放大镜
    end)
  end
end


local MyMimeMap={
  lua="text/plain",
}
--用外部应用打开文件
function openFileITPS(path)
  import "android.webkit.MimeTypeMap"
  local file=File(path)
  local name=file.getName()
  local extensionName=getFileTypeByName(name)
  local mime=MyMimeMap[extensionName] or MimeTypeMap.getSingleton().getMimeTypeFromExtension(extensionName) or "*/"
  if mime then
    local intent=Intent()
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.setAction(Intent.ACTION_VIEW)
    intent.setType(mime)
    intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    --intent.putExtra(Intent.EXTRA_STREAM, activity.getUriForFile(file))
    intent.setData(activity.getUriForFile(file))
    if mime=="*/" then
      activity.startActivity(Intent.createChooser(intent,name))
     else
      activity.startActivity(intent)
    end
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

function refreshSubTitle(newScreenWidthDp)
  if ProjectManager.openState then
    local appName=ProjectManager.nowConfig.appName
    if screenWidthDp then
      if screenWidthDp<360 then
        actionBar.setSubtitle(appName)
       elseif screenWidthDp<380 then
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_360dp,{appName}))
       elseif screenWidthDp<390 then
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

function fixLT(list)
  local lTList={}
  for index=1,#list do
    local view=list[index]
    lTList[index]=view.getLayoutTransition()
    view.setLayoutTransition(nil)
    --print(view)
  end
  return function()
    for index=1,#list do
      list[index].setLayoutTransition(lTList[index])
    end
    list=nil
    lTList=nil
  end
end

function addStrToTable(text,list,checkList)
  if not(checkList[text]) then
    table.insert(list,text)
    checkList[text]=true
  end
end

function getFilePathCopyMenus(inLibDirPath,filePath,fileName,isFile,fileType)
  local textList={}
  local textCheckList={}
  if inLibDirPath then
    addStrToTable(inLibDirPath,textList,textCheckList)
    local callLibPath=inLibDirPath
    if inLibDirPath:find("/") then
      callLibPath=inLibDirPath:gsub("/",".")
      addStrToTable(callLibPath,textList,textCheckList)
    end
    if fileType=="aly" or fileType=="lua" or fileType=="java" or fileType=="kt" or File(filePath.."/init.lua").isFile() then
      addStrToTable(getImportCode(callLibPath),textList,textCheckList)
    end

   else
    addStrToTable(fileName,textList,textCheckList)
  end
  return textList
end

--这是去除./和../的
function fixPath(path)
  path=path.."/"
  path=path:gsub("//","/")
  path=path:gsub("/%./","/")
  local newPath=path:gsub("[^/]-/%.%./","",1)--这么写是为了更快
  while path~=newPath do
    --print(path)
    path=newPath
    newPath=path:gsub("[^/]-/%.%./","",1)
  end
  return path:match("(.*)/")
end
