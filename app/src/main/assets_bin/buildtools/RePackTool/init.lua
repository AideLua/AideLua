local RePackTool={}
--import "versionsList"
local rePackToolList={
  ["1.0"]=true,
  ["1.1"]=true,
}
RePackTool.rePackToolList=rePackToolList

--通过config获取二次打包工具版本
function RePackTool.getRePackToolVerByConfig(config)
  if config.tool then
    return config.tool.version or "1.0"--没有版本，就默认为1.0
   else
    return "1.0"--没有就返回1.0，为了兼容旧版本工程
  end
end

--通过版本获取获取二次打包工具
function RePackTool.getRePackToolByVer(version)
  local rePackool=rePackToolList[version]
  if rePackool==true then
    rePackool=assert(loadfile(activity.getLuaPath("buildtools/RePackTool/RePackTool_"..version..".lua")))()
    --rePackool=require("buildtools.RePackTool.RePackTool_"..version)
    rePackToolList[version]=rePackool
    setmetatable(rePackool,{__index=function(self,key)--设置环境变量
        return RePackTool[key]
      end
    })
   elseif rePackool==nil then
    error(activity.getString(R.string.binpoject_cannotFindTool))
  end
  return rePackool
end

--通过Config获取获取二次打包工具
function RePackTool.getRePackToolByConfig(config)
  local toolVersion=RePackTool.getRePackToolVerByConfig(config)
  local rePackool=RePackTool.getRePackToolByVer(toolVersion)
  return rePackool
end

--通过项目目录获取.AideLua路径
function RePackTool.getALPathByProjectPath(projectPath)
  return ("%s/.aidelua"):format(projectPath)
end

--通过.AideLua路径获取config.lua路径
function RePackTool.getConfigPathByALPath(aideluaPath)
  return ("%s/config.lua"):format(aideluaPath)
end

--通过项目目录路径获取config
function RePackTool.getConfigByProjectPath(projectPath)
  local aideluaPath=RePackTool.getALPathByProjectPath(projectPath)
  local path=RePackTool.getConfigPathByALPath(aideluaPath)
  return getConfigFromFile(path)
end

--通过项目名字获取主项目路径
function RePackTool.getProjectDir(projectDir,name)
  return ("%s/%s/src/main"):format(projectDir,name)
end

--通过Config和RePackTool获取主项目路径
function RePackTool.getMainProjectDirByConfigAndRePackTool(projectDir,config,rePackTool)
  return RePackTool.getProjectDir(projectDir,rePackTool.getMainProjectName(config))
end
--二次打包更新信息
local function repackApk_update(message)
  showLoadingDia(message)
end


--二次打包回调
local function repackApk_callback(success,apkPath,projectDir,install)
  closeLoadingDia()
  local showingText=""
  if success==true then
    local shortApkPath=activity.getString(R.string.project)..ProjectUtil.shortPath(apkPath,true,projectDir)--转换成相对路径
    if install then
      activity.installApk(apkPath)
      showingText=formatResStr(R.string.binpoject_state_succeed,{shortApkPath})
     else
      showingText=formatResStr(R.string.binpoject_state_succeed_needSign,{shortApkPath})
    end
    showSnackBar(showingText)
   else
    showingText=success or activity.getString(R.string.unknowError)
    AlertDialog.Builder(this)
    .setTitle(activity.getString(R.string.binpoject_state_failed))
    .setMessage(showingText)
    .setPositiveButton(android.R.string.ok,nil)
    .show()
  end
  if activityStopped then
    MyToast.showToast(showingText)
  end
end


function RePackTool.repackApk(config,projectDir,install)
  local rePackTool=RePackTool.getRePackToolByConfig(config)
end


return RePackTool