import "android.animation.ObjectAnimator"
import "android.view.animation.DecelerateInterpolator"
import "android.view.animation.AccelerateInterpolator"
--动画助手
---@type AnimationHelper
local AnimationHelper={}

---阴影状态字典的字典
---@type table<View, table>
local elevationStateMap={}


AnimationHelper.elevationStateMap=elevationStateMapMap

---获取阴影状态字典
---@param view View
function AnimationHelper.getElevationStateMap(view)
  return elevationStateMapMap[view]
end

function AnimationHelper.deleteElevationStateMap(view)
  elevationStateMapMap[view]=nil
end

AnimationHelper.onScrollListenerForElevation=function(sideViewMap,sideStateMap)
  for side,sideView in pairs(sideViewMap) do
    --旧状态
    local lastState=elevationStateMap[sideView]
    --新状态
    local newState=sideStateMap[side]
    if lastState~=newState then
      ObjectAnimator.ofFloat(sideView, "elevation", {newState and theme.number.actionBarElevation or 0})
      .setDuration(200)
      --.setInterpolator(AccelerateInterpolator())
      .setAutoCancel(true)
      .start()
      elevationStateMap[sideView]=newState
    end
  end
end

--[[
local ActionBarAnimationHelper={}
AnimationHelper.ActionBarAnimationHelper=ActionBarAnimationHelper
]]
return AnimationHelper
