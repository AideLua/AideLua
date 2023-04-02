---加载lua语法的配置文件
---@param luaPath string 文件路径
---@param configTable table 加载到的 table，默认为空
local function loadluaconfig(luaPath,configTable)
  configTable=configTable or {}
  assert(loadfile(tostring(luaPath),"bt",configTable))()
  return configTable
end
return loadluaconfig