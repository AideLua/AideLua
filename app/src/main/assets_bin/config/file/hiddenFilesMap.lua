--v5.2.0+
---判断是否隐藏文件的字典
---@type table<string,boolean>
local hiddenFilesMap = {
    gradlew = true,
    ["gradlew.bat"] = true,
    ["luajava-license.txt"] = true,
    ["lua-license.txt"] = true,
    -- [".gitignore"] = true,
    gradle = true,
    build = true,
    ["init.lua"] = true,
    libs = true,
    cache = true,
    caches = true,
    wrapper = true
}
return hiddenFilesMap
