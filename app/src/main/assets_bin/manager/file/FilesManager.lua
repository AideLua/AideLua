--v5.2.0+
---文件管理器，管理已打开的文件
local FilesManager = {}
local nowFileConfig

function FilesManager.init()
end

function FilesManager.getNowFileConfig()
    return nowFileConfig
end

return createVirtualClass(FilesManager)
