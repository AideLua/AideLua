---默认设置管理器<br>
---使用前需要初始化<br>
---DefaultSettingsManager()
---@class DefaultSettingsManager
---@field private _originDataMap table 原始数据表
---@field public data table 数据表，自动编译原始数据表
local DefaultSettingsManager = {}
setmetatable(DefaultSettingsManager, DefaultSettingsManager)
local metatable = { __index = DefaultSettingsManager }

--用于获取默认值的 Metatable
local dataGetterMetatable = {
    __index = function(self, key)
        local originDataMap = rawget(self, "_originDataMap")
        local value = originDataMap[key]
        if value then
            local _type = type(value)
            if _type == "function" then --如果值是一个函数，那么需要执行这个函数，以获取真实的值
                value = value()
            end
            rawset(self, key, value)
        end
        return value
    end
}

---@return DefaultSettingsManager
function DefaultSettingsManager.__call(class)
    local self = {}
    ---原始数据表
    local originDataMap = {}
    --原始数据字典
    self._originDataMap = originDataMap
    --允许开发者访问的data，通过metatable自动自动判断，返回真实的数据
    self.data = { _originDataMap = originDataMap }
    setmetatable(self.data, dataGetterMetatable)
    setmetatable(self, metatable)
    return self
end

---添加数据
---@param dataMap table<string,any>
---@return DefaultSettingsManager
function DefaultSettingsManager:addData(dataMap)
    local originDataMap = self._originDataMap
    assert(originDataMap)
    for key, value in pairs(dataMap) do
        originDataMap[key] = value
    end
    return self
end

---检查并应用到全局设置
function DefaultSettingsManager:checkAndApplyData()
    local originDataMap = self._originDataMap
    local data = self.data
    for key, value in pairs(originDataMap) do
        local oldData = getSharedData(key)
        if oldData == nil then
            setSharedData(key, data[key]) --这里需要编译一下
        end
    end
end

return DefaultSettingsManager
