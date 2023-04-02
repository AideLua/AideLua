local CreateFileHelper={}
setmetatable(CreateFileHelper,CreateFileHelper)
local metatable={__index=CreateFileHelper}

function CreateFileHelper.__call(self)
  local self={}
  setmetatable(self,metatable)
end
return CreateFileHelper
