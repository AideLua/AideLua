require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "java.io.File"

import "themeutil"
themeutil.applyTheme()
import "res"

activity.setTitle("Project Runner")
activity.setContentView(loadlayout("layout"))

INFO_TAG="[INFO]"
ERROR_TAG="[ERROR]"
WARNING_TAG="[WARNING]"

local BACKUP_TIME=System.currentTimeMillis()
local inited=false
local started=false
--local restored=false
local recovering=false

--打印到屏幕
function printInScreen(...)
  local args=table.pack(...)
  for index=1,args.n do
    args[index]=tostring(args[index])
  end
  textView.text=textView.text..table.concat(args," ",1,args.n).."\n"
end

--恢复备份
function restoreBackup()
  recovering=true
  --恢复备份
  thread(function(initEnvFuncStr,BACKUP_TIME)
    assert(load(initEnvFuncStr))(BACKUP_TIME)
    printInScreen(INFO_TAG,"Exited the application, recovering the software environment")
    if File(backupMainDir).exists() then
      printInScreen(INFO_TAG,"Restoring backup:",backupMainDir)
      LuaUtil.rmDir(File(appMainDir))
      LuaUtil.copyDir(backupMainDir,appMainDir)
     else
      printInScreen(WARNING_TAG,"Unable to find backup:",backupLuaDir)
    end
    if File(backupLuaDir).exists() then
      printInScreen(INFO_TAG,"Restoring backup:",backupLuaDir)
      LuaUtil.rmDir(File(appLuaDir))
      LuaUtil.copyDir(backupLuaDir,appLuaDir)
     else
      printInScreen(WARNING_TAG,"Unable to find backup:",backupLuaDir)
    end
    --删除备份
    printInScreen(INFO_TAG,"Deleting backup:",backupDir)
    LuaUtil.rmDir(File(backupDir))
    printInScreen(INFO_TAG,"All done.")
    printInScreen(INFO_TAG,"This interface will be closed soon.")
    activity.finish()
  end,initEnvFuncStr,BACKUP_TIME)
end

function initEnv(BACKUP_TIME)
  require "import"
  import "android.app.*"
  import "android.os.*"
  import "java.io.File"
  INFO_TAG="[INFO]"
  ERROR_TAG="[ERROR]"
  WARNING_TAG="[WARNING]"
  packageName=activity.getPackageName()
  packageName=packageName
  sdCardPath=Environment.getExternalStorageDirectory().getPath()
  backupDir=sdCardPath.."/Android/media/"..packageName.."/.aidelua/importantTemp/envbackup/"..tostring(BACKUP_TIME)
  backupMainDir=backupDir.."/files"
  backupLuaDir=backupDir.."/app_lua"
  appMainDir="/data/data/"..packageName.."/files"
  appLuaDir="/data/data/"..packageName.."/app_lua"

  function printInScreen(...)
    local args=table.pack(...)
    for index=1,args.n do
      args[index]=tostring(args[index])
    end
    call("printInScreen",table.concat(args," ",1,args.n))
  end
end
initEnvFuncStr=string.dump(initEnv)

function startThread(func)
  thread(function(func)
    func()
  end,func)
end

function onError(...)
  printInScreen(ERROR_TAG,...)
  return true
end

function onCreate(savedInstanceState)
  thread(function(initEnvFuncStr,BACKUP_TIME)
    assert(load(initEnvFuncStr))(BACKUP_TIME)

    local path=sdCardPath.."/Android/media/"..packageName.."/cache/temp/debugApk"
    printInScreen(INFO_TAG,"Apk unzip path:",path)
    local newMainDir=path.."/assets"
    local newLuaDir=path.."/lua"

    if not File(newMainDir.."/main.lua").isFile() then
      return printInScreen(ERROR_TAG,"Lua file not found:",newMainDir.."/main.lua")
    end
    local backupDirFile=File(backupDir)
    if backupDirFile.exists() then
      printInScreen(INFO_TAG,"Deleting old backup:",backupDir)
      LuaUtil.rmDir(backupDirFile)
    end
    backupDirFile.mkdirs()
    --备份原文件
    printInScreen(INFO_TAG,"Backing:",appMainDir)
    LuaUtil.copyDir(appMainDir,backupMainDir)
    printInScreen(INFO_TAG,"Backing:",appLuaDir)
    LuaUtil.copyDir(appLuaDir,backupLuaDir)

    --复制新文件到环境内
    printInScreen(INFO_TAG,"Deleting:",appMainDir)
    LuaUtil.rmDir(File(appMainDir))
    printInScreen(INFO_TAG,"Applying:",newMainDir)
    LuaUtil.copyDir(newMainDir,appMainDir)

    printInScreen(INFO_TAG,"Deleting:",appLuaDir)
    LuaUtil.rmDir(File(appLuaDir))
    printInScreen(INFO_TAG,"Applying:",newLuaDir)
    LuaUtil.copyDir(newLuaDir,appLuaDir)

    call("onInited")
    printInScreen(INFO_TAG,"Starting lua activity")
    activity.newActivity(appMainDir.."/main.lua")
  end,initEnvFuncStr,BACKUP_TIME)
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    if not onKeyUp(KeyEvent.KEYCODE_BACK) then
      activity.finish()
    end
  end
end

function onStart()
  if not started then
    started=true
    return
  end
  if not inited then
    return
  end
  if recovering then
    return
  end
  restoreBackup()
end

function onKeyUp(keyCode, event)
  if keyCode==KeyEvent.KEYCODE_BACK then
    if not inited then
      print("Initializing, please do not exit.")
      return true
    end
    if not recovering then
      restoreBackup()
      return true
    end
  end
end

function onDestroy()
  if inited and not recovering then
    print("Abnormal exit, restoring backup.")
    restoreBackup()
   elseif not inited then
    print("Abnormal exit, your software may be damaged.")
  end
end

function onInited()
  inited=true
  actionBar.setDisplayHomeAsUpEnabled(true)
end

if themeutil.isJesse205Activity then--Jesse205主题没有分割线
  scrollView.onScrollChange=function(view,l,t,oldl,oldt)
    MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt,appBarLayout)
  end
end
