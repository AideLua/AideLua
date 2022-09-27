local RePackTool={}
--import "versionsList"
local rePackToolList={
  --["1.0"]=true,
  ["1.1"]=true,
}
RePackTool.rePackToolList=rePackToolList

--通过config获取二次打包工具版本
function RePackTool.getRePackToolVerByConfig(config)
  if config.tool then
    return config.tool.version or "1.1"--没有版本，就默认为1.0
   else
    return "1.1"--没有就返回1.0，为了兼容旧版本工程
  end
end

--通过版本获取获取二次打包工具
function RePackTool.getRePackToolByVer(version)
  local rePackool=rePackToolList[version]
  if rePackool==true then
    rePackool=assert(loadfile(activity.getLuaPath("buildtools/RePackTool/RePackTool_"..version..".lua")))()
    --rePackool=require("buildtools.RePackTool.RePackTool_"..version)
    rePackToolList[version]=rePackool
    setmetatable(rePackool,{__index=RePackTool
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

--通过项目目录获取.aideLua路径
function RePackTool.getALPathByProjectPath(projectPath)
  return ("%s/.aidelua"):format(projectPath)
end

--通过.aideLua路径获取config.lua路径
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


local buildingDialog
local buildingDiaIds={}
local buildingAdapter
local buildingButtons={}
local function showBuildingDialog()
  table.clear(buildingDiaIds)
  buildingAdapter=LuaAdapter(activity,infoItem)
  buildingDialog=AlertDialog.Builder(this)
  .setTitle(R.string.binpoject_loading)
  .setView(loadlayout(buildingLayout,buildingDiaIds))
  .setPositiveButton(android.R.string.ok,nil)
  .setNegativeButton(android.R.string.cancel,nil)
  .setCancelable(false)
  .show()
  --buildingDiaIds.listView=buildingDialog.getListView()
  buildingDialog.getButton(AlertDialog.BUTTON_POSITIVE).setVisibility(View.GONE)
  buildingDialog.getButton(AlertDialog.BUTTON_NEGATIVE).setVisibility(View.GONE)
  buildingDiaIds.listView.setAdapter(buildingAdapter)

end

local repackApk_building=false
local function repackApk_taskFunc(config,projectPath,install,sign)
  return pcall(function()
    require "import"
    config=luajava.astable(config,true)
    notLoadTheme=true
    import "jesse205"
    import "android.content.pm.PackageManager"
    import "net.lingala.zip4j.ZipFile"
    import "apksigner.*"
    import "com.jesse205.util.FileUtil"
    RePackTool=require "buildtools.RePackTool"
    local rePackTool=RePackTool.getRePackToolByConfig(config)
    local binEventsList={}

    local function updateInfo(message)
      this.update("info")
      this.update(message)
    end
    local function updateDoing(message)
      this.update("doing")
      this.update(message)
    end

    local function updateSuccess(message)
      this.update("success")
      this.update(message)
    end

    local function updateError(message)
      this.update("error")
      this.update(message)
    end

    local function autoCompileLua(compileDir)
      for index,content in ipairs(luajava.astable(compileDir.listFiles())) do
        if content.isDirectory() then
          autoCompileLua(content)
         elseif content.name:find"%.lua$" then
          local path=content.getPath()
          local func,err=loadfile(path)
          if func then
            io.open(path,"w"):write(string.dump(func,true)):close()
           else
            updateError("Compilation failed "..err)
          end
          --updateInfo("Compiled "..path)
          func=nil
          path=nil
         elseif content.name:find"%.aly$" then
          local path=content.getPath()
          local func,err=loadfile(path)
          local path=path:match("(.+)%.aly")..".lua"
          if func then
            io.open(path,"w"):write(string.dump(func,true)):close()
           else
            updateError("Compilation failed "..err)
          end
          content.delete()
          --updateInfo("Compiled "..path)
          func=nil
          path=nil
         elseif content.name==".nomedia" then
          content.delete()
          updateInfo("Deleted "..content.getPath())
        end
      end
    end
    function runBinEvent(name,...)
      for index=1,#binEventsList do
        local binEvents=binEventsList[index]
        local event=binEvents[name]
        if event then
          event(...)
        end
      end
    end

    --this.update(activity.getString(R.string.binpoject_creating_variables))
    local mainAppPath=("%s/%s"):format(projectPath,rePackTool.getMainProjectName(config))
    local buildPath=mainAppPath.."/build"
    local binPath=buildPath.."/bin"
    local binDir=File(binPath)
    local tempPath=binPath.."/aidelua_unzip"
    local tempDir=File(tempPath)
    local appName,appVer,appApkPAI,appApkInfo
    local newApkName,newApkBaseName,newApkPath
    --开始查找app.apk
    local appPathList={
      config.appApkPath,
      --Gradle打包
      buildPath.."/outputs/apk/release/app-release-unsigned.apk",--正式版
      buildPath.."/outputs/apk/debug/app-debug.apk",
      --AIDE高级设置版打包
      binPath.."/app.apk",
      binPath.."/app-debug.apk",
      binPath.."/app-release.apk",
      binPath.."/generated.apk",
      binPath.."/signed.apk",
      --普通AIDE打包
      AppPath.Sdcard.."/Android/data/com.aide.ui/cache/apk/app.apk",
    }
    local appPath,appFile
    for index,content in pairs(appPathList) do
      if content then
        local file=File(content)
        if file.isFile() then
          appPath=content
          appFile=file
          break
        end
      end
    end
    if not(appPath) then
      return getString(R.string.binpoject_error_notfind)
    end

    --找到appPath，就告诉用户

    local packageManager=activity.getPackageManager()

    appApkPAI=packageManager.getPackageArchiveInfo(appPath, PackageManager.GET_ACTIVITIES)
    if appApkPAI then
      --可以解析安装包
      appApkInfo = appApkPAI.applicationInfo
      appName=config.appName or getString(android.R.string.unknownName)
      --appName=tostring(packageManager.getApplicationLabel(appApkInfo))
      appVer=config.versionName or appApkPAI.versionName

      local binEventsPaths={RePackTool.getALPathByProjectPath(projectPath).."/bin.lua"}
      for _type,path in rePackTool.getSubprojectPathIterator(config,projectPath) do
        if _type=="project" then
          table.insert(binEventsPaths,RePackTool.getALPathByProjectPath(path).."/bin.lua")
        end
      end
      for index=1,#binEventsPaths do
        local path=binEventsPaths[index]
        if File(path).isFile() then
          local success,binEvents=pcall(getConfigFromFile,path)
          if success then
            setmetatable(binEvents,{__index=_G})
            table.insert(binEventsList,binEvents)
           else
            updateError(binEvents)
          end
        end
      end
      binEventsPaths=nil
      --解压安装包
      updateDoing(formatResStr(R.string.binpoject_unzip,{appFile.getName()}))
      binDir.mkdirs()
      LuaUtil.rmDir(tempDir)
      LuaUtil.unZip(appPath,tempPath)
      updateSuccess(getString(R.string.binpoject_unzip_done))

      updateDoing(getString(R.string.binpoject_copying))
      rePackTool.buildLuaResources(config,projectPath,tempPath,updateInfo)
      updateSuccess(getString(R.string.binpoject_copy_done))

      --todo:编译Lua
      if config.compileLua~=false then
        updateDoing(getString(R.string.binpoject_compiling))
        autoCompileLua(tempDir)
        updateSuccess(getString(R.string.binpoject_compile_done))
      end


      --压缩
      newApkBaseName=appName.."_v"..appVer..os.date("_%Y%m%d%H%M%S")
      newApkName=newApkBaseName..".apk"
      newApkPath=binPath.."/"..newApkName
      updateDoing(formatResStr(R.string.binpoject_zip,{newApkName}))
      runBinEvent("beforePack",tempPath)
      LuaUtil.zip(tempPath,binPath,newApkName)
      updateSuccess(getString(R.string.binpoject_zip_done))


      updateDoing(getString(R.string.binpoject_deleting))
      LuaUtil.rmDir(tempDir)
      updateSuccess(getString(R.string.binpoject_delete_done))

      --签名
      if sign then
        local signSucceed,signErr
        local signedApkName=newApkBaseName.."_autosigned.apk"
        local signedApkPath=binPath.."/"..signedApkName
        if Signer then--有签名工具
          updateDoing(formatResStr(R.string.binpoject_signing,{signedApkName}))
          signSucceed,signErr=pcall(Signer.sign,newApkPath,signedApkPath)
          updateSuccess(getString(R.string.binpoject_sign_done))
        end
        if signSucceed then--没有签名成功
          File(newApkPath).delete()
          return true,signedApkPath,projectPath,install
         else
          return formatResStr(R.string.binpoject_error_signer,{newApkPath})
        end
       else
        return true,newApkPath,projectPath,false
      end
     else
      --无法解析安装包
      return formatResStr(R.string.binpoject_error_parse,{appFile.getName()})
    end
  end)
end

local lastMessage
--二次打包更新信息
local function repackApk_update(message,state)
  if lastMessage then
    local nowStatePanel=buildingDiaIds.nowStatePanel
    local icon,iconColor=0,0

    if lastMessage=="doing" then
      icon=R.drawable.ic_reload
      iconColor=theme.color.Blue
      buildingDiaIds.stateTextView.text=message
     elseif lastMessage=="info" then
      icon=R.drawable.ic_information_variant
      --iconColor=theme.color.Blue
     elseif lastMessage=="warning" then
      icon=R.drawable.ic_alert_outline
      iconColor=theme.color.Orange
     elseif lastMessage=="success" then
      icon=R.drawable.ic_check
      iconColor=theme.color.Green
      buildingDiaIds.stateTextView.text=message
     elseif lastMessage=="error" then
      icon=R.drawable.ic_close
      iconColor=theme.color.Red
    end
    buildingAdapter.add({stateTextView=message or "",icon={src=icon ,colorFilter=iconColor or 0}})
    if state==nil then
      nowStatePanel.setVisibility(View.VISIBLE)
      buildingDiaIds.stateTextView2.text=message
     elseif state then
      buildingDialog.setTitle(R.string.binpoject_state_succeed)
      nowStatePanel.setVisibility(View.GONE)
     else
      buildingDialog.setTitle(R.string.binpoject_state_failed)
      nowStatePanel.setVisibility(View.GONE)
    end
    buildingDiaIds.listView.setSelection(buildingAdapter.getCount()-1)

    lastMessage=nil
   else
    lastMessage=message
  end
end

--二次打包回调
local function repackApk_callback(success,message,apkPath,projectPath,install)
  --closeLoadingDia()
  repackApk_building=false
  local showingText=""
  local positiveButton=buildingDialog.getButton(AlertDialog.BUTTON_POSITIVE)
  local negativeButton=buildingDialog.getButton(AlertDialog.BUTTON_NEGATIVE)
  buildingDialog.setCancelable(true)
  if message==true then
    local shortApkPath=activity.getString(R.string.project).."/"..ProjectManager.shortPath(apkPath,true,projectPath)--转换成相对路径
    if install then
      showingText=formatResStr(R.string.binpoject_state_succeed_with_path,{shortApkPath})
      positiveButton.setVisibility(View.VISIBLE)
      negativeButton.setVisibility(View.VISIBLE)
      positiveButton.setText(R.string.install).onClick=function()
        activity.installApk(apkPath)
        --buildingDialog.dismiss()
      end
     else
      showingText=formatResStr(R.string.binpoject_state_succeed_with_path_needSign,{shortApkPath})
      positiveButton.setVisibility(View.VISIBLE)
    end
    repackApk_update("success")
    repackApk_update(showingText,true)
   else
    showingText=message or activity.getString(R.string.unknowError)
    repackApk_update("error")
    repackApk_update(showingText,false)
    positiveButton.setVisibility(View.VISIBLE)
    --buildingDialogBuilder.setPositiveButton(android.R.string.ok,nil).show()
  end
  if activityStopped then
    MyToast.showToast(showingText)
  end
end

function RePackTool.repackApk(config,projectPath,install,sign)
  if repackApk_building then
    MyToast.showToast(R.string.binpoject_loading)
   else
    showBuildingDialog()
    --showLoadingDia(nil,R.string.binpoject_loading)
    activity.newTask(repackApk_taskFunc,repackApk_update,repackApk_callback)
    .execute({config,projectPath,install,sign})
    repackApk_building=true
  end
end


return RePackTool