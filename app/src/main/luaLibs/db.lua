local db, sdb, stream = {}, {}, {}

local setmetatable, tostring, type, pairs, error, load = setmetatable, tostring, type, pairs, error, load

local table, io, string, math = table, io, string, math

local pack, unpack, packsize = string.pack, string.unpack, string.packsize

local byte_order = ''
local block_size = 32768

local F = {'T', 'TT', 'B', 's', 'n', 'sB'}

setmetatable(db, db)

local function hash(s, n)
    if math.type(s) == 'integer' then
        return s % (n / 8)
    end
    s = tostring(s)
    local l = #s
    local h = l
    local step = (l >> 5) + 1

    for i = l, step, -step do
        h = h ~ ((h << 5) + string.byte(s, i) + (h >> 2))
    end
    return h % (n / 8)
end

function db:__index(k)
    if type(k) == 'number' then
        if k > 0 then
            local fmt = string.format('c%d', k)
            return pack(fmt, '')
        elseif k < 0 then
            return {db, -k}
        end
        return ''
    end
end

function db.open(path)
    byte_order = db.byte_order or byte_order
    block_size = db.block_size or block_size
    block_size = block_size // 8 * 8

    for i = 1, #F do
        local v = F[i]
        F[v] = byte_order .. v
    end

    local self = {
        path = path,
        __index = db,
        hash = ""
    }
    setmetatable(self, self)
    local f = io.open(path)
    if not f then
        self:reset()
    else
        f:close()
        self:init()
    end
    return self
end

function db:reset()
    io.open(self.path, 'w'):close()
    io.open(self.path .. '.gc', 'w'):close()
    io.open(self.path .. '.map', 'w'):close()
    self:init()
    return self
end

function db:init()
    self.fw = io.open(self.path, 'r+b')
    self.fw:setvbuf('no')
    self.fg = io.open(self.path .. '.gc', 'r+b')
    self.fg:setvbuf('no')
    self.fm = io.open(self.path .. '.map', 'r+b')
    self.fm:setvbuf('no')
    return self
end

function db:id(key, is)
    if type(key) == 'table' then
        if key.exist ~= nil then
            local a, b, c = self:addr(key.pointer, true, key.key)
            return a, b, c, key.key
        end
    end
    local level = 0
    local hash = hash(key, block_size)
    while true do
        local pointer = (level * block_size) + (hash * 8)
        local a, b, c = self:addr(pointer, is, key)
        if a then
            return a, b, c, key
        end
        level = level + 1
    end
end

function db:addr(pointer, is, key)
    local pointer = self.fm:seek('set', pointer)
    local addr = self.fm:read(8)
    if addr then
        addr = unpack(F.T, addr)
    else
        addr = 0
    end
    if addr == 0 then
        if is then
            return pointer, 0
        end
        return {
            exist = false,
            pointer = pointer,
            key = key
        }
    else
        self.fw:seek('set', addr)
        local n = self.fw:read(8)
        if n then
            n = unpack(F.T, n)
        else
            n = 0
        end
        local s, f
        if key then
            s = self.fw:read(n)
            f = s == tostring(key)
        else
            f = true
        end
        if f then
            if is then
                return pointer, addr, n
            end
            return {
                exist = true,
                pointer = pointer,
                key = key
            }
        end
    end
end

function db:new_addr(po)
    self.fm:seek('set', po)
    local n = self.fw:seek 'end' + 1
    self.fm:write(pack(F.T, n))
    return n
end

function db:scan_gc(size)
    self.fg:seek('set')
    while true do
        local s, e = self.fg:read(16)
        if not s then
            return 0
        end
        s, e = unpack(F.TT, s)
        if e - s >= size then
            self.fg:seek('cur', -16)
            self.fg:write(pack(F.T, s + size))
            return s
        end
    end
end

function db:add_gc(s0, e0)
    self.fg:seek('set')
    while true do
        local s, e = self.fg:read(16)
        if not s then
            self.fg:write(pack(F.TT, s0, e0))
            return self
        end
        s, e = unpack(F.TT, s)
        if e - s == 0 then
            self.fg:seek('cur', -16)
            self.fg:write(pack(F.TT, s0, e0))
            return self
        end
    end
end

function db:has(k)
    local _, addr, size = self:id(k, true)
    if addr > 0 then
        self.fw:seek('set', addr + 8 + size)
        local tp = unpack(F.B, self.fw:read(1))
        return tp > 0
    end
    return false
end

function db:remove(k)
    return self:put(k, nil)
end

function db:put(k, v)
    local tp, len, is = type(v), 0
    if tp == 'nil' then
        tp = 0
        v = ''
        len = 0
    elseif tp == 'string' then
        tp = 1
        v = pack(F.s, v)
        len = #v
    elseif tp == 'number' then
        tp = 2
        len = 8
        v = pack(F.n, v)
    elseif tp == 'boolean' then
        tp = 3
        len = 1
        v = v and '\1' or '\0'
    elseif tp == 'table' then
        if v[1] == db then
            tp = 1
            len = 8 + v[2]
            v = pack(F.T, v[2])
            is = true
        else
            tp = 4
            local code = string.format('%s$%s', self.hash, k)
            for k, v in pairs(v) do
                if math.type(k) == 'integer' then
                    k = math.tointeger(k)
                end
                k = string.format('%s$%s', code, k)
                self:put(k, v)
            end
            v = pack(F.s, code)
            len = #v
        end
    elseif tp == 'function' then
        tp = 5
        v = pack(F.s, string.dump(v, true))
        len = #v
    else
        error('db::不支持的类型::' .. tp)
    end

    local po, addr, size, k = self:id(k, true)
    k = tostring(k)
    if addr == 0 then
        addr = self:scan_gc(len + 8 + #k + 1)
        if addr == 0 then
            addr = self:new_addr(po)
        end
    else
        self.fw:seek('set', addr + 8 + size)
        local tp, n = unpack(F.B, self.fw:read(1))
        if tp == 1 or tp == 5 or tp == 4 then
            n = 8 + unpack(F.T, self.fw:read(8))
        elseif tp == 2 then
            n = 8
        elseif tp == 3 then
            n = 1
        else
            n = 0
        end

        if n < len then
            self:add_gc(addr, addr + 8 + size + 1 + n)
            addr = self:scan_gc(len + 8 + size + 1)
            if addr == 0 then
                addr = self:new_addr(po)
            end
        elseif n > len then
            self:add_gc(addr + len + 8 + size + 1, addr + 8 + size + 1 + n)
        end
    end

    self.fw:seek('set', addr)
    self.fw:write(pack(F.sB, k, tp))
    self.fw:write(v)

    if is then
        self.fw:seek('cur', len - 9)
        self.fw:write('\0')
    end

    return self
end

function db:get(k)
    local _, addr, size = self:id(k, true)
    if addr == 0 then
        return
    end
    self.fw:seek('set', addr + 8 + size)
    local tp = unpack(F.B, self.fw:read(1))
    if tp == 1 then
        local n = unpack(F.T, self.fw:read(8))
        return self.fw:read(n)
    elseif tp == 2 then
        return (unpack(F.n, self.fw:read(8)))
    elseif tp == 3 then
        return self.fw:read(1) == '\1'
    elseif tp == 4 then
        local n = unpack(F.T, self.fw:read(8))
        local obj = {
            parent = self,
            hash = self.fw:read(n),
            __index = sdb
        }
        return setmetatable(obj, obj)
    elseif tp == 5 then
        local n = unpack(F.T, self.fw:read(8))
        return load(self.fw:read(n))
    end
end

function db:stream(k)
    local _, addr, size = self:id(k, true)
    if addr == 0 then
        return
    end
    self.fw:seek('set', addr + 8 + size)
    local tp = unpack(F.B, self.fw:read(1))
    if tp ~= 1 then
        return
    end
    local n = unpack(F.T, self.fw:read(8))

    local obj = {
        s = addr + 8 + size + 9,
        e = addr + 8 + size + 9 + n,
        p = addr + 8 + size + 9,
        len = n,
        fw = self.fw,
        __len = stream.size,
        __index = stream
    }
    return setmetatable(obj, obj)
end

function db:fput(k, fmt, ...)
    return self:set(k, pack(fmt, ...))
end

function db:fget(k, fmt)
    local v = self:get(k)
    if type(v) ~= 'string' then
        return
    end
    local t = {unpack(fmt, v)}
    t[#t] = nil
    return table.unpack(t)
end

function db:close()
    self.fw:close()
    self.fg:close()
    self.fm:close()
    return self
end

function sdb:id(k)
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    return self.parent:id(k)
end

function sdb:has(k)
    if type(k) == 'table' then
        if k.exist ~= nil then
            return self.parent:has(k)
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    return self.parent:has(k)
end

function sdb:remove(k)
    if type(k) == 'table' then
        if k.exist ~= nil then
            return self.parent:remove(k)
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    return self.parent:remove(k)
end

function sdb:stream(k)
    if type(k) == 'table' then
        if k.exist ~= nil then
            return self.parent:stream(k)
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    return self.parent:stream(k)
end

function sdb:put(k, v)
    if type(k) == 'table' then
        if k.exist ~= nil then
            self.parent:put(k, v)
            return self
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    self.parent:put(k, v)
    return self
end

function sdb:get(k)
    if type(k) == 'table' then
        if k.exist ~= nil then
            return self.parent:get(k)
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    return self.parent:get(k)
end

function sdb:fput(k, fmt, ...)
    if type(k) == 'table' then
        if k.exist ~= nil then
            self.parent:fput(k, fmt, ...)
            return self
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    self.parent:fput(k, fmt, ...)
    return self
end

function sdb:fget(k, fmt)
    if type(k) == 'table' then
        if k.exist ~= nil then
            return self.parent:fget(k, fmt)
        end
    end
    if math.type(k) == 'integer' then
        k = math.tointeger(k)
    end
    k = string.format('%s$%s', self.hash, k)
    return self.parent:fget(k, fmt)
end

function stream:size()
    return self.len
end

function stream:seek(mode, n)
    local s, e, p = self.s, self.e, self.p
    if mode == 'set' then
        n = n or 1
        p = s + n - 1
    elseif mode == 'cur' then
        n = n or 0
        p = p + n
    elseif mode == 'end' then
        n = n or -1
        p = e + n + 1
    end
    if p < s or p > e then
        error('db::数据越界！')
    end
    self.p = p
    return p - s + 1
end

function stream:write(fmt, ...)
    if ... then
        fmt = pack(fmt, ...)
    end
    self.fw:seek('set', self.p)
    self.fw:write(fmt)
    self:seek('cur', #fmt)
    return self
end

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
        s = {unpack(fmt, s)}
        s[#s] = nil
        return table.unpack(s)
    end
    return s
end

db.set = db.put
db.fset = db.fput
sdb.set = sdb.put
sdb.fset = sdb.fput

return db
