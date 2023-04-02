local install={}
setmetatable(install,install)
local metatable={__index=install}

function install.__call(self)
  local self={}
  setmetatable(self,metatable)
end
return install
