local RePackTool={}


function RePackTool.getMainProjectName(config)
  local firstInclude=config.include[1]
  return firstInclude:match("project:(.+)") or "app"
end

function RePackTool.buildLuaResources(config,projectPath,outputPath,update)
  --update(activity.getString(R.string.binpoject_creating_variables))
  local outputDir=File(outputPath)
  local luaLibsPaths={}
  local assetsPaths={}
  for index,content in ipairs(config.include) do
    local type_,name=content:match("(.-):(.+)")
    if type_=="project" then
      local libraryPath=("%s/%s"):format(projectPath,name)
      local luaPath=libraryPath.."/src/main/luaLibs"
      local assetsPath=libraryPath.."/src/main/assets_bin"
      local luaFile=File(luaPath)
      local assetsFile=File(assetsPath)
      if luaFile.isDirectory() then
        update("Found "..luaPath)
        table.insert(luaLibsPaths,luaFile)
      end
      if assetsFile.isDirectory() then
        update("Found "..assetsPath)
        table.insert(assetsPaths,assetsFile)
      end
    end
  end

  for index,content in ipairs(assetsPaths) do
    FileUtil.copyDir(content,File(outputPath.."/assets"))
    update("Copied "..content.getPath())
  end
  for index,content in ipairs(luaLibsPaths) do
    FileUtil.copyDir(content,File(outputPath.."/lua"))
    update("Copied "..content.getPath())
  end
end

return RePackTool
