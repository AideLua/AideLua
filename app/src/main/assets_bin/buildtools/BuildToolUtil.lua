local BuildToolUtil={}
import "buildtools.BuildingDialogBuilder"
import "buildtools.RePackTool"
import "layouts.infoItem"
import "layouts.buildingLayout"

--打包对话框
BuildToolUtil.BuildDialog=BuildingDialogBuilder

--二次打包回调
local function repackApk_callback(buildingDialog,success,message,apkPath,projectPath,install)
  local dialog=buildingDialog.dialog
  local positiveButton=dialog.getButton(AlertDialog.BUTTON_POSITIVE)
  local negativeButton=dialog.getButton(AlertDialog.BUTTON_NEGATIVE)
  local showingText=""
  dialog.setCancelable(true)
  if message==true then
    local shortApkPath=getString(R.string.project).."/"..ProjectManager.shortPath(apkPath,true,projectPath)--转换成相对路径
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
    buildingDialog:update("success")
    buildingDialog:update(showingText,true)
   else
    showingText=message or getString(R.string.unknowError)
    buildingDialog:update("error")
    buildingDialog:update(showingText,false)
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
      repackApk_callback(buildingDialog,success,message,apkPath,projectPath,install)
    end)
    .execute({HashMap(config),projectPath,install,sign})
    repackApk_building=true
  end
end

function BuildToolUtil.runProject(config)

end

return BuildToolUtil
