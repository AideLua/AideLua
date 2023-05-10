SP_STR = "---------------------------------------"
local virtualSharedData = {}
activity = {
    getSharedData = function(name)
        local result = virtualSharedData[name]
        print("调用getSharedData", "name = " .. tostring(name), "返回 = " .. tostring(result))
        return result
    end,
    setSharedData = function(name, value)
        print("调用setSharedData", "name = " .. tostring(name), "value = " .. tostring(value))
        virtualSharedData[name] = value
    end
}

getSharedData = activity.getSharedData
setSharedData = activity.setSharedData
