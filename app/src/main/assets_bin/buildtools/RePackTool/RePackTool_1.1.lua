local RePackTool={}

function RePackTool.buildProject(config,projectPath,outputPath)
end

function RePackTool.getMainProjectName(config)
  local firstInclude=config.include[1]
  return firstInclude:match("project:(.+)") or "app"
end

return RePackTool
