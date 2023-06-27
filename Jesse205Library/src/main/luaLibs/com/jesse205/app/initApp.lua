import "com.jesse205.manager.DefaultSettingsManager"
local context = jesse205.context

local defaultSettingsManager = DefaultSettingsManager()
jesse205.defaultSettingsManager = defaultSettingsManager
defaultSettingsManager:addData(require("com.jesse205.config.defaultSettings"))

require "initApp"

defaultSettingsManager.checkAndApplyData()
