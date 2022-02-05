local context=activity or service
local dp2intCache={}
Jesse205.dp2intCache=dp2intCache
--[[清理dp2int缓存方法：
table.clear(Jesse205.dp2int)
]]
function math.dp2int(dpValue)
  local cache=dp2intCache[dpValue]
  if cache then
    return cache
   else
    import "android.util.TypedValue"
    local cache=TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue, context.getResources().getDisplayMetrics())
    dp2intCache[dpValue]=cache
    return cache
  end
end
function math.px2sp(pxValue)
  local scale=context.getResources().getDisplayMetrics().scaledDensity
  return pxValue/scale
end
--[[
function math.getNavigationBarHeight()
  local resourceId = activity.Resources.getIdentifier("navigation_bar_height","dimen", "android");
  local height = activity.Resources.getDimensionPixelSize(resourceId)
  return height
end
function math.getStatusBarHeight()
  local resourceId = activity.Resources.getIdentifier("status_bar_height", "dimen","android")
  local height = activity.Resources.getDimensionPixelSize(resourceId)
  return height
end

function math.getSmallestScreenWidthDp()
  return activity.Resources.getConfiguration().smallestScreenWidthDp
end

function math.getScreenRealSize()
  import "android.util.DisplayMetrics"
  local wm=activity.getSystemService(Context.WINDOW_SERVICE)
  local displayMetrics=DisplayMetrics()
  wm.getDefaultDisplay().getRealMetrics(displayMetrics)
  return displayMetrics.widthPixels,displayMetrics.heightPixels
end

function math.getDensityDpi()
  import "android.util.DisplayMetrics"
  local dm=DisplayMetrics()
  activity.WindowManager.getDefaultDisplay().getMetrics(dm)
  return dm.densityDpi;
end
]]
--return math