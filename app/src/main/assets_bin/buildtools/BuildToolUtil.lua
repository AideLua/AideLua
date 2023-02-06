local BuildToolUtil={}
import "buildtools.BuildingDialogBuilder"
import "buildtools.RePackTool"
import "layouts.infoItem"
import "layouts.buildingLayout"

--打包对话框
BuildToolUtil.BuildDialog=BuildingDialogBuilder

--二次打包回调
local function repackApk_callback(buildingDialog,success,message,apkPath,projectPath,install,config,runMode)
  local dialog=buildingDialog.dialog
  local positiveButton=dialog.getButton(AlertDialog.BUTTON_POSITIVE)
  local negativeButton=dialog.getButton(AlertDialog.BUTTON_NEGATIVE)
  local showingText=""
  dialog.setCancelable(true)
  if message==true then
    local shortApkPath=rel2AbsPath(ProjectManager.shortPath(apkPath,true,projectPath),getString(R.string.project))--转换成相对路径
    if install then
      showingText=formatResStr(R.string.binproject_state_succeed_with_path,{shortApkPath})
      positiveButton.setVisibility(View.VISIBLE)
      negativeButton.setVisibility(View.VISIBLE)
      positiveButton.setText(R.string.install).onClick=function()
        activity.installApk(apkPath)
      end
     else
      showingText=formatResStr(R.string.binproject_state_succeed_with_path_needSign,{shortApkPath})
      positiveButton.setVisibility(View.VISIBLE)
    end
    buildingDialog:print("success",showingText,true)
    if runMode then
      buildingDialog.dialog.dismiss()
      --如果是运行模式，那么apkPath就是apk解包路径
      ProjectManager.runProject(apkPath.."/assets/main.lua",config)
    end
   else
    showingText=message or getString(R.string.unknowError)
    buildingDialog:print("error",showingText,false)
    positiveButton.setVisibility(View.VISIBLE)
  end
  if activityStopped then
    MyToast.showToast(showingText)
  end
end

--正在打包标识
local repackApk_building=false
---@param config table 工程配置
---@param projectPath string 工程路径
---@param install boolean 是否显示安装按钮
---@param sign boolean 是否签名
function BuildToolUtil.repackApk(config,projectPath,install,sign)
  if repackApk_building then
    MyToast.showToast(R.string.binproject_loading)
   else
    local buildingDialog=BuildingDialogBuilder()
    buildingDialog:show()

    activity.newTask(RePackTool.repackApk_taskFunc,function(...)
      buildingDialog:update(...)
    end,
    function(success,message,apkPath)
      repackApk_building=false
      repackApk_callback(buildingDialog,success,message,apkPath,projectPath,install,config,false)
    end)
    .execute({HashMap(config),projectPath,install,sign,false})
    repackApk_building=true
  end
end

function BuildToolUtil.runProject(config,projectPath)
  if repackApk_building then
    MyToast.showToast(R.string.binproject_loading)
   else
    local buildingDialog=BuildingDialogBuilder()
    buildingDialog:show()

    activity.newTask(RePackTool.repackApk_taskFunc,function(...)
      buildingDialog:update(...)
    end,
    function(success,message,apkPath)
      repackApk_building=false
      repackApk_callback(buildingDialog,success,message,apkPath,projectPath,false,config,true)
    end)
    .execute({HashMap(config),projectPath,false,false,true})
    repackApk_building=true
  end
end

return BuildToolUtil
