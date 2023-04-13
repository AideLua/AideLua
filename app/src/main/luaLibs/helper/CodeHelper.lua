--v5.1.1+
---代码助手
local CodeHelper = {}

---获取导入类的代码
---@param className string
---@return string importCode 导入代码
function CodeHelper.getImportCode(className)
    return string.format("import \"%s\"", className)
end

---Lua 语法解析迭代器
---@param code string
---@return function
function CodeHelper.LuaLexerIteratorBuilder(code)
    local lexer = LuaLexer(code)
    return function()
        local advance = lexer.advance()
        local text = lexer.yytext()
        local column = lexer.yycolumn()
        return advance, text, column
    end
end

return CodeHelper
