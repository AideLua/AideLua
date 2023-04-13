return {
    {
        name = "None",
        type = "none",
        description = "No files opened",
        layout = "layout.editor.none",
        locale = {
            zh = {
                name = "空",
                description = "未打开文件"
            }
        },
    },
    {
        name = "Lua Editor",
        type = "lua_editor",
        description = "AndroLua+ Editor",
        layout = "layout.editor.luaEditor",
        locale = {
            zh = {
                name = "Lua 编辑器",
                description = "AndroLua+ 自带编辑器"
            }
        },
        onInit = function(self, viewsMap)
            --TODO: 初始化 Lua 编辑器
        end,
        onOpenFile = function(self, viewsMap, fileCfg)
            --TODO: 使用安全的方法读取文件
            print("file: " .. dump(fileCfg))
            local editor = viewsMap.editor
        end,
        onSaveFile = function(self, viewsMap, fileCfg)
            --TODO: 使用安全的方法保存文件
            local editor = viewsMap.editor
            FilesManager.saveTextFile(fileCfg)
        end,
        onTypefaceChange = function(self, viewsMap, typeface, boldTypeface, italicTypeface)
            ---@type LuaEditor
            local editor = viewsMap.editor
            editor.setTypeface(typeface)
            editor.setBoldTypeface(boldTypeface)
            editor.setItalicTypeface(italicTypeface)
        end,
    },
    {
        name = "Sora Code Editor",
        type = "sora_editor",
        description = "Sora Code Editor",
        locale = {
            zh = {
                name = "Sora 代码编辑器",
                description = "Sora 代码编辑器"
            }
        },
    },
    {
        name = "Layout Viewer",
        type = "layout_viewer",
        description = "Layout Viewer",
        locale = {
            zh = {
                name = "布局查看器",
                description = "布局查看器"
            }
        },
    },
    {
        name = "Image Viewer",
        type = "image_viewer",
        description = "Image Viewer",
        locale = {
            zh = {
                name = "图片查看器",
                description = "图片查看器"
            }
        },
    },
    {
        name = "HTML Viewer",
        type = "html_viewer",
        description = "HTML Viewer",
        locale = {
            zh = {
                name = "HTML 查看器",
                description = "HTML 查看器"
            }
        },
    }
}
