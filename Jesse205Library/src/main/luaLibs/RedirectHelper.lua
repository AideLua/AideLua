---轻量的重定向工具
---@author Jesse205
---@version 1.0
require "import"
import "android.content.Intent"
local activity=activity

local RedirectHelper={}
RedirectHelper._VERSION="1.0"

---重定向到原生的Activity
---@return true 已重定向，可以判断是否暂停执行代码
function RedirectHelper.toAndroidActivity(activityClassName)
  if activity.getClass().getName()~=activityClassName then
    local intent=Intent(activity,luajava.bindClass(activityClassName))
    activity.startActivity(intent)
    activity.finish()
    return true
  end
end

return RedirectHelper
