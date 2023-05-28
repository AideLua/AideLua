return {
    noneConfig = {
        --未打开文件时显示的编辑器
        noneEditor = "none",
        runCode = {
            defaultEditor = "lua_editor",
            defaultContent = [[

            ]]
        }
    },
    fileConfigs = {
        lua = {
            defaultEditor = "lua_editor"
        },
        aly = {
            super = "lua"
        },
    }
}
