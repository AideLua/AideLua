---@class LuaDB
---@field Exp table 查询表达式
local M = {}

local _NAME = 'db-query'
---@type LuaDB
local super
---@alias Query_EXP any|fun(f:any):boolean
---@class Query
---@field private iter fun():LUADB_ADDR
---@field private db LuaDB
---@field private kf Query_EXP
---@field private vf Query_EXP
---@field Exp table 表达式
local query = { Exp = {} }
local type, pairs, setmetatable, getmetatable, assert, ipairs =
type, pairs, setmetatable, getmetatable, assert, ipairs

---@private
---绑定LuaDB主模块
function M:bind(db)
  assert(db.ver, _NAME .. '::请使用LuaDB 3.2以上版本！')
  assert(db.ver >= 32, _NAME .. '::请使用LuaDB 3.2以上版本！')
  self.bind = nil
  if not db.super then
    super = {}
    for k, v in pairs(db) do
      super[k] = v
    end
    db.super = super
  end
  super = db.super
  for k, v in pairs(self) do
    db[k] = v
    self[k] = nil
  end
  M = db
  return db
end

--- 联合查询
---@return Query
function M:query()
  local obj = {
    iter = self:each(),
    db = self
  }
  return setmetatable(obj, query)
end

--- 查询key
---@param f Query_EXP
---@return Query
function query:key(f)
  self.kf = f
  return self
end

--- 查询value
---@param f Query_EXP
---@return Query
function query:value(f)
  self.vf = f
  return self
end

--- 迭代查询
---@param n? integer
---@return fun():LUADB_ADDR
function query:find(n)
  local i = 0
  local iter, db = self.iter, self.db
  local kf, vf = self.kf, self.vf
  return function()
    if n then
      i = i + 1
      if i > n then return end
    end
    while true do
      local o = iter()
      if not o then return end
      local f = true
      if kf ~= nil then
        local name = db:real_name(o)
        if type(kf) == 'function' then
          f = kf(name)
         else
          f = name == kf
        end
      end
      if f then
        if vf == nil then
          return o
         else
          local v = db:get(o)
          o.value = v
          if type(vf) == 'function' then
            if vf(v) then return o end
           else
            if v == vf then return o end
          end
        end
      end
    end
  end
end

--- 查询单条数据
---@return LUADB_ADDR
function query:findone()
  return self:find(1)()
end

--- 查询数据到数组
---@param n integer
---@return {...:LUADB_ADDR}
function query:map(n)
  local t = {}
  for o in self:find(n) do
    t[#t + 1] = o
  end
  return t
end

--- 跳过结果
---@param n integer
---@return Query
function query:skip(n)
  self.findone()
  return self
end

--- 重置查询对象
---@return Query
function query:reset()
  self.iter = self:each()
  return self
end

local exp = query.Exp

--- 绑定表达式到环境
---@param env table
---@return table
function exp:bind(env)
  env = env or _G
  for k, v in pairs(self) do
    env[k] = v
  end
  return self
end

--- 查询table
---@param v table
---@param mode? boolean
---@return Query_EXP
function exp.TABLE(v, mode)
  return function(v1)
    if type(v1) ~= 'table' or
      getmetatable(v1) == M then
      return false
    end
    if type(v) == 'function' then
      return v(v1)
    end
    for k3, v3 in pairs(v) do
      if type(k3) ~= 'function' then
        local v2 = v1[k3]
        if type(v3) == 'function' then
          local v = v3(v2)
          if v and mode then return true end
          if (not v) and not mode then return false end
         else
          if v2 == v3 and mode then return true end
          if v2 ~= v3 and not mode then return false end
        end
       else
        for k2, v2 in pairs(v1) do
          if k3(k2) then
            if type(v3) == 'function' then
              local v = v3(v2)
              if v and mode then return true end
              if (not v) and not mode then return false end
             else
              if v2 == v3 and mode then return true end
              if v2 ~= v3 and not mode then return false end
            end
          end
        end
      end
    end
    if mode then return false else return true end
  end
end

--- 查询数据库
---@param v table
---@param mode? boolean
---@return Query_EXP
function exp.DB(v, mode)
  return function(v1)
    if getmetatable(v1) ~= M then
      return false
    end
    if type(v) == 'function' then
      return v(v1)
    end
    local ids
    for k3, v3 in pairs(v) do
      if type(k3) ~= 'function' then
        local v2 = v1:get(k3)
        if type(v3) == 'function' then
          local v = v3(v2)
          if v and mode then return true end
          if (not v) and not mode then return false end
         else
          if v2 == v3 and mode then return true end
          if v2 ~= v3 and not mode then return false end
        end
       else
        if not ids then
          ids = {}
          for o in v1:each() do
            local v = v1:get(o)
            local name = v1:real_name(o)
            ids[name] = v
          end
        end
        for k2, v2 in pairs(ids) do
          if k3(k2) then
            if type(v3) == 'function' then
              local v = v3(v2)
              if v and mode then return true end
              if (not v) and not mode then return false end
             else
              if v2 == v3 and mode then return true end
              if v2 ~= v3 and not mode then return false end
            end
          end
        end
      end
    end
    if mode then return false else return true end
  end
end

--- 匹配全部
---@return boolean
function exp.ALL()
  return true
end

--- 等于
---@param v any
---@return Query_EXP
function exp.EQ(v)
  return function(v1)
    return v1 == v
  end
end

--- 不等于
---@param v any
---@return Query_EXP
function exp.NE(v)
  return function(v1)
    return v1 ~= v
  end
end

--- 非
---@param v Query_EXP
---@return Query_EXP
function exp.NOT(v)
  return function(v1)
    return not v(v1)
  end
end

--- 且
---@vararg table
---@return Query_EXP
function exp.AND(...)
  local t = { ... }
  if not t[2] then
    t = t[1]
  end
  return function(v1)
    for k, v in ipairs(t) do
      if not v(v1) then return false end
    end
    return true
  end
end

--- 或
---@vararg table
---@return Query_EXP
function exp.OR(...)
  local t = { ... }
  if not t[2] then t = t[1] end
  return function(v1)
    for k, v in ipairs(t) do
      if v(v1) then return true end
    end
    return false
  end
end

--- 正则
---@param v string
---@return Query_EXP
function exp.REQ(v)
  return function(v1)
    if type(v1) ~= 'string' then
      return false
    end
    return not not v1:find(v)
  end
end

--- 小于
---@param v string|number
---@return Query_EXP
function exp.LT(v)
  return function(v1)
    local tp1, tp2 = type(v1), type(v)
    if (tp1 == 'string' or tp1 == 'number') and (tp1 == tp2) then
      return v1 < v
    end
    return false
  end
end

--- 小于等于
---@param v string|number
---@return Query_EXP
function exp.LTE(v)
  return function(v1)
    local tp1, tp2 = type(v1), type(v)
    if (tp1 == 'string' or tp1 == 'number') and (tp1 == tp2) then
      return v1 <= v
    end
    return false
  end
end

--- 大于
---@param v string|number
---@return Query_EXP
function exp.GT(v)
  return function(v1)
    local tp1, tp2 = type(v1), type(v)
    if (tp1 == 'string' or tp1 == 'number') and (tp1 == tp2) then
      return v1 > v
    end
    return false
  end
end

--- 大于等于
---@param v string|number
---@return Query_EXP
function exp.GTE(v)
  return function(v1)
    local tp1, tp2 = type(v1), type(v)
    if (tp1 == 'string' or tp1 == 'number') and tp1 == tp2 then
      return v1 >= v
    end
    return false
  end
end

--- 范围
---@param s string|number
---@param e string|number
---@return Query_EXP
function exp.RANGE(s, e)
  return function(v1)
    local tp1, tp2, tp3 = type(v1), type(s), type(e)
    if (tp1 == 'string' or tp1 == 'number')
      and tp1 == tp2 and tp2 == tp3 then
      return v1 >= s and v1 <= e
    end
    return false
  end
end

--- 属于
---@param v string|table
---@return Query_EXP
function exp.IN(v)
  local tp1 = type(v)
  return function(v1)
    local tp2 = type(v1)
    if tp1 == 'string' and tp2 == tp1 then
      return not not v:find(v1, nil, true)
    end
    for k, v in ipairs(v) do
      if v == v1 then return true end
    end
    return false
  end
end

--- 不属于
---@param v string|table
---@return Query_EXP
function exp.NIN(v)
  local tp1 = type(v)
  return function(v1)
    local tp2 = type(v1)
    if tp1 == 'string' and tp2 == tp1 then
      return not v:find(v1, nil, true)
    end
    for k, v in ipairs(v) do
      if v == v1 then return false end
    end
    return true
  end
end

--- 包含
---@param v any
---@return Query_EXP
function exp.CONTAIN(v)
  local tp1 = type(v)
  return function(v1)
    local tp2 = type(v1)
    if tp2 ~= 'table' and tp2 ~= 'string' then
      return false
     elseif tp2 == 'string' and tp1 == tp2 then
      return not not v1:find(v, nil, true)
     elseif tp2 == 'table' then
      if getmetatable(v1) == M then
        for o in v1:each() do
          local v2 = v1:get(o)
          if v2 == v then return true end
        end
       else
        for k2, v2 in pairs(v1) do
          if v2 == v then return true end
        end
      end
    end
    return false
  end
end

--- 不包含
---@param v any
---@return Query_EXP
function exp.NO_CONTAIN(v)
  local tp1 = type(v)
  return function(v1)
    local tp2 = type(v1)
    if tp2 ~= 'table' and tp2 ~= 'string' then
      return false
     elseif tp2 == 'string' and tp1 == tp2 then
      return not v1:find(v, nil, true)
     elseif tp2 == 'table' then
      if getmetatable(v1) == M then
        for o in v1:each() do
          local v2 = v1:get(o)
          if v2 == v then return false end
        end
       else
        for k2, v2 in pairs(v1) do
          if v2 == v then return false end
        end
      end
    end
    return true
  end
end

--- 表大小
---@param v integer
---@return Query_EXP
function exp.SIZE(v)
  return function(v1)
    if type(v1) ~= 'table' and
      type(v1) ~= 'string' then
      return false
    end
    local i = 0
    if type(v1) == 'string' then
      i = #v1
     else
      local e = next
      if getmetatable(v1) == M then
        e = v1:each()
      end
      for k in e, v1 do
        i = i + 1
      end
    end
    if type(v) == 'function' then return v(i) end
    return v == i
  end
end

--- 类型
exp.TYPE = {}
setmetatable(exp.TYPE, exp.TYPE)
function exp.TYPE:__index(k)
  return function(v)
    if getmetatable(v) == M then
      return k == 'DB'
    end
    local tp = type(v):upper()
    if tp == 'NUMBER' and k == 'INTEGER' then
      return math.type(v) == 'integer'
    end
    return tp == k
  end
end

---@private
query.__index = query
M.Exp = query.Exp
return M
