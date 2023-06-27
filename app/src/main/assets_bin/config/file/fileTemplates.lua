---@class FileTemplateItem
---@param name string 模板名称
---@param enabledKey string 用于检测是否启用的标识符
---@param id string 唯一标识符，也用于给模板排序

return {
    {
        name = "Lua 表 (Table)",
        enName = "Lua Table",
        id = "lua_table",
        extensionName = "aly",
        content = [[{

}]],
    },

    {
        name = "Lua 模块 (Module)",
        enName = "Lua Module",
        id = "lua_module",
        extensionName = "lua",
        content = [[local {{ShoredModuleName}}={}
setmetatable({{ShoredModuleName}},{{ShoredModuleName}})
local metatable={__index={{ShoredModuleName}}}

function {{ShoredModuleName}}.__call(self)
  local self={}
  setmetatable(self,metatable)
  return self
end
return {{ShoredModuleName}}
]],
    },

    {
        name = "空 Lua 文件",
        enName = "Empty Lua File",
        id = "lua_empty",
        extensionName = "lua",
        content = "",
    },

    {
        name = "空文件",
        enName = "Empty File",
        id = "empty_file",
        extensionName = "txt",
        content = "",
    },

}
