--RES资源获取工具
--[[
--颜色
res.color.attr.colorAccent
android.res.color.attr.colorAccent
res.colorStateList.attr.colorAccent
res.color.attr.colorPrimary
--id
android.res.id.attr.actionBarTheme
res.id.attr.actionBarTheme

res(android.res.id.attr.actionBarTheme).color.attr.colorControlNormal

]]
local _M={}
_M._VERSION="1.0 (alpha3) (dev)"
_M._VERSIONCODE=1003
_M._NAME="Android Res Getter"

--android.res
local androidRes=table.clone(_M)
androidRes._isAndroidRes=true
android.res=androidRes

---默认值
local defaultAttrValues={
  color=0xFFFF0000,
  id=0,
  resourceId=0,
  boolean=false,
  dimension=0,
  dimen=0,
  float=0,
  int=0,
  integer=0,
  themeAttributeId=0,
}

local noDefaultAttrValues={
  colorStateList=true,
  complexColor=true,
  drawable=true,
  font=true,
  string=true,
  text=true,
  textArray=true,
  type=true,
}

--将键转换为java的方法名称
local key2GetterMap={
  id="getResourceId",
  dimen="getDimension",
  bool="getBoolean",
}

local key2ResGetterMap={
  int="getInteger",
}

--将键转换为R的键
local key2RIndexMap={
  colorStateList="color",
  resourceId="id",
  dimension="dimen",
  int="integer",
  boolean="bool",
  text="string",
}

local resources=activity.getResources()
local contextTheme=activity.getTheme()

local resMetatable,
androidMetatable,typeMetatable,
androidAttrMetatable,attrMetatable

--应用了样式的res索引
local styledResMap={}
local styledAndroidResMap={}

local function key2Getter(key)
  return key2GetterMap[key] or "get"..string.gsub(key, "^(%w)", string.upper)
end

local function key2ResGetter(key)
  return key2ResGetterMap[key] or key2Getter(key)
end

local function key2RIndex(key)
  return key2RIndexMap[key] or key
end

local function getAttrValue(_type,key,style)
  local array
  if style then
    array=contextTheme.obtainStyledAttributes(style,{key})
   else
    array=contextTheme.obtainStyledAttributes({key})
  end
  local value
  if noDefaultAttrValues[_type] then
    value=array[key2Getter(_type)](0)
   else
    value=array[key2Getter(_type)](0,defaultAttrValues[_type])
  end
  array.recycle()
  luajava.clear(array)
  return value
end

typeMetatable={
  __index=function(self,key)
    local _type=rawget(self,"_type")
    local style=rawget(self,"_style")
    local isAndroidRes=rawget(self,"_isAndroidRes")
    local value
    if key=="attr" then--res.xxx.attr
      value={_type=_type,_isAndroidRes=isAndroidRes,_style=style}
      setmetatable(value,attrMetatable)
     else--res.xxx.xxx
      local Rid=isAndroidRes and android.R or R
      value = resources[key2ResGetter(_type)](Rid[key2RIndex(_type)][key])
    end
    rawset(self,key,value)
    return value
  end
}

attrMetatable={
  __index=function(self,key)
    local _type=rawget(self,"_type")
    local style=rawget(self,"_style")
    local isAndroidRes=rawget(self,"_isAndroidRes")
    local value
    local Rid=isAndroidRes and android.R or R
    value=getAttrValue(_type,Rid.attr[key],style)
    rawset(self,key,value)
    return value
  end
}

resMetatable={
  __index=function(self,key)
    local isAndroidRes=rawget(self,"_isAndroidRes")
    local style=rawget(self,"_style")
    local typeT={_type=key,_isAndroidRes=isAndroidRes,_style=style}
    setmetatable(typeT,typeMetatable)
    return typeT
  end,
  __call=function(self,key)
    local isAndroidRes=rawget(self,"_isAndroidRes")
    local map=isAndroidRes and styledAndroidResMap or styledResMap
    local styled=map[key]
    if not styled then
      styled={_isAndroidRes=isAndroidRes,_style=key}
      setmetatable(styled,resMetatable)
      map[key]=styled
    end
    return styled
  end,
}

setmetatable(_M,resMetatable)
setmetatable(androidRes,resMetatable)

return _M