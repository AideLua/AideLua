-- 文件读取保存相关工具
---@type table<string,table<string,function>>
return {
    text = {
        ---读取文件
        ---@param filePath 文件路径
        ---@return boolean state 成功加载
        ---@return string content 文件内容
        readFile = function(filePath)
            local content = isBinaryFile(filePath)
            if content == true then
                return nil, getString(R.string.file_cannot_open_compiled_file)
            end
            return true, content
        end,
        saveFile = function(filePath, content)
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
    --TODO: 支持json对象加载
    --TODO: 支持glide加载
}
