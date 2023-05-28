require "Jesse205Library.test.env"


local DefaultSettingsManager = require "com.jesse205.manager.DefaultSettingsManager"

local defaultSettings = require "com.jesse205.config.defaultSettings"
local mData = {
    booleanTest = true,
    stringTest = "hello",
    numberTest = 123456,
    functionTest = function()
        return os.time()
    end
}

--初始化类
defaultSettingsManager = DefaultSettingsManager()
defaultSettingsManager:addData(defaultSettings)
defaultSettingsManager:addData(mData)
--获取数据表
local defaultData = defaultSettingsManager.data
print("名称", "测试值", "期望值")
print("获取 theme_style", defaultData.theme_style, "Material2")
print("获取 booleanTest", defaultData.booleanTest, true)
print("获取 stringTest", defaultData.stringTest, "hello")
print("获取 numberTest", defaultData.numberTest, 123456)
print("获取 functionTest", defaultData.functionTest, os.time())

print(SP_STR)

print("设置默认选项")
clearPrintedStr()
defaultSettingsManager:checkAndApplyData()

if not getPrinted():find("调用getSharedData.-调用setSharedData") then
    error("验证失败")
end

print(SP_STR)
print("再次设置默认选项，期望只有调用getSharedData")
clearPrintedStr()
defaultSettingsManager:checkAndApplyData()
print("设置结束")

if getPrinted():find("setSharedData") then
    error("验证失败")
end
