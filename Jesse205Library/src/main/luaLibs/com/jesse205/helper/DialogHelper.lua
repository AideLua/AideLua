---对话框辅助模块
local DialogHelper={}

function DialogHelper.enableTextIsSelectable(dialog)
  local textView = dialog.findViewById(android.R.id.message)
  textView.setTextIsSelectable(true)
end

return DialogHelper
