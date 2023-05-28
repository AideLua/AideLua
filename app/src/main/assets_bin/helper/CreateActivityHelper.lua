local CreateActivityHelper = {}
setmetatable(CreateActivityHelper, CreateActivityHelper)
local metatable = { __index = CreateActivityHelper }

function CreateActivityHelper.__call(self)
    local self = {}
    setmetatable(self, metatable)
end

return CreateActivityHelper
