---@class LuaDB
---@field TYPE_STREAM LUADB_STREAM 成员数据流
local M = {
  TYPE_STREAM = {}
}

local _NAME = 'db-stream'
---@type LuaDB
local super
---@class LUADB_STREAM
---@field [1] integer 空间长度
---@field __index function
---@class Stream
---@field private s integer
---@field private e integer
---@field private p integer
---@field private len integer
---@field private fw file
local stream = {}
local pack, unpack, packsize = string.pack, string.unpack, string.packsize
local type, pairs, setmetatable, getmetatable, error, assert =
type, pairs, setmetatable, getmetatable, error, assert
local table_unpack = table.unpack

---@private
---绑定LuaDB主模块
function M:bind(db)
  assert(db.ver, _NAME .. '::请使用LuaDB 3.0以上版本！')
  assert(db.ver >= 30, _NAME .. '::请使用LuaDB 3.0以上版本！')
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

function M:pack(v)
  if getmetatable(v) == M.TYPE_STREAM then
    -- 判断为流对象，写入空间长度
    local tp = 1
    local len = 8 + v[1]
    v = pack(self.F.T, v[1])
    return tp, len, v
  end
  return super.pack(self, v)
end

function M:set(k, v)
  local fw = self.fw
  super.set(self, k, v)
  if getmetatable(v) == M.TYPE_STREAM then
    fw:seek('cur', v[1] - 1)
    fw:write('\0')
  end
  return self
end

--- 成员数据流
---@param k any|LUADB_ADDR|LUADB_ID 成员key
---@return Stream
function M:stream(k)
  -- 申明变量
  local F = self.F
  local fw = self.fw
  -- 获取成员地址
  local po, addr, size = self:check_key(k)
  if addr == 0 then
    return
  end
  -- 过滤不支持的类型
  fw:seek('set', addr + 8 + size)
  local tp = unpack(F.B, fw:read(1))
  if tp ~= 1 then
    return
  end
  -- 获取空间长度
  local n = unpack(F.T, fw:read(8))
  -- 创建数据流对象
  local obj = {
    s = addr + 8 + size + 9,
    e = addr + 8 + size + 9 + n,
    p = addr + 8 + size + 9,
    len = n,
    fw = fw,
    __len = stream.size,
    __index = stream
  }
  return setmetatable(obj, obj)
end

--- 空间长度
---@return integer
function stream:length()
  return self.len
end

--- 移动流指针
---@param mode string 移动模式
---@param n integer 移动距离
---@return integer 当前位置
function stream:seek(mode, n)
  local s, e, p = self.s, self.e, self.p
  if mode == 'set' then -- 从头部开始
    n = n or 1
    p = s + n - 1
   elseif mode == 'cur' then -- 偏移
    n = n or 0
    p = p + n
   elseif mode == 'end' then -- 从尾部开始
    n = n or -1
    p = e + n + 1
  end
  if p < s or p > e then
    error('LuaDB::stream::指针越界！')
  end
  self.p = p
  return p - s + 1
end

--- 写入数据
---@param fmt string 二进制格式串或数据
---@vararg any
---@return Stream
function stream:write(fmt, ...)
  if ... then
    fmt = pack(fmt, ...)
  end
  self.fw:seek('set', self.p)
  self.fw:write(fmt)
  self:seek('cur', #fmt)
  return self
end

--- 读取数据
---@param fmt string|integer|nil 格式串|字节数|为空即读取剩余
---@return Stream
function stream:read(fmt)
  local n = fmt
  local e, p = self.e, self.p
  if not n then
    n = e - p
   elseif type(fmt) == 'string' then
    n = packsize(n)
  end

  if p + n > e then
    n = e - p
  end

  self.fw:seek('set', p)
  local s = self.fw:read(n)
  self:seek('cur', n)

  if type(fmt) == 'string' then
    s = { unpack(fmt, s) }
    return table_unpack(s, 1, #s - 1)
  end
  return s
end

--- 流类型的元方法
---@private
function M.TYPE_STREAM:__index(k)
  assert(k ~= 0, 'LuaDB::空间长度不可为0！')
  if k > 0 then
    return pack('c' .. k, '')
  end
  return setmetatable({ -k }, self)
end

setmetatable(M.TYPE_STREAM, M.TYPE_STREAM)

return M
