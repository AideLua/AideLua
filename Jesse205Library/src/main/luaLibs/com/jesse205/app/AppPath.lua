local Environment=luajava.bindClass("android.os.Environment")
local LuaUtil=luajava.bindClass("com.androlua.LuaUtil")
local File=luajava.bindClass("java.io.File")
local context=jesse205.context
local packageName=context.getPackageName()

local sdcardPath=Environment.getExternalStorageDirectory().getPath()--SD卡的目录

--将默认目录设为“/sdcard/Android/data/Package Name/files”
local sdcardDataDirPath="Android/data/"..packageName
context.setLuaExtDir(sdcardDataDirPath.."/files")
local dataDirPath="/data/data/"..packageName
sdcardDataDirPath=sdcardPath.."/"..sdcardDataDirPath
local mediaDirPath=sdcardPath.."/Android/media/"..packageName--共享文件夹

local _M={}

local function getAppPublicPath(name)--获取自身公共路径
  return sdcardPath.."/"..name.."/Edde software/"..jesse205.appName
end

_M.Sdcard=sdcardPath

_M.Temp=context.getLuaExtDir("temp")--临时目录

_M.Downloads=getAppPublicPath("Downloads")
_M.Movies=getAppPublicPath("Movies")
_M.Pictures=getAppPublicPath("Pictures")
_M.Music=getAppPublicPath("Music")

_M.LuaDir=context.getLuaDir()
_M.AppMediaDir=mediaDirPath.."/files"
_M.AppDataDir=dataDirPath.."/files"
_M.AppSdcardDataDir=sdcardDataDirPath.."/files"

_M.AppMediaCacheDir=mediaDirPath.."/cache"
_M.AppDataCacheDir=dataDirPath.."/cache"
_M.AppSdcardDataCacheDir=sdcardDataDirPath.."/cache"

_M.AppMediaTempDir=mediaDirPath.."/cache/temp"
_M.AppDataTempDir=dataDirPath.."/cache/temp"
_M.AppSdcardDataTempDir=sdcardDataDirPath.."/cache/temp"

function _M.cleanTemp()
  LuaUtil.rmDir(File(_M.AppMediaTempDir))
  LuaUtil.rmDir(File(_M.AppDataTempDir))
  LuaUtil.rmDir(File(_M.AppSdcardDataTempDir))
end

return _M