local CreateFileHelper = {}
setmetatable(CreateFileHelper, CreateFileHelper)
local metatable = { __index = CreateFileHelper }

function CreateFileHelper.__call(self)
    local self = {}
    setmetatable(self, metatable)
end

function CreateFileHelper.init()
    --TODO: 添加支持解析器
end

return CreateFileHelper
