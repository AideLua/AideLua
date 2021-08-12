import "initApp"
local context=activity or service

if getSharedData("theme")==nil then--默认主题
  setSharedData("theme","Default")
end
if getSharedData("theme_type")==nil then--主题类型，可以使用在style.xml可以继承Jesse205主题
  setSharedData("theme_type","Jesse205")
end
if getSharedData("theme_darkactionbar")==nil then
  setSharedData("theme_darkactionbar",false)
end