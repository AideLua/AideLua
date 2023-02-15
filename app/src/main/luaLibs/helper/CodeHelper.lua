--v5.1.1+
local CodeHelper={}

function CodeHelper.getImportCode(className)
  return string.format("import \"%s\"",className)
end

function CodeHelper.LuaLexerIteratorBuilder(code)
  local lexer=LuaLexer(code)
  return function()
    local advance=lexer.advance()
    local text=lexer.yytext()
    local column=lexer.yycolumn()
    return advance,text,column
  end
end

return CodeHelper
