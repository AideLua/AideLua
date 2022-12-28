if getSharedData("antiAddictionMode") then
  if not application.get("antiAddictionModeReceiver") then
    function checkTime()
      if tonumber(os.date("%H"))~=12 or os.date("%A")~="Saturday" and os.date("%A")~="Sunday" then
        os.exit()
      end
    end
    import "android.content.BroadcastReceiver"
    import "android.content.IntentFilter"
    local filter = IntentFilter()
    filter.addAction(Intent.ACTION_TIME_TICK)
    filter.addAction(Intent.ACTION_TIME_CHANGED)

    local receiver=BroadcastReceiver({
      onReceive=function(context,intent)
        checkTime()
      end,
    })
    application.registerReceiver(receiver,filter)
    application.set("antiAddictionModeReceiver",receiver)
    checkTime()
  end
end

function getConfigFromFile(path,env)
  env=env or {}
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
    .setShowTitle(true)
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

