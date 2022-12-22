local SubActivityUtil={}
---在 v5.1.1(51199) 添加

local BASE_DIR_PATH="%s/%s/src/main/assets_bin/%s"
local DIR_NAMES={"sub","subActivity","subActivities","activity","activities"}

function SubActivityUtil.getDirPath()
  local basePath
  local mainModule
  local dirName
  return BASE_DIR_PATH:format(basePath,mainModule,dirName)
end

function SubActivityUtil.showCreateActivityDialog()

end

return SubActivityUtil
