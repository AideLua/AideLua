require "import"
import "android.widget.ListView"
import "android.graphics.Typeface"

isJesse205Activity=pcall(function()
  import "jesse205"
end)
isSupportActivity=pcall(function()
  androidx={appcompat={R=luajava.bindClass("androidx.appcompat.R")}}
end)
isEmuiSystem=pcall(function()
  androidhwext={R=luajava.bindClass("androidhwext.R")}
end)


function toboolean(content)
  if content then
    return true
   else
    return false
  end
end
function setTheme(success,func)
  if not(success) then
    success=pcall(func)
  end
  return toboolean(success)
end

function getActionBarState()
  local array = activity.getTheme().obtainStyledAttributes({
    android.R.attr.windowActionBar
  })
  local windowActionBar=array.getBoolean(0,false)
  array.recycle()
  return windowActionBar
end
function getSupportActionBarState()
  local array = activity.getTheme().obtainStyledAttributes({
    androidx.appcompat.R.attr.windowActionBar
  })
  local windowActionBar=array.getBoolean(0,false)
  array.recycle()
  return windowActionBar
end

local dp2intCache={}
function math.dp2int(dpValue)
  local cache=dp2intCache[dpValue]
  if cache then
    return cache
   else
    import "android.util.TypedValue"
    local cache=TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue, activity.resources.getDisplayMetrics())
    dp2intCache[dpValue]=cache
    return cache
  end
end


--设置主题
if not(isJesse205Activity) then
  import "android.app.*"
  import "android.os.*"
  import "android.widget.*"
  import "android.view.*"
  import "android.content.*"
  local success=false
  if isSupportActivity then
    success=setTheme(getSupportActionBarState(),function()
      activity.setTheme(androidx.appcompat.R.style.Theme_AppCompat_DayNight)
    end)
    actionBar=activity.getSupportActionBar()
   else
    setTheme(getActionBarState(),function()
      success=setTheme(success,function()
        activity.setTheme(androidhwext.R.style.Theme_Emui)
      end)
      success=setTheme(success,function()
        activity.setTheme(android.R.style.Theme_DeviceDefault_DayNight)
      end)
      success=setTheme(success,function()
        activity.setTheme(android.R.style.Theme_Material_Light)
      end)
      success=setTheme(success,function()
        activity.setTheme(android.R.style.Theme_Holo)
      end)
    end)
    actionBar=activity.getActionBar()
  end
end

local array = activity.getTheme().obtainStyledAttributes({
  android.R.attr.textColorPrimary,
  android.R.attr.textColorSecondary,
  android.R.attr.colorAccent,
  android.R.attr.dividerVertical,
})
textColorPrimary=array.getColor(0,0)
textColorSecondary=array.getColor(1,0)
colorAccent=array.getColor(2,0)
dividerVertical=array.getDrawable(3)
array.recycle()

actionBar.setDisplayHomeAsUpEnabled(true)
actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS)

local filterNames={"全部","Lua","Test","Tcc","Error","Warning","Info","Debug","Verbose"}
local filterParameters={"","lua:* *:S","test:* *:S","tcc:* *:S","*:E","*:W","*:I","*:D","*:V"}
local nowPriorityIndex=2
local isBottom=true
local isRefreshing=false
local canCallSelected=false

function onCreateOptionsMenu(menu)
  clearMenu=menu.add("清空全部")
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  local title=item.title
  if id==android.R.id.home then
    activity.finish()
   elseif item==clearMenu then
    runClearLog()
  end
end

function show(content)--展示日志
  local isBottom=isBottom
  adapter.clear()
  progressBar.setVisibility(View.GONE)
  canCallSelected=false
  actionBar.setSelectedNavigationItem(nowPriorityIndex-1)
  canCallSelected=true
  isRefreshing=false
  if content and #content~=0 then
    local nowTitle=""
    local nowContent=""
    for line in content:gmatch("(.-)\n") do
      if line:find("^%-%-%-%-%-%-%-%-%- beginning of ") then
        adapter.add({__type=1,title=line})
       elseif line:find("^%[ *%d+%-%d+ *%d+:%d+:%d+%.%d+ *%d+: *%d+ *%a/[^ ]+ *%]$") then
        if nowContent~="" then
          adapter.add({__type=2,title=nowTitle,content=String(nowContent).trim()})
        end
        nowTitle=line
        nowContent=""
       else
        nowContent=nowContent.."\n"..line
      end
    end
   else
    adapter.add({__type=1,title="<运行应用程序以查看其日志输出>"})
  end
  actionBar.setSubtitle(os.date("%Y-%m-%d %H:%M:%S."..System.currentTimeMillis()%1000))
  if isBottom then
    listView.setSelection(adapter.getCount()-1)
  end
end

function readLog(value)--读取日志
  local p=io.popen("logcat -d -v long "..value)
  local content=p:read("*a")
  p:close()
  return content
end

function clearLog()--清除日志
  local p=io.popen("logcat -c")
  p:close()
end

function refreshLog(index)
  index=index or nowPriorityIndex
  isRefreshing=true
  progressBar.setVisibility(View.VISIBLE)
  task(readLog,filterParameters[index],show)
end

function runClearLog()
  if not isRefreshing then
    isRefreshing=true
    progressBar.setVisibility(View.VISIBLE)
    task(clearLog,refreshLog)
  end
end

function onTabSelected(tab)
  if canCallSelected then
    local filterIndex=tab.tag
    if not isRefreshing then
      nowPriorityIndex=filterIndex
      refreshLog(filterIndex)
    end
  end
end

for index,content in ipairs(filterNames) do
  local tab=actionBar.newTab()
  tab
  .setTag(index)
  .setText(content)
  .setTabListener({onTabSelected=onTabSelected,
    onTabReselected=onTabSelected,
    onTabUnselected=function(tab)
      if canCallSelected and isRefreshing then
        Handler().postDelayed(Runnable({
          run=function()
            actionBar.setSelectedNavigationItem(nowPriorityIndex-1)
          end
        }),1)
      end
  end})
  actionBar.addTab(tab)
end
canCallSelected=true


item={
  {
    TextView;
    textIsSelectable=true;
    textSize="14sp";
    padding="8dp";
    id="title";
    textColor=colorAccent;
    typeface=Typeface.defaultFromStyle(Typeface.BOLD);
  },
  {--条目
    LinearLayout;
    layout_width="fill";
    orientation="vertical";
    padding="8dp";
    {
      TextView;
      textIsSelectable=true;
      textSize="12sp";
      id="title";
      textColor=textColorPrimary;
      typeface=Typeface.defaultFromStyle(Typeface.BOLD);
    };
    {
      TextView;
      textIsSelectable=true;
      textSize="12sp";
      id="content";
      textColor=textColorPrimary;
    };
  }
}

listView=ListView(activity)
listView.setFastScrollEnabled(true)
if isJesse205Activity then--Jesse205主题没有分割线
  listView.setDivider(dividerVertical)
end

adapter=LuaMultiAdapter(activity,item)
listView.setAdapter(adapter)

listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  if MyAnimationUtil then
    MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,topCard)
  end
  isBottom=(firstVisibleItem+visibleItemCount ==totalItemCount) and (totalItemCount>0)
end

if CoordinatorLayout then
  mainLay=CoordinatorLayout(activity)
 else
  mainLay=FrameLayout(activity)
end

mainLay.addView(listView)
local linearParams=listView.getLayoutParams()
linearParams.height=-1
linearParams.width=-1
listView.setLayoutParams(linearParams)

progressBar=ProgressBar(activity,nil,android.R.attr.progressBarStyleLarge)
mainLay.addView(progressBar)
local linearParams=progressBar.getLayoutParams()
linearParams.height=math.dp2int(72)
linearParams.width=math.dp2int(72)
linearParams.gravity=Gravity.CENTER

progressBar.setLayoutParams(linearParams)

activity.setContentView(mainLay)

local linearParams=mainLay.getLayoutParams()
linearParams.height=-1
linearParams.width=-1
mainLay.setLayoutParams(linearParams)

actionBar.setSelectedNavigationItem(1)

