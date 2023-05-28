-- os.execute("@chcp 65001")
package.path = package.path .. ";app\\src\\main\\luaLibs\\?.lua;"
package.path = package.path .. ";Jesse205Library\\src\\main\\luaLibs\\?.lua;"
package.path = package.path .. ";Jesse205Library\\test\\env\\?.lua;"

SP_STR = "---------------------------------------"
local virtualSharedData = {}
activity = {
    getSharedData = function(name)
        local result = virtualSharedData[name]
        print("调用getSharedData", "name = " .. tostring(name), "返回 = " .. tostring(result))
        return result
    end,
    setSharedData = function(name, value)
        print("调用setSharedData", "name = " .. tostring(name), "value = " .. tostring(value))
        virtualSharedData[name] = value
    end
}

getSharedData = activity.getSharedData
setSharedData = activity.setSharedData

local oldPrint = print

local printedStr = ""

function clearPrintedStr()
    printedStr = ""
end

function print(...)
    local list = table.pack(...)
    for i = 1, list.n do
        list[i] = tostring(list[i])
    end

    printedStr = printedStr .. table.concat(list, " ", 1, list.n) .. "\n"
    oldPrint(...)
end

function getPrinted()
    return printedStr
end

function import(package, env)
    env = env or _G
    local className = package:match('([^%.$]+)$')
    env[className] = require(package)
end


function dump(o)
    local t = {}
    local _t = {}
    local _n = {}
    local space, deep = string.rep(' ', 2), 0
    local function _ToString(o, _k)
        if type(o) == ('number') then
            table.insert(t, o)
        elseif type(o) == ('string') then
            table.insert(t, string.format('%q', o))
        elseif type(o) == ('table') then
            local mt = getmetatable(o)
            if mt and mt.__tostring then
                table.insert(t, tostring(o))
            else
                deep = deep + 2
                table.insert(t, '{')

                for k, v in pairs(o) do
                    if v == _G then
                        table.insert(t, string.format('\r\n%s%s\t=%s ;', string.rep(space, deep - 1), k, "_G"))
                    elseif v ~= package.loaded then
                        if tonumber(k) then
                            k = string.format('[%s]', k)
                        else
                            k = string.format('[\"%s\"]', k)
                        end
                        table.insert(t, string.format('\r\n%s%s\t= ', string.rep(space, deep - 1), k))
                        if v == NIL then
                            table.insert(t, string.format('%s ;',"nil"))
                        elseif type(v) == ('table') then
                            if _t[tostring(v)] == nil then
                                _t[tostring(v)] = v
                                local _k = _k .. k
                                _t[tostring(v)] = _k
                                _ToString(v, _k)
                            else
                                table.insert(t, tostring(_t[tostring(v)]))
                                table.insert(t, ';')
                            end
                        else
                            _ToString(v, _k)
                        end
                    end
                end
                table.insert(t, string.format('\r\n%s}', string.rep(space, deep - 1)))
                deep = deep - 2
            end
        else
            table.insert(t, tostring(o))
        end
        table.insert(t, " ;")
        return t
    end

    t = _ToString(o, '')
    return table.concat(t)
end
