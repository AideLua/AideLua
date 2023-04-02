---@deprecated
print("getImportCode.lua","已废弃，请使用","CodeHelper")
local function getImportCode(className)
  print("getImportCode","已废弃，请使用","CodeHelper.getImportCode")
  return string.format("import \"%s\"",className)
end
return getImportCode