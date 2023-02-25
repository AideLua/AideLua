import "android.animation.ObjectAnimator"
import "android.view.animation.DecelerateInterpolator"
import "android.view.animation.AccelerateInterpolator"
--动画助手
---@type AnimationHelper
local _M={}

---阴影状态字典的字典
---@type table<View, table>
local elevationStateMap={}


_M.elevationStateMap=elevationStateMap

---获取阴影状态字典
---@param view View
function _M.getElevationStateMap(view)
  return elevationStateMap[view]
end

function _M.deleteElevationStateMap(view)
  elevationStateMap[view]=nil
end

function _M.onScrollListenerForElevation(sideViewMap,sideStateMap)
  for side,sideView in pairs(sideViewMap) do
    --旧状态
    local lastState=elevationStateMap[sideView]
    --新状态
    local newState=sideStateMap[side]
    if lastState~=newState then
      ObjectAnimator.ofFloat(sideView, "elevation", {newState and theme.number.actionBarElevation or 0})
      .setDuration(200)
      .setAutoCancel(true)
      .start()
      elevationStateMap[sideView]=newState
    end
  end
end

function _M.onScrollListenerForActionBarElevation(actionBar,state)
  _M.onScrollListenerForElevation({top=actionBar},{top=state})
end

return _M
