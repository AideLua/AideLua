local ThemeUtilJava=luajava.bindClass(jesse205.LIBRARY_PACKAGE_NAME..".util.ThemeUtil")
local context=jesse205.context
local ThemeUtil={}

---判断是否是系统夜间模式
---@return boolean 是否开启了夜间模式
function ThemeUtil.isSysNightMode()
  return ThemeUtilJava.isSystemNightMode(context)
end
ThemeUtil.isNightMode=ThemeUtil.isSysNightMode


return ThemeUtil
