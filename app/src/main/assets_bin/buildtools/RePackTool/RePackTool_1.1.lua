local RePackTool={}


function RePackTool.getMainProjectName(config)
  local firstInclude=config.include[1]
  return firstInclude:match("project:(.+)") or "app"
end

function RePackTool.getSubprojectPathIterator(config,projectPath)
  local index=1
  local include=config.include or {}
  return function()
    local content=include[index]
    if content then
      index=index+1
      local _type,name=content:match("(.-):(.+)")
      if _type=="project" then
        return _type,projectPath.."/"..name
      end
    end
  end
end

function RePackTool.buildLuaResources(config,projectPath,outputPath,update)
  local outputDir=File(outputPath)
  local luaLibsPaths={}
  local assetsPaths={}
  for _type,libraryPath in RePackTool.getSubprojectPathIterator(config,projectPath) do
    if _type=="project" then
      --local libraryPath=("%s/%s"):format(projectPath,name)
      local luaPath=libraryPath.."/src/main/luaLibs"
      local assetsPath=libraryPath.."/src/main/assets_bin"
      local luaFile=File(luaPath)
      local assetsFile=File(assetsPath)
      if luaFile.isDirectory() then
        --update("Found "..luaPath)
        table.insert(luaLibsPaths,luaFile)
      end
      if assetsFile.isDirectory() then
        --update("Found "..assetsPath)
        table.insert(assetsPaths,assetsFile)
      end
    end
  end

  for index,content in ipairs(assetsPaths) do
    FileUtil.copyDir(content,File(outputPath.."/assets"))
    --update("Copied "..content.getPath())
  end
  for index,content in ipairs(luaLibsPaths) do
    FileUtil.copyDir(content,File(outputPath.."/lua"))
    --update("Copied "..content.getPath())
  end
end

return RePackTool
