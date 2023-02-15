--文档Url
DOCS_URL="https://aidelua.github.io/AideLua/"
REPOSITORY_URL="https://gitee.com/AideLua/AideLua"
PAGE_URL="https://aidelua.github.io/"

if getSharedData("antiAddictionMode") then
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

  local receiver
  receiver=BroadcastReceiver({
    onReceive=function(context,intent)
      if activity.isFinishing() then--当activity正在退出的时候，注销广播
        application.unregisterReceiver(receiver)
       else
        checkTime()
      end
    end,
  })
  application.registerReceiver(receiver,filter)
  checkTime()
end

function getConfigFromFile(path,env)
  env=env or {}
  assert(loadfile(tostring(path),"bt",env))()
  return env
end

local richAnim=getSharedData("richAnim")
local newLayoutTransitionSuper=newLayoutTransition
function newLayoutTransition()
  if richAnim then
    return newLayoutTransitionSuper()
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

