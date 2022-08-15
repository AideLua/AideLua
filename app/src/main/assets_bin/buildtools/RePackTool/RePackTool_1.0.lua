local RePackTool={}
function RePackTool.getMainProjectName(config)
  return config.main or "app"
end

return RePackTool
