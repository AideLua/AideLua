local ThemeUtil={}
setmetatable(ThemeUtil,ThemeUtil)
local metatable={__index=ThemeUtil}

function ThemeUtil.__call(self)
  local self={}
  setmetatable(self,metatable)
end
return ThemeUtil
