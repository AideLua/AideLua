-- 文件读取保存相关工具
return {
    text = {
        readFile = function(filePath)
            local content = isBinaryFile(filePath)
            if content == true then
                return nil, getString(R.string.file_cannot_open_compiled_file)
            end
            return content
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
            local file = io.open(path, "w")
            if file then
                return pcall(function()
                    file:write(content):close()
                end)
            else
                return true, getString(R.string.file_not_find)--文件未找到是正常情况
            end
        end
    }
}
