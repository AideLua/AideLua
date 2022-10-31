import "java.io.FileOutputStream"

local PluginsManagerUtil={}
local getAlpInfo,showInstallDialog
local PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)
local versionCode=PackInfo.versionCode

function getAlpInfo(path)
  local config = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", config)()
  return config
end
PluginsManagerUtil.getAlpInfo=getAlpInfo


function showInstallDialog(path,uri,config,callback)
  local mode=config.mode
  if mode=="plugin" or mode==nil then
    local packageName=config.packagename
    local message = string.format("名称: %s\
版本: %s\
包名: %s\
作者: %s\
说明: %s\
URI: %s",
    config.appname,
    config.appver,
    packageName,
    config.developer,
    config.description,
    uri)
    local supported=config.supported2
    local waringId
    if supported then--插件指定了受支持的应用
      local limitVersion=supported[apptype]
      if limitVersion then--支持此应用
        if limitVersion.targetcode<versionCode then
          waringId=R.string.plugins_warning_update
        end
       else--不支持此应用
        waringId=R.string.plugins_error_unsupported
      end
     else--没有指定，则显示警告
      waringId=R.string.plugins_warning_supported
    end
    if waringId then
      message=message.."\n\n"..getString(waringId)
    end
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
PluginsManagerUtil.showInstallDialog=showInstallDialog

function PluginsManagerUtil.installByUri(uri,callback)
  local scheme=uri.getScheme()
  local path
  if scheme=="content" then
    local inputStream=activity.getContentResolver().openInputStream(uri)
    path=AppPath.AppSdcardDataTempDir.."/"..System.currentTimeMillis()..".zip"
    File(AppPath.AppSdcardDataTempDir).mkdirs()
    local outputStream=FileOutputStream(path)
    LuaUtil.copyFile(inputStream,outputStream)
   else
    return
  end
  local success,config=pcall(getAlpInfo,path)
  if success then--读取成功
    local supported=config.supported2
    if supported then
      local limitVersion=supported[apptype]
      if limitVersion then--支持此APP
        if limitVersion.mincode>versionCode then--在最低版本之上
          showErrorDialog(R.string.plugins_error_update_app)
         else
          showInstallDialog(path,uri,config,callback)
        end
       else
        showErrorDialog(R.string.plugins_error_unsupported)
      end
     else
      showInstallDialog(path,uri,config,callback)
    end
   else--读取失败
    showErrorDialog(R.string.open_failed,config)
  end
end

--[[PluginsManagerUtil.uninstall(path, {appname="AppName"},function(state)
  if state=="success" then
    elseif state=="failed" then
  end
end)]]
function PluginsManagerUtil.uninstall(path,config,callback)
  local dir=File(path)
  local dirName=dir.getName()
  AlertDialog.Builder(this)
  .setTitle(formatResStr(R.string.uninstall_withName,{config.appname or dirName}))
  .setMessage(R.string.plugins_uninstall_warning)
  .setPositiveButton(R.string.uninstall,function()
    if dir.exists() then--判断一下插件是否存在
      LuaUtil.rmDir(dir)--移除插件
      LuaUtil.rmDir(File(PluginsUtil.getPluginDataPath(dirName)))--移除数据
      PluginsUtil.setEnabled(dirName,nil)--移除启用状态
      callback("success")
     else
      callback("failed")
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()

end
return PluginsManagerUtil
