local Environment=luajava.bindClass("android.os.Environment")
local LuaUtil=luajava.bindClass("com.androlua.LuaUtil")
local File=luajava.bindClass("java.io.File")
local context=jesse205.context
local packageName=jesse205.packageName

local sdcardPath=Environment.getExternalStorageDirectory().getPath()--SD卡的目录

--将默认目录设为“/sdcard/Android/data/Package Name/files”
local sdcardDataDirPath="Android/data/"..packageName
context.setLuaExtDir(sdcardDataDirPath.."/files")
local dataDirPath="/data/data/"..packageName
sdcardDataDirPath=sdcardPath.."/"..sdcardDataDirPath

local mediaDirPaths=context.getExternalMediaDirs()
local mediaDirPath=mediaDirPaths and #mediaDirPaths>0 and mediaDirPaths[0].toString() or nil

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
local filesDir=context.getFilesDir()
_M.AppDataDir=filesDir and filesDir.toString() or nil
_M.AppSdcardDataDir=sdcardDataDirPath.."/files"

--缓存
_M.AppMediaCacheDir=mediaDirPath.."/cache"
local cacheDir=context.getCacheDir()
_M.AppDataCacheDir=cacheDir and cacheDir.toString() or nil
local externalCacheDir=context.getExternalCacheDir()
_M.AppSdcardDataCacheDir=externalCacheDir and externalCacheDir.toString() or nil


--临时文件
_M.AppMediaTempDir=_M.AppMediaCacheDir.."/temp"
_M.AppDataTempDir=_M.AppDataCacheDir.."/temp"
_M.AppSdcardDataTempDir=_M.AppSdcardDataCacheDir.."/temp"

function _M.cleanTemp()
  LuaUtil.rmDir(File(_M.AppMediaTempDir))
  LuaUtil.rmDir(File(_M.AppDataTempDir))
  LuaUtil.rmDir(File(_M.AppSdcardDataTempDir))
end

return _M