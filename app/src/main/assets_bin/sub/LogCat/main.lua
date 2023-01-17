require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.widget.ListView"
import "android.graphics.Typeface"
import "android.text.Spannable"
import "android.text.SpannableString"
import "android.text.style.ForegroundColorSpan"
import "android.text.style.BackgroundColorSpan"
import "android.text.style.TypefaceSpan"
import "themeutil"

themeutil.applyTheme()

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
local isRefreshing=false
local canCallSelected=false

type2color={
  V=0xFF000000,
  D=0xff2196f3,
  I=0xff4caf50,
  W=0xffff9800,
  E=0xfff44336
}

function onCreateOptionsMenu(menu)
  refreshMenu=menu.add("刷新")
  clearMenu=menu.add("清空全部")
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  local title=item.title
  if id==android.R.id.home then
    activity.finish()
   elseif item==refreshMenu then
    refreshLog()
   elseif item==clearMenu then
    runClearLog()
  end
end

function show(content)--展示日志
  local canScroll=listView.canScrollVertically(1)
  adapter.clear()
  progressBar.setVisibility(View.GONE)
  listView.setVisibility(View.VISIBLE)
  canCallSelected=false
  actionBar.setSelectedNavigationItem(nowPriorityIndex-1)
  canCallSelected=true
  isRefreshing=false
  if content and #content~=0 then
    local nowTitle=""
    local nowTag=""
    local nowContent=""
    for line in content:gmatch("(.-)\n") do
      if line:find("^%-%-%-%-%-%-%-%-%- beginning of ") then
        adapter.add({__type=1,title=line})
       elseif line:find("^%[ *%d+%-%d+ *%d+:%d+:%d+%.%d+ *%d+: *%d+ *%a/[^ ]+ *%]$") then
        local date,time,processId,threadId,logType,logTag=line:match("^%[ *(%d+%-%d+) *(%d+:%d+:%d+%.%d+) *(%d+): *(%d+) *(%a)/([^ ]+) *%]$")
        --print(date,time,processId,threadId,logType,logTag)
        local title
        if logTag~="LuaInvocationHandler" then
          title="[ "..date.." "..time.." "..processId..":"..threadId.."  "
          local typeIndex=utf8.len(title)
          title=title..logType.." /"..logTag.." ]"
          title=SpannableString(title)
          title.setSpan(BackgroundColorSpan(type2color[logType] or 0xff9e9e9e),typeIndex-1,typeIndex+2,Spannable.SPAN_INCLUSIVE_INCLUSIVE)
          title.setSpan(ForegroundColorSpan(0xFFFFFFFF),typeIndex-1,typeIndex+2,Spannable.SPAN_INCLUSIVE_INCLUSIVE)
          title.setSpan(TypefaceSpan("monospace"),typeIndex-1,typeIndex+2,Spannable.SPAN_INCLUSIVE_INCLUSIVE)
        end
        if nowContent~="" and nowTag~="LuaInvocationHandler" then
          adapter.add({__type=2,title=nowTitle,content=String(nowContent).trim()})
        end
        nowTitle=title--line
        nowTag=logTag
        nowContent=""
       else
        nowContent=nowContent.."\n"..line
      end
    end
   else
    adapter.add({__type=1,title="<运行应用程序以查看其日志输出>"})
  end
  actionBar.setSubtitle(os.date("%Y-%m-%d %H:%M:%S."..System.currentTimeMillis()%1000))
  if not(canScroll) then
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
  listView.setVisibility(View.GONE)
  actionBar.setSubtitle(nil)
  task(readLog,filterParameters[index],show)
end

function runClearLog()
  if not isRefreshing then
    isRefreshing=true
    progressBar.setVisibility(View.VISIBLE)
    --listView.setVisibility(View.GONE)
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
      --typeface=Typeface.MONOSPACE;
    };
  }
}

listView=ListView(activity)
listView.setFastScrollEnabled(true)
if themeutil.isJesse205Activity then--Jesse205主题没有分割线
  listView.setDivider(dividerVertical)
  listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
    MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount)
  end
end

adapter=LuaMultiAdapter(activity,item)
listView.setAdapter(adapter)

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