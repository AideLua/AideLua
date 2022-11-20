local BuildToolUtil={}
import "buildtools.RePackTool"
import "layouts.infoItem"
import "layouts.buildingLayout"

--打包对话框
local BuildingDialog={}
BuildToolUtil.BuildDialog=BuildingDialog
setmetatable(BuildingDialog,BuildingDialog)
local buildingDialogBuilderMetatable={__index=BuildingDialog}

function BuildingDialog.__call(class)
  local self={}
  self.dialogIds={}
  setmetatable(self,buildingDialogBuilderMetatable)
  return self
end

function BuildingDialog:update(message,state)--state主要用来检验是否构建完成
  local lastMessage=self.lastMessage
  local dialogIds=self.dialogIds
  local adapter=self.adapter
  local dialog=self.dialog
  if lastMessage then
    local nowStatePanel=dialogIds.nowStatePanel
    local icon,iconColor=0,0--设置图标及颜色
    if lastMessage=="doing" then--正在
      icon=R.drawable.ic_reload
      iconColor=theme.color.Blue
     elseif lastMessage=="info" then--信息
      icon=R.drawable.ic_information_variant
      --iconColor=theme.color.Blue
     elseif lastMessage=="warning" then--警告
      icon=R.drawable.ic_alert_outline
      iconColor=theme.color.Orange
     elseif lastMessage=="success" then--成功
      icon=R.drawable.ic_check
      iconColor=theme.color.Green
      dialogIds.stateTextView.text=message
     elseif lastMessage=="error" then--错误
      icon=R.drawable.ic_close
      iconColor=theme.color.Red
    end
    adapter.add({stateTextView=message or "",icon={src=icon ,colorFilter=iconColor or 0}})
    if state==nil then
      nowStatePanel.setVisibility(View.VISIBLE)
      dialogIds.stateTextView2.text=message
      if lastMessage=="doing" then
        dialogIds.stateTextView.text=message
        dialogIds.stateTextView2.setVisibility(View.GONE)
       else
        dialogIds.stateTextView2.setVisibility(View.VISIBLE)
      end
     elseif state then
      dialog.setTitle(R.string.binpoject_state_succeed)
      nowStatePanel.setVisibility(View.GONE)
     else
      dialog.setTitle(R.string.binpoject_state_failed)
      nowStatePanel.setVisibility(View.GONE)
    end
    dialogIds.listView.setSelection(adapter.getCount()-1)
    self.lastMessage=nil
   else
    self.lastMessage=message
  end
end

function BuildingDialog:show()
  local dialogIds=self.dialogIds
  table.clear(dialogIds)
  local adapter=LuaAdapter(activity,infoItem)
  local dialog=AlertDialog.Builder(this)
  .setTitle(R.string.binpoject_loading)
  .setView(loadlayout(buildingLayout,dialogIds))
  .setPositiveButton(android.R.string.ok,nil)
  .setNegativeButton(android.R.string.cancel,nil)
  .setCancelable(false)
  .show()
  self.adapter=adapter
  self.dialog=dialog
  dialog.getButton(AlertDialog.BUTTON_POSITIVE).setVisibility(View.GONE)
  dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setVisibility(View.GONE)
  dialogIds.listView.setAdapter(adapter)
end


--二次打包回调
local function repackApk_callback(buildingDialog,success,message,apkPath,projectPath,install)
  local dialog=buildingDialog.dialog

  local showingText=""
  local positiveButton=dialog.getButton(AlertDialog.BUTTON_POSITIVE)
  local negativeButton=dialog.getButton(AlertDialog.BUTTON_NEGATIVE)
  dialog.setCancelable(true)
  if message==true then
    local shortApkPath=activity.getString(R.string.project).."/"..ProjectManager.shortPath(apkPath,true,projectPath)--转换成相对路径
    if install then
      showingText=formatResStr(R.string.binpoject_state_succeed_with_path,{shortApkPath})
      positiveButton.setVisibility(View.VISIBLE)
      negativeButton.setVisibility(View.VISIBLE)
      positiveButton.setText(R.string.install).onClick=function()
        activity.installApk(apkPath)
      end
     else
      showingText=formatResStr(R.string.binpoject_state_succeed_with_path_needSign,{shortApkPath})
      positiveButton.setVisibility(View.VISIBLE)
    end
    buildingDialog:update("success")
    buildingDialog:update(showingText,true)
   else
    showingText=message or activity.getString(R.string.unknowError)
    buildingDialog:update("error")
    buildingDialog:update(showingText,false)
    positiveButton.setVisibility(View.VISIBLE)
  end
  if activityStopped then
    MyToast.showToast(showingText)
  end
end


local repackApk_building=false
function BuildToolUtil.repackApk(config,projectPath,install,sign)
  if repackApk_building then
    MyToast.showToast(R.string.binpoject_loading)
   else
    local buildingDialog=BuildingDialog()
    buildingDialog:show()
    activity.newTask(RePackTool.repackApk_taskFunc,function(...)
      buildingDialog:update(...)
    end,
    function(success,message,apkPath)
      repackApk_building=false
      repackApk_callback(buildingDialog,success,message,apkPath,projectPath,install)
    end)
    .execute({config,projectPath,install,sign})

    repackApk_building=true
  end
end

return BuildToolUtil
