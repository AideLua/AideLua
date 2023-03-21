local test={}
setmetatable(test,test)
local metatable={__index=test}

function test.__call(self)
  local self={}
  setmetatable(self,metatable)
end
return test
