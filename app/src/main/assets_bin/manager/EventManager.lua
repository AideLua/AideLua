---事件管理器
---TODO: 实现
local EventManager = {}

---@type function[]
local eventList = {}

---提交事件
---@param func function
function EventManager.push(func)
    table.insert(eventList, func)
end

function EventManager.handleEvents(func)
    
end

return EventManager
