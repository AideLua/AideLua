---@class FileLoader 文件加载器
---@param readFile fun(filePath: string):boolean, any openState, content
---@param saveFile fun(filePath: string, content: any):boolean, string|nil savwState, errorText

---@alias FileLoaderType string

---文件读取保存相关工具
---@type table<FileLoaderType,FileLoader>
return {
    ---@class TextFileLoader: FileLoader
    text = {
        ---读取文件
        ---@param self TextFileLoader
        ---@param filePath 文件路径
        ---@return boolean state 成功加载
        ---@return string content 文件内容
        readFile = function(self, filePath)
            local content = isBinaryFile(filePath)
            if content == true then
                return nil, getString(R.string.file_cannot_open_compiled_file)
            end
            return true, content
        end,
        ---写入文件
        ---@param self TextFileLoader
        saveFile = function(self, filePath, content)
            -- 自动备份
            if getSharedData("editor_autoBackupOriginalFiles") then
                FilesTabManager.backupDir.mkdirs()
                local backupFilePath = FilesTabManager.backupPath .. "/" ..
                    System.currentTimeMillis() .. "_" ..
                    File(path).getName()
                os.rename(path, backupFilePath)
            end
            local file = io.open(filePath, "w")
            if file then
                return pcall(function()
                    file:write(content):close()
                end)
            else
                return true, getString(R.string.file_not_find) --文件未找到是正常情况
            end
        end
    },
    image = {
        --TODO: 支持glide加载
        readFile = function(self, filePath)
        end,
        saveFile = function(self, filePath, content)
        end
    }
    --TODO: 支持json对象加载

}
