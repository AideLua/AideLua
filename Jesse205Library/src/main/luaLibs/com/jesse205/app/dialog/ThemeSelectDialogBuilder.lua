import "com.google.android.material.dialog.MaterialAlertDialogBuilder"

local ThemeSelectDialogBuilder={}
setmetatable(ThemeSelectDialogBuilder,ThemeSelectDialogBuilder)
local metatable={__index=ThemeSelectDialogBuilder}

function ThemeSelectDialogBuilder.__call(self,context)
  local self={}
  setmetatable(self,metatable)
  self.context=context
end

function ThemeSelectDialogBuilder:show()
  local dialog=MaterialAlertDialogBuilder(self.context)
  self.dialog=dialog
  dialog.show()
  return self
end


return ThemeSelectDialogBuilder
