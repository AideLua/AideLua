--import "android.os.Environment"
local AppPath={}
local context=activity or service

--将默认目录设为“/sdcard/Android/data/Package Name/files”
context.setLuaExtDir(("Android/data/%s/files"):format(context.getPackageName()))

--软件名
local appName=context.getApplicationInfo().loadLabel(context.getPackageManager())
--AppPath.Data=Environment.getDataDirectory().getPath()
AppPath.Sdcard=Environment.getExternalStorageDirectory().getPath()--在SD卡中的目录
AppPath.Temp=context.getLuaExtDir("temp")--临时目录

local function getSelfPublicPath(value)
  return Environment.getExternalStoragePublicDirectory(value).getPath().."/"..appName
end

AppPath.Downloads=getSelfPublicPath(Environment.DIRECTORY_DOWNLOADS)
AppPath.Movies=getSelfPublicPath(Environment.DIRECTORY_MOVIES)
AppPath.Pictures=getSelfPublicPath(Environment.DIRECTORY_PICTURES)
AppPath.Music=getSelfPublicPath(Environment.DIRECTORY_MUSIC)


AppPath.LuaDir=context.getLuaDir()
AppPath.LuaExtDir=context.getLuaExtDir()
AppPath.AppSdcardDataDir=AppPath.LuaExtDir

return AppPath