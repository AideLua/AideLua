---@class LuaDB
local M = {}

local _NAME = 'db-pack'
---@type LuaDB
local super

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

--- 类型常量
local NIL = 0
local STRING = 1
local INTEGER = 2
local DOUBLE = 3
local BOOLEAN = 4
local FUNCTION = 5
local TABLE = 6
local DATABASE = 7

local pack, unpack = string.pack, string.unpack
local next, tonumber, type, assert, load = next, tonumber, type, assert, load
local math_type, string_dump = math.type, string.dump

--- 导出数据
---@private
---@param t LuaDB
---@return file
local function O(t, f)
  local is, e, block_size, addr_size = t.get_pointer
  if is then
    block_size = t.block_size
    addr_size = t.addr_size
    e = super.each(t)
   else
    e = next
  end
  for k, v in e, t do
    if is then
      v = t:get(k)
      k = t:real_name(k)
    end
    local tp = type(k)
    if tp == 'string' then
      f:write((pack('>Bs2', STRING, k)))
     elseif tp == 'number' then
      if math_type(k) == 'integer' then
        f:write((pack('>Bi8', INTEGER, k)))
       else
        f:write((pack('>Bn', DOUBLE, k)))
      end
    end
    tp = type(v)
    if tp == 'string' then
      f:write((pack('>Bs4', STRING, v)))
     elseif tp == 'number' then
      if math_type(v) == 'integer' then
        f:write((pack('>Bi8', INTEGER, v)))
       else
        f:write((pack('>Bn', DOUBLE, v)))
      end
     elseif tp == 'boolean' then
      f:write((pack('>BB', BOOLEAN, v and 1 or 0)))
     elseif tp == 'function' then
      f:write((pack('>Bs4', FUNCTION, string_dump(v, true))))
     elseif tp == 'table' then
      local p = v.get_pointer
      if p then
        f:write((pack('>B', DATABASE)))
       else
        f:write((pack('>B', TABLE)))
      end
      O(v, f)
      if p then
        f:write((pack('>B', DATABASE)))
       else
        f:write((pack('>B', TABLE)))
      end
     else
      f:write((pack('>B', NIL)))
    end
  end
end

--- 输出数据到文件
---@param f string
---@return LuaDB
function M:output(f)
  assert(self.can_each, _NAME .. '::请开启遍历支持！')
  f = io.open(f, 'w')
  O(self, f)
  f:close()
  return self
end

--- 导入数据到数据库
---@param f string
---@return LuaDB
function M:input(f)
  f = io.open(f)
  local sf = { DATABASE, self }
  local stack = {}
  while true do
    local pop, pass = stack[#stack] or sf
    local tp, k = f:read(1)
    if not tp then break end
    tp = unpack('>B', tp)
    if tp == INTEGER then
      k = unpack('>i8', f:read(8))
     elseif tp == DOUBLE then
      k = unpack('>n', f:read(8))
     elseif tp == STRING then
      k = unpack('>I2', f:read(2))
      k = f:read(k)
     else
      stack[#stack] = nil
      pass = true
      if pop[1] == TABLE then
        local p = stack[#stack] or sf
        if not p[2].get_pointer then
          p[2][pop[3]] = pop[2]
         else
          p[2]:set(pop[3], pop[2])
        end
       else
        local p = stack[#stack] or sf
        if not p[2].get_pointer then
          p[2][pop[3]] = super.TYPE_DB(pop[2])
         else
          p[2]:set(pop[3], pop[2])
        end
      end
    end
    if not pass then
      local tp, v, is = f:read(1)
      tp = unpack('>B', tp)
      if tp == STRING then
        v = unpack('>I', f:read(4))
        v = f:read(v)
       elseif tp == INTEGER then
        v = unpack('>i8', f:read(8))
       elseif tp == DOUBLE then
        v = unpack('>n', f:read(8))
       elseif tp == BOOLEAN then
        v = unpack('>B', f:read(1)) == 1
       elseif tp == FUNCTION then
        v = unpack('>I', f:read(4))
        v = load(f:read(v))
       elseif tp == TABLE then
        local t = {}
        stack[#stack + 1] = { TABLE, t, k }
        is = true
       elseif tp == DATABASE then
        local p, t = pop[2]
        if p.get_pointer then
          p:set(k, super.TYPE_DB)
          t = p:get(k)
         else
          t = {}
        end
        stack[#stack + 1] = { DATABASE, t, k }
        is = true
      end
      if not is then
        if not pop[2].get_pointer then
          pop[2][k] = v
         else
          pop[2]:set(k, v)
        end
      end
    end
  end
  f:close()
  return self
end

return M
