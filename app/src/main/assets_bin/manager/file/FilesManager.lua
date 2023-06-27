---文件管理器，管理已打开的文件
---@class FileManager
---@field nowFileConfig FileConfig 正在打开的文件配置
---@field openedState boolean 是否已打开了文件
local FilesManager = {}

---@class FileConfig 文件配置
---@param path string 文件路径
---@param name string 文件名称（包含扩展名）
---@param file File Java File 对象
---@param extensionName string 扩展名称（不包括“.”），如果未 nil 则不包含扩展名
---@param loader FileLoader 对应的文件加载器

---正在打开的文件配置
---@type FileConfig
local nowFileConfig

---是否已打开了文件
---@type boolean
local openedState = false

---初始化 FilesManager
function FilesManager.init()
end

---获取正在打开的文件配置
function FilesManager.getNowFileConfig()
    return nowFileConfig
end

---是否已打开了文件
---@return boolean openedState 文件打开状态(true=已打开、false=未打开)
function FilesManager.getOpenedState()
    return openedState
end

return createVirtualClass(FilesManager)
