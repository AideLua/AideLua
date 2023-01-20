--- kv数据库
---@class LuaDB
---@field private F table 格式串
---@field private fw file db文件
---@field private fm file map文件
---@field private fg file gc文件
---@field private node_id integer 节点id
---@field byte_order string 字节序
---@field block_size integer 簇大小
---@field addr_size integer 地址长度
---@field can_each boolean 遍历支持
---@field ver integer 数据库版本
---@field BIT_16 integer 地址16位
---@field BIT_32 integer 地址32位
---@field BIT_64 integer 地址64位
---@field BYTE_LE string 小端
---@field BYTE_BE string 大端
---@field BYTE_AUTO string 跟随系统
---@field TYPE_DB LUADB_DB 子数据库
---@field TYPE_ID LUADB_ID 成员指针
---@field TYPE_ADDR LUADB_ADDR 成员地址
---@field TYPE_STREAM LUADB_STREAM 成员数据流
local db = {
    ver = 30,
    BIT_16 = 2,
    BIT_32 = 4,
    BIT_64 = 8,
    BYTE_LE = '<',
    BYTE_BE = '>',
    BYTE_AUTO = '=',
    TYPE_ID = {},
    TYPE_ADDR = {},
    TYPE_DB = {},
    TYPE_STREAM = {}
}

---@class LUADB_STREAM
---@field [1] integer
---@field __index function

---@class LUADB_ADDR
---@field pointer integer
---@field addr integer
---@field key_size integer
---@field key string
---@field name string

---@class LUADB_ID: LUADB_ADDR

---@class LUADB_DB
---@field __call function

---@class Stream
---@field private s integer
---@field private e integer
---@field private p integer
---@field private len integer
---@field private fw file
local stream = {}

-- global转local
local pack, unpack, packsize = string.pack, string.unpack, string.packsize
local type, pairs, tostring, setmetatable, getmetatable, error, assert, load =
type, pairs, tostring, setmetatable, getmetatable, error, assert, load
local math_type, string_dump, table_concat, string_byte, table_unpack =
math.type, string.dump, table.concat, string.byte, table.unpack


-- 格式串模板
local _F = { 'c5BAA', 'c5B', 'i8', 's', 'n', 'A', 'AA', 'B', 'T', 'sB' }
local _C = { -- 配置模板
    node_id = 6,
    block_size = 4096,
    can_each = false,
    addr_size = db.BIT_32,
    byte_order = db.BYTE_AUTO
}

--- 序列化数值
---@private
---@param t any 值
---@return any
local function serialize(t)
    -- 获取类型
    local tp = type(t)
    if tp == 'string' then -- 判断为字符串
        -- 打包为二进制串 类型/字符串
        return pack('bs', 1, t)
    elseif tp == 'number' then -- 判断为数值
        if math_type(t) == 'integer' then -- 判断为整数
            return pack('bi8', 2, t) -- 打包为int64
        end
        -- 否则打包为number
        return pack('bn', 3, t)
    elseif tp == 'boolean' then -- 判断为布尔值
        -- 打包为字节
        return pack('bb', 4, t and 1 or 0)
    elseif tp == 'function' then -- 判断为函数
        -- 序列化并打包为字符串
        return pack('bs', 5, string_dump(t))
    elseif tp == 'table' then -- 判断为table
        local s = {} -- 申明table
        for k, v in pairs(t) do -- 遍历传入的table
            -- 序列化key与value
            k, v = serialize(k), serialize(v)
            -- 序列化成功即赋值
            if k ~= nil and v ~= nil then
                s[#s + 1] = k .. v -- 将key与value拼接并赋值
            end
        end
        s = table_concat(s) -- 拼接数组，返回二进制串
        return pack('bs', 6, s) -- 打包为字符串
    end
end

--- 反序列化数值
---@private
---@param s string 二进制串
---@param n integer 偏移值
---@return any
---@overload fun(s:string):any
local function deserialize(s, n)
    n = n or 1 -- 默认不偏移
    local tp = unpack('b', s, n) -- 解包类型值
    if tp == 1 then -- 判断为字符串
        -- 解包为字符串
        return unpack('s', s, n + 1)
    elseif tp == 2 then -- 判断为整数
        -- 解包为int64
        return unpack('i8', s, n + 1)
    elseif tp == 3 then -- 判断为数值
        -- 解包为number
        return unpack('n', s, n + 1)
    elseif tp == 4 then -- 判断为布尔值
        -- 解包byte，并判断是否为1
        local v, n = unpack('b', s, n + 1)
        return v == 1, n
    elseif tp == 5 then -- 判断为函数
        -- 解包为字符串并load
        local v, n = unpack('s', s, n + 1)
        return load(v), n
    elseif tp == 6 then -- 判断为table
        local t = {} -- 申明table
        -- 解包成员为字符串
        s, n = unpack('s', s, n + 1)
        if #s > 0 then --判断table是否为空
            local i = 1 -- 起始偏移值
            while true do -- 遍历成员
                -- 反序列化key
                local k, n = deserialize(s, i)
                i = n -- 偏移
                -- 反序列化value
                local v, n = deserialize(s, i)
                i = n -- 偏移
                t[k] = v -- 赋值到table
                -- 遍历结束，跳出循环
                if i > #s then
                    break
                end
            end
        end
        return t, n -- 返回table
    end
end

--- hash函数
---@private
---@param s any 数值
---@return integer
local function hash(s)
    -- 判断为整数，返回整数以减少碰撞
    if math_type(s) == 'integer' then
        if s > 0 then
            return s
        end
    end
    -- 将数值转为字符串处理
    s = tostring(s)
    local l = #s
    local h = l
    local step = (l >> 5) + 1
    for i = l, step, -step do
        h = h ~ ((h << 5) + string_byte(s, i) + (h >> 2))
    end
    return h -- 返回hash值
end

--- 打开数据库
---@param config table|string 路径或配置表
---@return LuaDB
function db.open(config)
    -- 如果传入路径，则将其转为配置表
    if type(config) == 'string' then
        config = {
            path = config
        }
    end
    -- 导入模板
    for k, v in pairs(_C) do
        local c = config[k]
        if c == nil then
            config[k] = v
        end
    end
    -- 将配置表作为db对象
    local self = config
    setmetatable(self, db) -- 设置元表
    local F = {} -- 创建格式串
    for i = 1, #_F do -- 导入模板
        -- 设置地址大小
        local v = _F[i]
        local _v = v:gsub('A', 'I' .. self.addr_size)
        F[v] = self.byte_order .. _v -- 添加字节序
    end
    self.F = F -- 将格式串添加到self
    -- 打开文件对象
    local f = io.open(self.path)
    if f then -- 存在即加载
        f:close()
        self:init()
    else -- 不存在则创建
        self:reset()
    end
    return self
end

---重置数据库
---@return LuaDB
function db:reset()
    -- 创建数据库文件，写入信息
    io.open(self.path, 'wb'):write((pack(self.F.c5BAA, 'LuaDB', db.ver, 0, 0))):close()
    io.open(self.path .. '.gc', 'wb'):close()
    io.open(self.path .. '.map', 'wb'):close()
    self:init() -- 加载数据库
    return self
end

--- 加载数据库
---@private
---@return LuaDB
function db:init()
    -- 打开文件对象并设置缓冲模式
    self.fw = io.open(self.path, 'r+b')
    self.fw:setvbuf('no')
    self.fg = io.open(self.path .. '.gc', 'r+b')
    self.fg:setvbuf('no')
    self.fm = io.open(self.path .. '.map', 'r+b')
    self.fm:setvbuf('no')
    -- 校验文件标识，并赋值版本号
    local s = self.fw:read(6)
    assert(s, 'LuaDB::数据格式错误！')
    assert(#s >= 6, 'LuaDB::数据格式错误！')
    local tag, ver = unpack(self.F.c5B, s)
    self.ver = ver
    assert(tag == 'LuaDB', 'LuaDB::数据格式错误！')
    return self
end

--- 打包数据
---@private
---@param v any 数据
---@return integer,integer,any,boolean
function db:pack(v)
    -- 申明变量，并获取数据类型
    local F = self.F
    local tp, len, mode = type(v), 0
    if v == nil then -- 数值为空，即不写入数据
        tp = 0
        v = ''
        len = 0
    elseif tp == 'string' then -- 打包数据
        tp = 1
        v = pack(F.s, v)
        len = #v
    elseif math_type(v) == 'integer' then
        tp = 2
        len = 8
        v = pack(F.i8, v)
    elseif tp == 'number' then
        tp = 3
        len = 8
        v = pack(F.n, v)
    elseif tp == 'boolean' then
        tp = 4
        len = 1
        v = v and '\1' or '\0'
    elseif tp == 'function' then
        tp = 5
        v = pack(F.s, string_dump(v, true))
        len = #v
    elseif getmetatable(v) == db.TYPE_DB then
        -- 判断为子数据库，写入起始指针和最近指针
        tp = 6
        v = pack(F.AA, 0, 0)
        len = self.addr_size * 2
    elseif getmetatable(v) == db.TYPE_STREAM then
        -- 判断为流对象，写入空间长度
        tp = 1
        len = 8 + v[1]
        v = pack(F.T, v[1])
        mode = true -- 稀疏空间
    elseif tp == 'table' then
        tp = 7
        v = pack(F.s, serialize(v))
        len = #v
    else
        error('LuaDB::不支持的类型::' .. tp)
    end
    return tp, len, v, mode
end

--- 解包数据
---@private
---@param addr 解包地址
---@return any
function db:unpack(addr)
    -- 申明变量
    local F = self.F
    local fw = self.fw
    -- 定位到地址
    fw:seek('set', addr)
    -- 获取类型值
    local tp = unpack(F.B, fw:read(1))
    -- 判断类型值并解包
    if tp == 1 then
        local n = unpack(F.T, fw:read(8))
        return fw:read(n)
    elseif tp == 2 then
        return (unpack(F.i8, fw:read(8)))
    elseif tp == 3 then
        return (unpack(F.n, fw:read(8)))
    elseif tp == 4 then
        return fw:read(1) == '\1'
    elseif tp == 5 then
        local n = unpack(F.T, fw:read(8))
        return load(fw:read(n))
    elseif tp == 6 then
        -- 创建子数据库对象
        local v0 = setmetatable({}, db)
        for k, v in pairs(self) do -- 继承对象
            v0[k] = v
        end
        v0.node_id = addr + 1 -- 设置节点id
        return v0
    elseif tp == 7 then
        local n = unpack(F.T, fw:read(8))
        return (deserialize(fw:read(n))) -- 反序列化
    end
end

--- 成员指针
---@param key any|LUADB_ADDR key或成员地址
---@return LUADB_ID
function db:id(key)
    -- 判断为成员地址
    if getmetatable(key) == db.TYPE_ADDR then
        local o = { pointer = key.pointer, key = key.key, name = key.name }
        return setmetatable(o, db.TYPE_ID)
    end
    -- 获取指针地址
    local po = self:get_pointer(key)
    local name = key -- 处理key名称
    if self.node_id > 6 then
        name = name:sub(self.addr_size + 1)
    end
    -- 创建成员指针对象
    local o = { pointer = po, key = key, name = name }
    return setmetatable(o, db.TYPE_ID)
end

--- 加载成员指针
---@param key any 成员key
---@param po integer 指针地址
---@return LUADB_ID
function db:load_id(key, po)
    local name = key -- 处理成员名称
    if self.node_id > 6 then
        name = name:sub(self.addr_size + 1)
    end
    -- 创建成员指针对象
    local o = { pointer = po, key = key, name = name }
    return setmetatable(o, db.TYPE_ID)
end

--- 成员地址
---@param id any|LUADB_ID 成员key或成员指针
---@return LUADB_ADDR
function db:addr(id)
    -- 判断为成员key
    if getmetatable(id) ~= db.TYPE_ID then
        -- 获取指针地址
        local po, addr, size = self:get_pointer(id)
        local name = id -- 处理成员名称
        if self.node_id > 6 then
            name = name:sub(self.addr_size + 1)
        end
        -- 创建成员地址对象
        local o = { pointer = po, addr = addr, key_size = size, key = id, name = name }
        return setmetatable(o, db.TYPE_ADDR)
    end
    -- 否则获取成员地址
    local addr, size = self:get_addr(id.pointer, id.key)
    -- 创建成员地址对象
    local o = { pointer = id.pointer, addr = addr, key_size = size, key = id.key, name = id.name }
    return setmetatable(o, db.TYPE_ADDR)
end

---获取指针地址
---@private
---@param key any 成员key
---@return integer,integer,integer,any
function db:get_pointer(key)
    -- 定义当前簇深度和簇大小
    local level, block_size = 0, self.block_size
    local addr_size = self.addr_size
    local hash_code = (hash(key) % block_size) + 1 -- 获取hash值
    key = tostring(key) -- key转字符串
    -- 判断数据库可遍历，即留出next属性的空间
    if self.can_each then
        block_size = block_size * 2
        hash_code = hash_code * 2
    end
    -- 计算实际占用空间
    block_size = block_size * addr_size
    -- 计算指针实际位置
    hash_code = hash_code * addr_size

    while true do -- 递归寻址
        local pointer = (level * block_size) + hash_code -- 计算指针位置
        local a, b = self:get_addr(pointer, key) -- 获取地址
        if a then -- 存在即返回，否则下降深度
            return pointer, a, b, key
        end
        level = level + 1 -- 下降深度
    end
end

--- 获取地址
---@private
---@param pointer integer 指针地址
---@param key any 成员key
---@return integer,integer
---@overload fun(pointer:any):integer,integer
function db:get_addr(pointer, key)
    -- 定义变量
    local addr_size, F = self.addr_size, self.F
    local fw, fm = self.fw, self.fm
    -- 定位到指针
    fm:seek('set', pointer)
    -- 读取地址
    local addr = fm:read(addr_size)
    if addr then -- 存在即解包地址
        addr = unpack(F.A, addr)
    else -- 否则定义为0
        addr = 0
    end
    -- 地址为0，即成员不存在，返回等待创建
    if addr == 0 then
        return 0
    else -- 否则判断key
        fw:seek('set', addr) -- 定位到地址
        local n = fw:read(8) -- 读取key长度
        n = unpack(F.T, n) -- 解包
        local s = fw:read(n) -- 读取key
        if s == key then -- 相同即返回，等待操作成员
            return addr, n
        end -- 否则发生碰撞，继续递归
    end
end

--- 指向新的地址
---@private
---@param po integer 指针地址
---@return integer
function db:new_addr(po)
    -- 定义变量
    local addr_size = self.addr_size
    local node_id = self.node_id
    local F = self.F
    local fw, fm = self.fw, self.fm
    -- 定位到指针
    fm:seek('set', po)
    -- 获取数据尾
    local n = fw:seek('end')
    -- 将指针指向数据尾
    fm:write(pack(F.A, n))
    return n -- 返回地址
end

--- 扫描碎片
---@private
---@param size 空间大小
---@return integer
function db:scan_gc(size)
    -- 申明变量
    local F = self.F
    local addr_size = self.addr_size
    local fg = self.fg
    -- 遍历碎片
    fg:seek('set')
    while true do
        -- 读取碎片范围
        local s, e = fg:read(addr_size * 2)
        -- 读到结尾跳出循环
        if not s then
            return 0
        end
        s, e = unpack(F.AA, s) -- 解包
        -- 判断碎片大小合适，复用该碎片
        if e - s >= size then
            fg:seek('cur', -addr_size * 2)
            fg:write(pack(F.A, s + size))
            return s
        end
    end
end

--- 标记碎片
---@private
---@param s0 碎片头
---@param e0 碎片尾
---@return LuaDB
function db:add_gc(s0, e0)
    -- 申明变量
    local F = self.F
    local addr_size = self.addr_size
    local fg = self.fg
    -- 遍历碎片
    fg:seek('set')
    while true do
        local s, e = fg:read(addr_size * 2)
        if not s then -- 碎片不合适，追加新的碎片
            fg:write(pack(F.AA, s0, e0))
            return self
        end
        s, e = unpack(F.AA, s)
        if e - s == 0 then -- 复用空闲碎片
            fg:seek('cur', -addr_size * 2)
            fg:write(pack(F.AA, s0, e0))
            return self
        end
    end
end

--- 检查key类型并调用
---@private
---@param k any|LUADB_ID|LUADB_ADDR
---@return integer,integer,integer
function db:check_key(k)
    -- 处理成员指针和地址
    local p = getmetatable(k)
    if p == db.TYPE_ID then
        local pointer, key = k.pointer, k.key
        local addr, size = self:get_addr(pointer, key)
        return pointer, addr, size, key
    elseif p == db.TYPE_ADDR then
        return k.pointer, k.addr, k.key_size, k.key, k
    end
    -- 处理成员key
    if self.node_id > 6 then
        k = pack(self.F.A, self.node_id) .. tostring(k)
    end
    return self:get_pointer(k)
end

--- 添加next属性
---@private
---@param po integer 指针地址
---@return LuaDB
function db:add_next(po)
    -- 申明变量
    local F = self.F
    local fw, fm = self.fw, self.fm
    local node_id, addr_size = self.node_id, self.addr_size
    -- 判断是否可遍历
    if self.can_each then
        -- 定位起始指针
        fw:seek('set', node_id)
        -- 读取起始指针地址
        local l = fw:read(addr_size)
        l = unpack(F.A, l)
        -- 如果为0，则数据库为空
        if l == 0 then
            -- 写入起始指针与最近指针
            fw:seek('cur', -addr_size)
            fw:write(pack(F.AA, po, po))
        else
            -- 否则读取最近指针
            l = fw:read(addr_size)
            l = unpack(F.A, l)
            -- 最近指针指向新的指针
            fw:seek('cur', -addr_size)
            fw:write(pack(F.A, po))
            -- 定位到旧的最近指针
            fm:seek('set', l + addr_size)
            -- 将新指针写入next属性
            fm:write(pack(F.A, po))
        end
    end
    return self
end

--- 写入数据
---@param k any|LUADB_ID|LUADB_ADDR
---@param v any|LUADB_DB|LUADB_STREAM
---@return LuaDB
function db:set(k, v)
    -- 申明变量
    local F = self.F
    local _v = v
    local fw, fm = self.fw, self.fm
    -- 打包数据
    local tp, len, v, mode = self:pack(v)
    -- 得到成员属性
    local po, addr, size, k, ck = self:check_key(k)
    -- key转换类型，用于判断是否碰撞
    k = tostring(k)
    -- 地址不存在，即创建新地址
    if addr == 0 then
        size = #k
        addr = self:scan_gc(len + 8 + size + 1)
        if addr == 0 then
            addr = self:new_addr(po)
        else
            fm:seek('set', po)
            -- 将指针指向数据尾
            fm:write(pack(F.A, addr))
        end
        self:add_next(po)
    else
        -- 读取原本存储的数据类型和长度
        fw:seek('set', addr + 8 + size)
        local tp, n = unpack(F.B, fw:read(1))
        if tp == 1 or tp == 5 or tp == 7 then
            n = 8 + unpack(F.T, fw:read(8))
        elseif tp == 6 then
            n = self.addr_size * 2
        elseif tp == 2 or tp == 3 then
            n = 8
        elseif tp == 4 then
            n = 1
        else
            n = 0
        end
        -- 处理成员原本空间
        if n < len then -- 空间不够，标记碎片，申请新的空间
            self:add_gc(addr, addr + 8 + size + 1 + n)
            addr = self:scan_gc(len + 8 + size + 1)
            if addr == 0 then
                addr = self:new_addr(po)
            else
                fm:seek('set', po)
                -- 将指针指向数据尾
                fm:write(pack(F.A, addr))
            end
            if ck then
                ck.addr = addr
            end
        elseif n > len then -- 空间过大，截断并标记多余空间
            self:add_gc(addr + len + 8 + size + 1 + 1, addr + 8 + size + 1 + n)
        end
    end
    -- 写入数据
    fw:seek('set', addr)
    fw:write(pack(F.sB, k, tp))
    fw:write(v)
    -- 处理子数据库的初始成员
    if tp == 6 then
        local v0
        for k, v in pairs(_v) do
            if k ~= '__call' then
                if not v0 then
                    v0 = setmetatable({}, db)
                    for k, v in pairs(self) do
                        v0[k] = v
                    end
                    v0.node_id = addr + 8 + size + 1
                end
                v0:set(k, v)
            end
        end
    elseif mode then -- 处理稀疏空间
        fw:seek('cur', len - 9)
        fw:write('\0')
    end
    return self
end

--- 读取数据
---@param k any|LUADB_ID|LUADB_ADDR 成员key
---@return any
function db:get(k)
    -- 获取成员地址与key长度
    local po, addr, size = self:check_key(k)
    if addr == 0 then -- 成员不存在返回nil
        return
    end
    -- 解包数据
    local v = self:unpack(addr + 8 + size)
    return v
end

--- 删除数据 (将成员赋值为空)
---@param k any|LUADB_ID|LUADB_ADDR 成员key
---@return LuaDB
function db:del(k)
    return self:set(k)
end

--- 成员是否存在
---@param k any|LUADB_ID|LUADB_ADDR 成员key
---@return boolean
function db:has(k)
    local po, addr, size = self:check_key(k)
    return addr > 0
end

--- 写入二进制数据
---@param k any|LUADB_ID|LUADB_ADDR 成员key
---@param fmt string 格式串
---@vararg any
---@return LuaDB
function db:fset(k, fmt, ...)
    return self:set(k, pack(fmt, ...))
end

--- 读取二进制数据
---@param k any|LUADB_ID|LUADB_ADDR 成员key
---@param fmt string 格式串
---@return any...
function db:fget(k, fmt)
    local t = { unpack(fmt, self:get(k)) }
    return table_unpack(t, 1, #t - 1)
end

--- 迭代器 返回成员地址对象
---@return fun():LUADB_ADDR
function db:each()
    assert(self.can_each, 'LuaDB::each::该数据库未开启遍历！')
    -- 定义变量
    local addr_size = self.addr_size
    local F = self.F
    local fw, fm = self.fw, self.fm
    local node
    -- 返回迭代函数
    return function()
        -- 第一轮使用起始指针
        if not node then
            fw:seek('set', self.node_id)
            node = fw:read(addr_size)
        else -- 后续使用上轮指针
            fm:seek('set', node + addr_size)
            node = fm:read(addr_size)
        end
        -- 遍历完毕
        if not node then
            return
        end
        -- 解包当前指针
        node = unpack(F.A, node)
        if node == 0 then
            return
        end
        -- 获取当前指针指向的地址
        fm:seek('set', node)
        local addr = fm:read(addr_size)
        addr = unpack(F.A, addr)
        --print(addr)
        -- 得到成员地址的属性
        fw:seek('set', addr)
        local n = fw:read(8)
        n = unpack(F.T, n)
        local s = fw:read(n)
        local name = s -- 处理key名称
        if self.node_id > 6 then
            name = name:sub(addr_size + 1)
        end
        -- 创建成员地址对象
        local o = { pointer = node, addr = addr, key_size = n, key = s, name = name }
        return setmetatable(o, db.TYPE_ADDR)
    end
end

--- 成员数据流
---@param k any|LUADB_ADDR|LUADB_ID 成员key
---@return Stream
function db:stream(k)
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

--- 关闭数据库
---@return LuaDB
function db:close()
    self.fw:close()
    self.fg:close()
    self.fm:close()
    return self
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
function db.TYPE_STREAM:__index(k)
    assert(k ~= 0, 'LuaDB::空间长度不可为0！')
    if k > 0 then
        return pack('c' .. k, '')
    end
    return setmetatable({ -k }, self)
end

--- 子数据库的元方法
---@private
function db.TYPE_DB:__call(t)
    return setmetatable(t, self)
end

---@private
db.__index = db
setmetatable(db.TYPE_DB, db.TYPE_DB)
setmetatable(db.TYPE_STREAM, db.TYPE_STREAM)
return db
