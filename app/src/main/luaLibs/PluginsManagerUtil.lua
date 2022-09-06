local PluginsManagerUtil={}
local getAlpInfo,install

function getAlpInfo(path)
  local config = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", config)()
  return config
end
PluginsManagerUtil.getAlpInfo=getAlpInfo


function install(path,uri,config,callback)
  local mode=config.mode
  if mode=="plugin" or mode==nil then
    local packageName=config.packagename
    local message = string.format("名称: %s\
版本: %s\
包名: %s\
作者: %s\
说明: %s\
路径: %s",
    config.appname,
    config.appver,
    packageName,
    config.developer,
    config.description,
    uri)
    AlertDialog.Builder(this)
    .setTitle(R.string.plugins_install)
    .setMessage(message)
    .setPositiveButton(R.string.install,function()
      local extractPath=PluginsUtil.getPluginPath(packageName)
      local extractDir=File(extractPath)
      local zipFile=ZipFile(path)
      if zipFile.isValidZipFile() then
        if extractDir.exists() then--已经安装过，就需要删除旧文件
          LuaUtil.rmDir(extractDir)
        end
        zipFile.extractAll(extractPath)
        callback("success")
       else
        callback("failed")
      end
    end)
    .setNegativeButton(android.R.string.cancel,nil)
    .show()
   else
    callback("failed")
  end
end
PluginsManagerUtil.install=install

function PluginsManagerUtil.installByUri(uri,callback)
  local scheme=uri.getScheme()
  local path
  if scheme=="content" then
    local inputStream=activity.getContentResolver().openInputStream(uri)
    path=AppPath.AppSdcardCacheDataDir.."/"..System.currentTimeMillis()..".zip"
    local outputStream=FileOutputStream(path)
    LuaUtil.copyFile(inputStream,outputStream)
   else
    return
  end
  local success,config=pcall(getAlpInfo,path)
  if success then--读取成功
    install(path,uri,config,callback)
   else--读取失败
    showErrorDialog(R.string.open_failed,config)
  end
end

function PluginsManagerUtil.uninstall(path,config,callback)
  local dir=File(path)
  local dirName=dir.getName()
  AlertDialog.Builder(this)
  .setTitle(formatResStr(R.string.uninstall_withName,{config.appname or dirName}))
  .setMessage(R.string.plugins_uninstall_warning)
  .setPositiveButton(R.string.uninstall,function()
    --local path=PluginsUtil.getPluginPath(config.packagename)
    if dir.exists() then
      LuaUtil.rmDir(dir)
      LuaUtil.rmDir(File(PluginsUtil.getPluginDataPath(dirName)))
      PluginsUtil.setEnabled(dirName,nil)
      callback("success")
     else
      callback("failed")
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()

end
return PluginsManagerUtil
