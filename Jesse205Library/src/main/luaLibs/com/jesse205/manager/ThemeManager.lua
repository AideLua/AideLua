--Lua专属ThemeManager
local ThemeManagerJ=luajava.bindClass(jesse205.LIBRARY_PACKAGE_NAME..".manager.ThemeManager")
local themeManagerJ=ThemeManagerJ(activity)
local ThemeManager={}
ThemeManager.THEME_TYPE=ThemeManagerJ.THEME_TYPE
ThemeManager.THEME_MATERIAL3=ThemeManagerJ.THEME_MATERIAL3
ThemeManager.THEME_DARK_ACTION_BAR=ThemeManagerJ.THEME_DARK_ACTION_BAR

function ThemeManager.applyTheme(isNoActionBar)
  themeManagerJ.applyTheme(isNoActionBar)
end

function ThemeManager.applyTheme(isNoActionBar)
  themeManagerJ.applyTheme(isNoActionBar)
end

function ThemeManager.getAppTheme()
  return ThemeManagerJ.getAppTheme(activity)
end

function ThemeManager.getAppDarkActionBarState()
  return ThemeManagerJ.getAppDarkActionBarState(activity)
end

function ThemeManager.checkThemeChanged()
  return themeManagerJ.checkThemeChanged()
end


return ThemeManager
