local CodeHelper={}

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
