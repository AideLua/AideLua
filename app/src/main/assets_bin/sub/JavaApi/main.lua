-- 在 v5.1.0(51099) 搜索框改到标题栏内
require "import"
useCustomAppToolbar=true
import "jesse205"
import "android.widget.ListView"
import "androidx.core.view.ViewCompat"
import "androidx.core.view.WindowInsetsCompat"
import "androidx.core.graphics.ColorUtils"
import "android.graphics.drawable.ColorDrawable"
import "android.animation.ObjectAnimator"
import "com.google.android.material.appbar.AppBarLayout"
import "com.google.android.material.appbar.MaterialToolbar"

--import "com.jesse205.widget.AutoToolbarLayout"
import "com.jesse205.adapter.MyLuaAdapter"
import "com.jesse205.layout.MySearchBar"
import "androidApis.editor.systemApis"
import "showPackageMenu"

import "item"

PluginsUtil.setActivityName("javaapi")

searching=false
nowDevice="phone"

local actionBarState=true
local actionBarAnimator
local canPlayActionBarAnimation=true

activity.setTitle(R.string.javaApiViewer)
activity.setContentView(loadlayout2("layout"))

activity.setSupportActionBar(toolbar)
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)

function onCreate(savedInstanceState)
  PluginsUtil.callElevents("onCreate", savedInstanceState)
  onNewIntent(activity.getIntent())
  search("")
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end

function onNewIntent(intent)
  local bundle=intent.getExtras()
  local arg=bundle.get("arg")
  if arg then
    local searchWord=arg[0]
    local trueWord=""
    if searchWord then
      trueWord="%."..searchWord.."$"
    end
    search(trueWord,function(classesList)
      if searchWord then
        if #classesList==1 then
          newSubActivity("ViewClass",{searchWord})
         elseif #classesList==2 then
          newSubActivity("ViewClass",{classesList[2].text})
        end
      end
    end)
    searchEdit.text=trueWord
  end
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onResult(name,err)
  if err then
    MyToast(err)
  end
end

function searchTaskFunc(text,application)
  require "import"
  local allClasses=application.get("classes_table")
  if allClasses then
    allClasses=luajava.astable(allClasses)
   else
    import "androidApis.androidxApis"
    import "androidApis.systemApis"
    import "androidApis.androluaApis"
    local insertedClasses={}
    allClasses={}
    function addAndroidClasses(classes,rootPath)
      for index,className in pairs(classes) do
        if type(index)=="number" then
          --local className=content:match(".+[%.$](.+)")
          local class=rootPath..className
          if not(insertedClasses[class]) then
            table.insert(allClasses,class)
          end
         else
          addAndroidClasses(className,rootPath..index..".")
        end
      end
    end

    for index,content in ipairs({androidxApis,systemApis,androluaApis}) do
      addAndroidClasses(content,"")
    end
    table.insert(allClasses,activity.getPackageName()..".R")
    table.sort(allClasses,function(a,b)
      return string.lower(a)<string.lower(b)
    end)
    application.set("classes_table",String(allClasses))
  end


  local findClasses={}
  local isEmptyText=text==""
  if not(isEmptyText) then
    table.insert(findClasses,{text=text})
  end
  local lowerText=string.lower(text)
  for index,content in ipairs(allClasses) do
    if (isEmptyText or string.lower(content):find(lowerText)) and content~=text then
      table.insert(findClasses,{text=content})
    end
  end
  return findClasses
end


local showProgressBarHandler=Handler()
local showProgressBarRunnable=Runnable({
  run=function()
    if searching then
      progressBar.setVisibility(View.VISIBLE)
    end
  end
})

function search(text,callback)
  if not(searching) then
    if checkTextError(text) then
      return
    end
    searching=true
    --延迟展示进度条
    showProgressBarHandler.postDelayed(showProgressBarRunnable,100)

    activity.newTask(searchTaskFunc,function(classesList)
      searching=false
      local classesList=luajava.astable(classesList)
      adp.clear()
      adp.addAll(classesList)
      adp.notifyDataSetChanged()
      progressBar.setVisibility(View.GONE)
      --searchButton.clickable=true
      if callback then
        callback(classesList)
      end
    end).execute({tostring(text),application})
  end
end

function checkTextError(text)
  local success,err=pcall(string.find,"",text)
  if success then
    searchEdit
    .setError(nil)
   else
    searchEdit
    .setError(err)
  end
  return not success
end

function onAnimUpdate(hideOffset)
  local actionBarHeight=appBarLayout.getHeight()
  if actionBarHeight<=0 then
    return
  end
  local progress=1+hideOffset/actionBarHeight
  toolbar.setAlpha(progress*progress)
  appBarLayout.setTranslationY(hideOffset)
  --searchLayout.setTranslationY(hideOffset)
  progressBar.setTranslationY(hideOffset)
  if hideOffset==-actionBarHeight then
    toolbar.setVisibility(View.INVISIBLE)
   else
    toolbar.setVisibility(View.VISIBLE)
  end
  MyAnimationUtil.ListView.onScroll(listView,listView.getFirstVisiblePosition(),nil,nil,appBarLayout,nil,false,appBarLayout.getHeight()+hideOffset)
end

function showActionBar(force)
  if (not actionBarState or force) and canPlayActionBarAnimation then
    if actionBarAnimator then
      actionBarAnimator.cancel()
    end
    if nowDevice~="phone" then
      appBarLayout.setTranslationY(0)
      onAnimUpdate(0)
      actionBarState=true
      return
    end
    actionBarState=true
    actionBarAnimator = ObjectAnimator.ofFloat(appBarLayout,"translationY",{0})
    .setDuration(200)
    .setAutoCancel(true)
    .addUpdateListener({
      onAnimationUpdate=function(animator)
        onAnimUpdate(animator.getAnimatedValue())
      end
    })
    .start()
  end
end

function hideActionBar(force)
  if (actionBarState or force) and canPlayActionBarAnimation then
    if actionBarAnimator then
      actionBarAnimator.cancel()
    end
    if nowDevice~="phone" then
      appBarLayout.setTranslationY(0)
      onAnimUpdate(0)
      actionBarState=true
      return
    end
    actionBarState=false
    actionBarAnimator = ObjectAnimator.ofFloat(appBarLayout,"translationY",{-appBarLayout.getHeight()})
    .setDuration(200)
    .setAutoCancel(true)
    .addUpdateListener({
      onAnimationUpdate=function(animator)
        onAnimUpdate(animator.getAnimatedValue())
      end
    })
    .start()
  end
end

--设置ListView的padding
local width=View.MeasureSpec.makeMeasureSpec(0,View.MeasureSpec.UNSPECIFIED)
local height=View.MeasureSpec.makeMeasureSpec(0,View.MeasureSpec.UNSPECIFIED)
searchLayout.measure(width,height)
appBarLayout.measure(width,height)
local searchLayoutHeight=searchLayout.getMeasuredHeight()
local appBarLayoutHeight=appBarLayout.getMeasuredHeight()

if nowDevice=="phone" then
  listView.setPadding(0,appBarLayoutHeight+searchLayoutHeight,0,0)
 else
  listView.setPadding(0,appBarLayoutHeight,0,0)
end

local searchEditDownY=0
local searchEditDownOffset=0
--拽拖顶栏触摸事件
topLayoutOnTouchListener=View.OnTouchListener{
  onTouch=function(view,event)
    if nowDevice~="phone" then
      appBarLayout.setTranslationY(0)
      onAnimUpdate(0)
      actionBarState=true
      return
    end
    local y=event.getRawY()
    local action=event.getAction()
    local actionBarHeight=appBarLayout.getHeight()
    if action==MotionEvent.ACTION_DOWN then
      if actionBarAnimator then
        actionBarAnimator.cancel()
      end
      searchEditDownY=y
      searchEditDownOffset=appBarLayout.getTranslationY()
      canPlayActionBarAnimation=false
     elseif action==MotionEvent.ACTION_MOVE then
      local offset=y-searchEditDownY+searchEditDownOffset
      if offset>0 then
        offset=0
       elseif offset<-actionBarHeight
        offset=-actionBarHeight
      end
      onAnimUpdate(offset)
      if searchEditDownY~=y then
        view.cancelLongPress()
      end
     elseif action==MotionEvent.ACTION_UP or action==MotionEvent.ACTION_CANCEL then
      canPlayActionBarAnimation=true
      local offset=y-searchEditDownY+searchEditDownOffset
      --播放释放动画
      if offset>=0 then
        actionBarState=true
       elseif offset<=-actionBarHeight then
        actionBarState=false
       else
        --仅当有偏移时播放动画
        if offset>-actionBarHeight/2 then
          showActionBar(true)
         else
          hideActionBar(true)
        end
      end
    end
  end
}

ClearContentHelper.setupEditor(searchEdit,clearSearchBtn,res.color.attr.rippleColorPrimary)

--搜索按钮波纹
local drawable=ThemeUtil.getRippleDrawable(res.color.attr.rippleColorAccent)
if Build.VERSION.SDK_INT>=23 then
  drawable.mutate().setRadius(math.dp2int(20))
end
searchButton.setBackground(drawable)

searchAdapter=ArrayAdapter(activity,android.R.layout.simple_dropdown_item_1line,systemApis)
searchEdit.setAdapter(searchAdapter)

--添加触摸移动搜索框
toolbar.setOnTouchListener(topLayoutOnTouchListener)
searchEdit.setOnTouchListener(topLayoutOnTouchListener)
searchLayout.setOnTouchListener(topLayoutOnTouchListener)

datas={}
adp=MyLuaAdapter(activity,datas,item)
listView.setAdapter(adp)

listView.onItemClick=function(id,v,zero,one)
  newSubActivity("ViewClass",{v.tag.text.text})
end
listView.onItemLongClick=function(id,v,zero,one)
  showPackageMenu(datas[one].text,v,mainLay)
  return true
end


local oldFirstVisibleItem=0
local oldFirstViewTop=0
listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,appBarLayout,nil,false,appBarLayout.getHeight()+appBarLayout.getTranslationY())
  local firstView=view.getChildAt(0)
  local firstViewTop=firstView and firstView.getTop() or 0
  if firstVisibleItem>oldFirstVisibleItem then
    hideActionBar()
   elseif firstVisibleItem<oldFirstVisibleItem then
    showActionBar()
   elseif oldFirstViewTop>firstViewTop then
    hideActionBar()
   elseif oldFirstViewTop<firstViewTop then
    showActionBar()
  end
  oldFirstVisibleItem=firstVisibleItem
  oldFirstViewTop=firstViewTop
end

searchButton.onClick=function()
  search(searchEdit.text)
end

searchEdit.onEditorAction=function(view,i,keyEvent)
  if not searching then
    search(view.text)
  end
  return true
end

searchEdit.addTextChangedListener({onTextChanged=function(text)
    checkTextError(tostring(text))
end})

local params=searchLayout.getLayoutParams()
params.setAnchorId(appBarLayout.getId())
params.anchorGravity=Gravity.BOTTOM
params.gravity=Gravity.BOTTOM
searchLayout.setLayoutParams(params)


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  onDeviceByWidthChanged=function(device, oldDevice)
    nowDevice=device
    if device=="phone" then
      toolBarLayout.removeView(searchLayout)
      mainLay.addView(searchLayout)
      local params=searchLayout.getLayoutParams()
      params.setAnchorId(appBarLayout.getId())
      params.anchorGravity=Gravity.BOTTOM
      params.gravity=Gravity.BOTTOM
      params.width=-1
      searchLayout.setLayoutParams(params)
     else
      mainLay.removeView(searchLayout)
      toolBarLayout.addView(searchLayout)
      local params=searchLayout.getLayoutParams()
      params.width=math.dp2int(320)
      searchLayout.setLayoutParams(params)
    end
    local width=View.MeasureSpec.makeMeasureSpec(0,View.MeasureSpec.UNSPECIFIED)
    local height=View.MeasureSpec.makeMeasureSpec(0,View.MeasureSpec.UNSPECIFIED)
    searchLayout.measure(width,height)
    appBarLayout.measure(width,height)
    local searchLayoutHeight=searchLayout.getMeasuredHeight()
    local appBarLayoutHeight=appBarLayout.getMeasuredHeight()
    if device=="phone" then
      listView.setPadding(0,appBarLayoutHeight+searchLayoutHeight,0,0)
     else
      listView.setPadding(0,appBarLayoutHeight,0,0)
      showActionBar(true)
    end
  end
})

onConfigurationChanged(activity.getResources().getConfiguration())

