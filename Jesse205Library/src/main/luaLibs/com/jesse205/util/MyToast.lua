import "com.google.android.material.snackbar.Snackbar"
import "com.google.android.material.snackbar.BaseTransientBottomBar"
import "com.google.android.material.motion.MotionUtils"

local MyToast={}
setmetatable(MyToast,MyToast)

local context=jesse205.context
--mainLay为全局变量

function MyToast.showToast(text)
  local toast=Toast.makeText(context,text,Toast.LENGTH_SHORT)
  .show()
  return toast
end

function MyToast.showSnackBar(text,view)
  BaseTransientBottomBar.getDeclaredField("animationSlideDuration").setAccessible(true)
  BaseTransientBottomBar.getDeclaredField("animationFadeInDuration").setAccessible(true)
  BaseTransientBottomBar.getDeclaredField("animationFadeOutDuration").setAccessible(true)

  local snackBar=Snackbar.make(view or mainLay or context.getDecorView(),text,Snackbar.LENGTH_SHORT)
  --.setAnimationMode(Snackbar.ANIMATION_MODE_SLIDE)
  --snackbar的MD2动画时间存在问题。一旦被修复，则移除这段代码
  if not res.boolean.attr.isMaterial3Theme then
    snackBar.animationSlideDuration=MotionUtils.resolveThemeDuration(context, R.attr.motionDurationShort4,250)
    snackBar.animationFadeInDuration=MotionUtils.resolveThemeDuration(context, R.attr.motionDurationShort2,150)
    snackBar.animationFadeOutDuration=MotionUtils.resolveThemeDuration(context, R.attr.motionDurationShort1,75)
  end
  --[[
  snackBar.animationSlideDuration=200
  snackBar.animationFadeInDuration=150
  snackBar.animationFadeOutDuration=150]]
  snackBar.show()
  return snackBar
end


--[[
根据是否有view或者mainLay来是否显示SnackBar
@param text 接收类型为string的文字
@param view SnackBar显示的View，设置false为使用Toast
]]
function MyToast.autoShowToast(text,view)
  if view==nil then
    view=mainLay
  end
  local toast
  if view then
    toast=MyToast.showSnackBar(text,view)
   else
    toast=MyToast.showToast(text)
  end
  return toast
end

--根据网络错误代码显示Toast或SnackBar
function MyToast.showNetErrorToast(code,view)
  return MyToast.autoShowToast(getNetErrorStr(code),view)
end

--复制文字然后显示Toast
function MyToast.copyText(text,view)
  _G.copyText(text)
  return MyToast.autoShowToast(R.string.jesse205_toast_copied,view)
end

--显示“xxx成功/失败”
function MyToast.assetsAndToast(successStr,failedStr,succeed)
  local text
  if succeed then
    text=successStr
   else
    text=failedStr
  end
  return MyToast.showToast(text)
end

function MyToast.pcallToSnackbar(view,succeedStr,failedStr,succeed)
  local text
  if succeed then
    text=succeedStr
   else
    text=failedStr
  end
  return MyToast.showSnackBar(view,text)
end

--调用 MyToast() 时
function MyToast.__call(self,text,view)
  return MyToast.autoShowToast(text,view)
end

return MyToast