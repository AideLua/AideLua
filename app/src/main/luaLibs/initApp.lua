import "android.os.Build"
import "android.os.Environment"

local defaultSettingsManager = jesse205.defaultSettingsManager
defaultSettingsManager:addData(require("config.defaultSettings"))
--脚本运行成功后会自动设置偏好
