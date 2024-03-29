---v5.1.1+

import "layouts.infoItem"
import "layouts.buildingLayout"

local BuildingDialogBuilder={}

setmetatable(BuildingDialogBuilder,BuildingDialogBuilder)
local buildingDialogBuilderMetatable={__index=BuildingDialogBuilder}

--@param context Context v5.1.2+
function BuildingDialogBuilder.__call(class,context)
  local self={}
  self.context=context--v5.1.2+
  self.dialogIds={}
  setmetatable(self,buildingDialogBuilderMetatable)
  return self
end

function BuildingDialogBuilder:setTitle(text)
  self.title=text
  return self
end

function BuildingDialogBuilder:update(message,state)--state主要用来检验是否构建完成
  local lastMessage=self.lastMessage
  local dialogIds=self.dialogIds
  local adapter=self.adapter
  local dialog=self.dialog
  if lastMessage then
    self:print(lastMessage,message)
    dialogIds.listView.setSelection(adapter.getCount()-1)
    self.lastMessage=nil
   else
    self.lastMessage=message--update一次只能传一个参数，所以要第一次更新图标，第二次更新文字
  end
end

---v5.1.1+ 新增state
function BuildingDialogBuilder:print(iconName,message,state)
  local adapter=self.adapter
  local dialogIds=self.dialogIds
  local nowStatePanel=dialogIds.nowStatePanel
  local dialog=self.dialog

  local icon,iconColor=0,0--设置图标及颜色
  if iconName=="doing" then
    icon=R.drawable.ic_reload
    iconColor=res.color.jesse205_blue
  elseif iconName=="info" then
    icon=R.drawable.ic_information_variant
  elseif iconName=="success" then
    icon=R.drawable.ic_check
    iconColor=res.color.jesse205_teal
  elseif iconName=="error" then
    icon=R.drawable.ic_close
    iconColor=res.color.jesse205_red
  else
    error("Unknow icon:"..iconName)
  end

  adapter.add({stateTextView=message or "",icon={src=icon ,colorFilter=iconColor}})

  dialogIds.stateTextView2.text=message
  if iconName=="doing" then
    dialogIds.stateTextView.text=message
    dialogIds.stateTextView2.setVisibility(View.GONE)
   else
    dialogIds.stateTextView2.setVisibility(View.VISIBLE)
  end
  dialogIds.listView.setSelection(adapter.getCount()-1)
  if state then
    dialog.setTitle(R.string.binproject_state_succeed)
    nowStatePanel.setVisibility(View.GONE)
   elseif state==false then
    dialog.setTitle(R.string.binproject_state_failed)
    nowStatePanel.setVisibility(View.GONE)
  end

end

function BuildingDialogBuilder:show()
  local dialogIds=self.dialogIds
  table.clear(dialogIds)
  local adapter=LuaAdapter(activity,infoItem)
  local dialog=MaterialAlertDialogBuilder(self.context)
  .setTitle(self.title or R.string.binproject_loading)
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

return BuildingDialogBuilder
