os.execute("@chcp 65001")
package.path = package.path .. ";Jesse205Library\\src\\main\\luaLibs\\?.lua;"

require "Jesse205Library.test.env"


local DefaultSettingsManager = require "com.jesse205.manager.DefaultSettingsManager"

local defaultSettings = require "com.jesse205.config.defaultSettings"
local mData = {
    boolTest = true,
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
print("获取 theme_darkactionbar", defaultData.theme_darkactionbar, false)
print("获取 boolTest", defaultData.boolTest, true)
print("获取 stringTest", defaultData.stringTest, "hello")
print("获取 numberTest", defaultData.numberTest, 123456)
print("获取 functionTest", defaultData.functionTest, os.time())

print(SP_STR)

print("设置默认选项")
defaultSettingsManager:checkAndApplyData()

print(SP_STR)
print("再次设置默认选项，期望只有调用getSharedData")
defaultSettingsManager:checkAndApplyData()
print("设置结束")
