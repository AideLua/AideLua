return {
    {
        name = "None",                   --名称
        type = "none",                   --类型，不可重复
        description = "No files opened", --简介
        layout = "layout.editor.none",   --布局文件
        locale =                         --本地化信息
        {
            zh = {
                name = "空",
                description = "未打开文件"
            }
        }
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
            --TODO: 使用安全的公共方法读取文件
            print("file: " .. dump(fileCfg))
            local editor = viewsMap.editor
        end,
        ---文件保存时
        onSaveFile = function(self, viewsMap, fileCfg)
            --TODO: 使用安全的方法公共方法保存文件
            local editor = viewsMap.editor
            FilesManager.saveTextFile(fileCfg)
        end,
        ---字体改变时
        onTypefaceChange = function(self, viewsMap, typeface, boldTypeface, italicTypeface)
            ---@type LuaEditor
            local editor = viewsMap.editor
            editor.setTypeface(typeface)
            editor.setBoldTypeface(boldTypeface)
            editor.setItalicTypeface(italicTypeface)
        end,
        ---模板解析时
        onDecodeSupport = function(self, viewsMap)

        end,
        supportedFiles = { "lua", "aly" }
    },
    {
        name = "Sora Code Editor",
        type = "sora_editor",
        description = "Sora Code Editor",
        locale = {
            zh = {
                name = "Sora 代码编辑器",
                description = "查看与编写代码"
            }
        },
        supportedFiles = {
            -- Lua
            "lua",
            "aly",
            -- Java
            "java",
            "kt",
            -- 网页
            "js",
            "ts",
            "css",
            "scss",
            "less",
            -- 文档
            "md",
            "markdown",
            "txt",
            -- 数据存储
            "json",
            "xml",
            "ini"
        }
    },
    {
        name = "Layout Viewer",
        type = "layout_viewer",
        description = "Layout Viewer",
        locale = {
            zh = {
                name = "布局查看器",
                description = "查看 Lua 布局"
            }
        }
    },
    {
        name = "Image Viewer",
        type = "image_viewer",
        description = "Image Viewer",
        locale = {
            zh = {
                name = "图片查看器",
                description = "查看 PNG、JPG 等类型的图片"
            }
        }
    },
    {
        name = "Web Viewer",
        type = "web_viewer",
        description = "HTML Viewer",
        locale = {
            zh = {
                name = "网页浏览器",
                description = "查看 HTML、SVG，预览视频和音频"
            }
        }
    },
    {
        name = "Markdown Viewer",
        type = "markdown_viewer",
        description = "View Markdown file",
        locale = {
            zh = {
                name = "Markdown 查看器",
                description = "查看 Markdown 文件"
            }
        }
    }
}
