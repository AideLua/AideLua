local themeutil={}
themeutil._VERSION="1.0"
themeutil._DESCRIPTION="一个简单方便的工具&主题库"

--Jesse205活动
---@type boolean
themeutil.isJesse205Activity=pcall(function()
  import "jesse205"
end)

--AndroidX活动
---@type boolean
themeutil.isSupportActivity=pcall(function()
  androidx={appcompat={R=luajava.bindClass("androidx.appcompat.R")}}
  if not(luajava.instanceof(this,luajava.bindClass("androidx.appcompat.app.AppCompatActivity"))) then
    error()
  end
end)

---EMUI系统
---@type boolean
themeutil.isEmuiSystem=pcall(function()
  androidhwext={R=luajava.bindClass("androidhwext.R")}
end)

function toboolean(content)
  if content then
    return true
   else
    return false
  end
end

local dp2intCache={}
function math.dp2int(dpValue)
  local cache=dp2intCache[dpValue]
  if cache then
    return cache
   else
    import "android.util.TypedValue"
    local cache=TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue, activity.resources.getDisplayMetrics())
    dp2intCache[dpValue]=cache
    return cache
  end
end

function themeutil.setTheme(success,func)
  if not(success) then
    success=pcall(func)
  end
  return toboolean(success)
end

function themeutil.getActionBarState()
  local array = activity.getTheme().obtainStyledAttributes({
    android.R.attr.windowActionBar
  })
  local windowActionBar=array.getBoolean(0,false)
  array.recycle()
  return windowActionBar
end

function themeutil.getSupportActionBarState()
  local array = activity.getTheme().obtainStyledAttributes({
    androidx.appcompat.R.attr.windowActionBar
  })
  local windowActionBar=array.getBoolean(0,false)
  array.recycle()
  return windowActionBar
end

---设置主题
function themeutil.applyTheme()
  if not(themeutil.isJesse205Activity) then
    local success=false
    if themeutil.isSupportActivity then
      success=themeutil.setTheme(themeutil.getSupportActionBarState(),function()
        activity.setTheme(androidx.appcompat.R.style.Theme_AppCompat_DayNight)
      end)
      actionBar=activity.getSupportActionBar()
     else
      themeutil.setTheme(themeutil.getActionBarState(),function()
        success=themeutil.setTheme(success,function()
          activity.setTheme(androidhwext.R.style.Theme_Emui)
        end)
        success=themeutil.setTheme(success,function()
          activity.setTheme(android.R.style.Theme_DeviceDefault_DayNight)
        end)
        success=themeutil.setTheme(success,function()
          activity.setTheme(android.R.style.Theme_Material_Light)
        end)
        success=themeutil.setTheme(success,function()
          activity.setTheme(android.R.style.Theme_Holo)
        end)
      end)
      actionBar=activity.getActionBar()
    end
  end
end

return themeutil