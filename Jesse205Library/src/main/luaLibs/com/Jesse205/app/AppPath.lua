--import "android.os.Environment"
local AppPath={}
local context=activity or service

--将默认目录设为“/sdcard/Android/data/Package Name/files”
local extDir=("Android/data/%s/files"):format(context.getPackageName())
context.setLuaExtDir(extDir)

--软件名
local appName
appName=application.get("appName")
if appName==nil then
  appName=context.getApplicationInfo().loadLabel(context.getPackageManager())
  application.set("appName",appName)
end

AppPath.Sdcard=Environment.getExternalStorageDirectory().getPath()--在SD卡中的目录
AppPath.Temp=context.getLuaExtDir("temp")--临时目录

local function getSelfPublicPath(value)
  return Environment.getExternalStoragePublicDirectory(value).getPath().."/Edde software/"..appName
end

AppPath.Downloads=getSelfPublicPath(Environment.DIRECTORY_DOWNLOADS)
AppPath.Movies=getSelfPublicPath(Environment.DIRECTORY_MOVIES)
AppPath.Pictures=getSelfPublicPath(Environment.DIRECTORY_PICTURES)
AppPath.Music=getSelfPublicPath(Environment.DIRECTORY_MUSIC)


AppPath.LuaDir=context.getLuaDir()
AppPath.LuaExtDir=extDir
AppPath.LuaSharedDir=AppPath.Downloads.."/.shared"--共享文件夹
AppPath.AppSdcardDataDir=AppPath.LuaExtDir

return AppPath