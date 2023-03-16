local _M={}
_M._VERSION="1.0 (alpha3) (dev)"
_M._VERSIONCODE=1003
_M._NAME="Android Res Getter"

--android.res
local androidRes=table.clone(_M)
android.res=androidRes
androidRes._isAndroidRes=true

---默认值
---@type table<string,all>
local defaultAttrValues={
  color=0xFFFF0000,
  id=0,
  resourceId=0,
  boolean=false,
  dimension=0,
  dimensionPixelSize=0,
  dimensionPixelOffset=0,
  dimen=0,
  float=0,
  int=0,
  integer=0,
  themeAttributeId=0,
}

---@type table<string,boolean>
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

---将键转换为java的方法名称
---@type table<string,string>
local key2GetterMap={
  id="getResourceId",
  dimen="getDimension",
  bool="getBoolean",
}

---@type table<string,string>
local key2ResGetterMap={
  int="getInteger",
}

--将键转换为R的键
local key2RIndexMap={
  colorStateList="color",
  resourceId="id",
  dimension="dimen",
  dimensionPixelSize="dimen",
  dimensionPixelOffset="dimen",
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
---@type table<number,table>
local styledResMap={}
---@type table<number,table>
local styledAndroidResMap={}

---将key转换为用于获取TypedArray的方法名
---@param key string 资源类型名称，也就是res.(xxxx)的这段
---@return string methodName 方法名
local function key2Getter(key)
  return key2GetterMap[key] or "get"..string.gsub(key, "^(%w)", string.upper)
end

---将key转换为用于获取Resource的方法名
---@param key string 资源类型名称，也就是res.(xxxx)的这段
---@return string methodName 方法名
local function key2ResGetter(key)
  return key2ResGetterMap[key] or key2Getter(key)
end

---将key转换为R的子类名称
---@param key string 资源类型名称，也就是res.(xxxx)的这段
---@return string rClassName R的子类名
local function key2RIndex(key)
  return key2RIndexMap[key] or key
end

---获取主题中的值
---@param _type string 资源类型名称，也就是res.(xxxx)的这段
---@param key string attr名称，也就是res.xxxx.attr.(xxxx)的这段
---@param style number 主题ID
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