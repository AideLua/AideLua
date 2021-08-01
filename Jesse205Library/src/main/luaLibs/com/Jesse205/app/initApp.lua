import "initApp"
local context=activity or service

if getSharedData("theme")==nil then
  setSharedData("theme","Default")
end
if getSharedData("theme_type")==nil then
  setSharedData("theme_type","Jesse205")
end
if getSharedData("theme_darkactionbar")==nil then
  setSharedData("theme_darkactionbar",false)
end