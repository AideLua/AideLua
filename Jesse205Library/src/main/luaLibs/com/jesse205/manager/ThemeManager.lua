local ThemeManager={}

function ThemeManager.applyTheme()
  local useCustomAppToolbar=useCustomAppToolbar or false
  local darkNavigationBar=useDarkNavigationBar or false
  local darkStatusBar=useDarkStatusBar or false
  local themeKey
  themeKey=getAppTheme()--获取当前设置的主题
  if not(supportedThemeName[themeKey]) then--主图里面没有，可能是废除了这个主题
    themeKey="Default"
    setAppTheme(themeKey)--自动设置会默认
  end

  --构建用的主题名字
  local themeString=("Theme_%s_%s"):format(jesse205.themeType,themeKey)
  if getSharedData("theme_darkactionbar") then--如果是暗色ActionBar
    themeString=themeString.."_DarkActionBar"
  end
  if useCustomAppToolbar then--使用自定义的ToolBar
    themeString=themeString.."_NoActionBar"
  end

  activity.setTheme(R.style[themeString])--设置主题
  themeString=nil

  local systemUiVisibility=0
  decorView=activity.getDecorView()--定要在设置主题之后调用
  local colorList=theme.color

  if not(useCustomAppToolbar) then
    local actionBar=activity.getSupportActionBar()
    _G.actionBar=actionBar
    actionBar.setElevation(0)--关闭ActionBar阴影
  end

  if isGrayNavigationBarSystem() then
    ThemeUtil.setNavigationbarColor(res.theme.color.attr.windowBackgroundColor)
  end

  if res.boolean.attr.windowLightNavigationBar and SDK_INT>=26 and not(darkNavigationBar) then--主题默认亮色导航栏
    systemUiVisibility=systemUiVisibility|View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR--设置亮色导航栏
  end

  if res.boolean.attr.windowLightStatusBar and SDK_INT >= 23 and not(darkStatusBar) then--默认是亮色状态栏并且不低于安卓6
    systemUiVisibility=systemUiVisibility|View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
  end

  decorView.setSystemUiVisibility(systemUiVisibility)
end


return ThemeManager
