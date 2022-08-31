local PermissionUtil={}
local grantedList={}
PermissionUtil.grantedList=grantedList
local context=Jesse205.context--当前context

local function request(permissions)
  context.requestPermissions(String(permissions),0)
end
PermissionUtil.request=request

local function checkPermission(permission)
  return ContextCompat.checkSelfPermission(context,permission)==PackageManager.PERMISSION_GRANTED
end
PermissionUtil.checkPermission=checkPermission

local function check(permissions)
  for index,permission in ipairs(permissions)
    local granted=checkPermission(permission)
    if not(granted) then--有一个没给予，直接返回false
      return false
    end
  end
  return true--所有的权限都没有没被给予，返回true
end
PermissionUtil.check=check

local function smartRequestPermission(permissions)
  local needApply={}
  for index,permission in ipairs(permissions)
    local granted=grantedList[permission]
    if not(granted) then
      local nowGranted=checkPermission(permission)
      if nowGranted then
        grantedList[permission]=true
       else
        table.insert(needApply,permission)
      end
    end
  end
  if #needApply~=0 then
    request(needApply)
  end
  needApply=nil
end
PermissionUtil.smartRequestPermission=smartRequestPermission

return PermissionUtil
