import "android.animation.ObjectAnimator"
import "android.view.animation.DecelerateInterpolator"
import "android.view.animation.AccelerateInterpolator"
--动画助手
---@type AnimationHelper
local _M={}

---阴影状态字典的字典
---@type table<View, table>
local elevationMap={}
--local elevationStateMap={}
local backgroundColorMap={}

_M.elevationMap=elevationMap

---获取阴影状态
---@param view View
function _M.getElevation(view)
  return elevationMap[view]
end

---删除阴影状态
---@param view View
function _M.deleteElevation(view)
  elevationMap[view]=nil
end

---@param sideViewMap table
---@param sideElevationMap table
function _M.onScrollListenerForElevation(sideViewMap,sideElevationMap)
  for side,sideView in pairs(sideViewMap) do
    --旧状态
    local lastElevation=elevationMap[sideView]
    --新状态
    local newElevation=sideElevationMap[side]
    if lastElevation~=newElevation then
      ObjectAnimator.ofFloat(sideView, "elevation", {newElevation})
      .setDuration(150)
      .setAutoCancel(true)
      .start()
      elevationMap[sideView]=newElevation
    end
  end
end

---@param sideViewMap table
---@param sideElevationMap table
function _M.onScrollListenerForBackgroundColor(sideViewMap,sideElevationMap)
  for side,sideView in pairs(sideViewMap) do
    --旧状态
    local lastElevation=elevationMap[sideView]
    --新状态
    local newElevation=sideElevationMap[side]
    if lastElevation~=newElevation then
      ObjectAnimator.ofFloat(sideView, "elevation", {newElevation})
      .setDuration(150)
      .setAutoCancel(true)
      .start()
      elevationMap[sideView]=newElevation
    end
  end
end


function _M.onScrollListenerForActionBarElevation(actionBar,state)
  local elevation=0
  if state then
    elevation=res(res.id.attr.actionBarTheme).dimen.attr.elevation
  end
  _M.onScrollListenerForElevation({top=actionBar},{top=elevation})
end

function _M.onScrollListenerForToolBar(toolBar,backgroundViews,state)
  _M.onScrollListenerForActionBarElevation(actionBar,state)

end

return _M
