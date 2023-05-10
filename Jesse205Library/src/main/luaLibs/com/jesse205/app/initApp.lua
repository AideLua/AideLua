import "com.jesse205.manager.DefaultSettingsManager"
local context = jesse205.context

if getSharedData("theme_darkactionbar") == nil then
  setSharedData("theme_darkactionbar", false)
end

local defaultSettingsManager = DefaultSettingsManager()
jesse205.defaultSettingsManager = defaultSettingsManager
defaultSettingsManager:addData(require("com.jesse205.config.defaultSettings"))

require "initApp"

defaultSettingsManager.checkAndApplyData()
