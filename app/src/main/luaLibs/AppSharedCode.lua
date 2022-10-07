function getConfigFromFile(path)
  local env={}
  assert(loadfile(tostring(path),"bt",env))()
  return env
end

function LuaLexerIteratorBuilder(code)
  local lexer=LuaLexer(code)
  return function()
    local advance=lexer.advance()
    local text=lexer.yytext()
    local column=lexer.yycolumn()
    return advance,text,column
  end
end


local richAnim=getSharedData("richAnim")
local oldNewLayoutTransition=newLayoutTransition
function newLayoutTransition()
  if richAnim then
    return oldNewLayoutTransition()
  end
end

function openUrl(url)
  xpcall(function()
    import "androidx.browser.customtabs.CustomTabsIntent"
    CustomTabsIntent.Builder()
    .setToolbarColor(theme.color.colorPrimary)
    .build()
    .launchUrl(activity, Uri.parse(url))
  end,
  function()
    openInBrowser(url)
  end)
end

--加载全局插件
function onCreate(savedInstanceState)
  PluginsUtil.callElevents("onCreate", savedInstanceState)
end

apptype="aidelua"

import "PluginsUtil"

