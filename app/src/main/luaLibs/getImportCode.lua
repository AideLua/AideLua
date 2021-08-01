local function getImportCode(className)
  return string.format("import \"%s\"",className)
end
return getImportCode