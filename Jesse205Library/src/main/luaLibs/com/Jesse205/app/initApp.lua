import "initApp"
local context=activity or service

if getSharedData("theme")==nil then--默认主题
  setSharedData("theme","Default")
end
if getSharedData("theme_darkactionbar")==nil then
  setSharedData("theme_darkactionbar",false)
end
