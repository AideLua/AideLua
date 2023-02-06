-- 在 v5.1.0(51099) 搜索框改到标题栏内
require "import"
--useCustomAppToolbar=true
import "jesse205"
import "android.widget.ListView"
import "androidx.core.view.ViewCompat"
import "androidx.core.view.WindowInsetsCompat"
import "androidx.core.graphics.ColorUtils"
import "android.graphics.drawable.ColorDrawable"
import "android.animation.ObjectAnimator"

import "com.jesse205.adapter.MyLuaAdapter"
import "com.jesse205.layout.MySearchLayout"
import "getImportCode"
import "showPackageMenu"

import "item"

PluginsUtil.setActivityName("javaapi")

searchWord=...
searchWord=tostring(searchWord)
if searchWord=="nil" then
  searchWord=nil
end

activity.setTitle(R.string.javaApiViewer)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

searching=false
ThemeUtil.applyAplhaSystemBar()
window.setStatusBarColor(0)
actionBar.setBackgroundDrawable(ColorDrawable(0))
appBarSpaceView.setBackgroundColor(theme.color.colorPrimary)

--反射工具栏
local field=actionBar.getClass().getDeclaredField("mContainerView")
field.setAccessible(true)
local mContainerView=field.get(actionBar)


function onCreate(savedInstanceState)
  PluginsUtil.callElevents("onCreate", savedInstanceState)
  local trueWord=""
  if searchWord then
    trueWord="%."..searchWord.."$"
  end
  searchItem(trueWord,function(classesList)
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

function search(text,application)
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

searchButton.onClick=function()
  searchItem(searchEdit.text)
end

--搜索按钮波纹
local drawable=ThemeUtil.getRippleDrawable(theme.color.ActionBar.rippleColorPrimary)
if Build.VERSION.SDK_INT>=23 then
  drawable.mutate().setRadius(math.dp2int(20))
end
searchButton.setBackground(drawable)


local showProgressBarHandler=Handler()
local showProgressBarRunnable=Runnable({
  run=function()
    if searching then
      progressBar.setVisibility(View.VISIBLE)
    end
  end
})

function searchItem(text,callback)
  if not(searching) then
    if checkTextError(text) then
      return
    end
    --延迟展示进度条
    showProgressBarHandler.postDelayed(showProgressBarRunnable,100)

    activity.newTask(search,function(classesList)
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
  local actionBarHeight=mContainerView.getHeight()
  local progress=1+hideOffset/actionBarHeight
  mContainerView.setAlpha(progress*progress)
  mContainerView.setTranslationY(hideOffset)
  appBarSpaceView.setTranslationY(hideOffset)
  searchLayout.setTranslationY(hideOffset)
  if hideOffset==-actionBarHeight then
    mContainerView.setVisibility(View.INVISIBLE)
   else
    mContainerView.setVisibility(View.VISIBLE)
  end
  --appBarSpaceView的高度不完全等于mContainerView的高度
  MyAnimationUtil.ListView.onScroll(listView,listView.getFirstVisiblePosition(),nil,nil,appBarSpaceView,nil,false,appBarSpaceView.getHeight()+hideOffset)
end

local actionBarState=true
local actionBarAnimator
local canPlayActionBarAnimation=true
function showActionBar(force)
  if (not actionBarState or force) and canPlayActionBarAnimation then
    actionBarState=true
    if actionBarAnimator then
      actionBarAnimator.cancel()
    end
    actionBarAnimator = ObjectAnimator.ofFloat(mContainerView,"translationY",{0})
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
    actionBarState=false
    if actionBarAnimator then
      actionBarAnimator.cancel()
    end
    actionBarAnimator = ObjectAnimator.ofFloat(mContainerView,"translationY",{-mContainerView.getHeight()})
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

ClearContentHelper.setupEditor(searchEdit,clearSearchBtn,theme.color.ActionBar.rippleColorPrimary)

import "androidApis.editor.systemApis"
searchAdapter=ArrayAdapter(activity,android.R.layout.simple_dropdown_item_1line,systemApis)
searchEdit.setAdapter(searchAdapter)

ViewCompat.setOnApplyWindowInsetsListener(mainLay,function(view,windowInsets)
  local insets=windowInsets.getSystemWindowInsets()
  local params=searchLayout.getLayoutParams()
  params.setMargins(insets.left+math.dp2int(16),insets.top+math.dp2int(8),insets.right+math.dp2int(16),math.dp2int(8))
  searchLayout.setLayoutParams(params)
  local params=appBarSpaceView.getLayoutParams()
  params.height=insets.top
  appBarSpaceView.setLayoutParams(params)

  listView.setPadding(insets.left,insets.top+math.dp2int(64),insets.right,0)
  listView.parent.setPadding(0,0,0,insets.bottom)
  return WindowInsetsCompat.CONSUMED
end)

local searchEditDownYWithOffset=0
--拽拖顶栏触摸事件
topLayoutOnTouchListener=View.OnTouchListener{
  onTouch=function(view,event)
    local y=event.getRawY()
    local action=event.getAction()
    local actionBarHeight=mContainerView.getHeight()
    if action==MotionEvent.ACTION_DOWN then
      if actionBarAnimator then
        actionBarAnimator.cancel()
      end
      searchEditDownYWithOffset=y-searchLayout.getTranslationY()
      canPlayActionBarAnimation=false
     elseif action==MotionEvent.ACTION_MOVE then
      local offset=y-searchEditDownYWithOffset
      if offset>0 then
        offset=0
       elseif offset<-actionBarHeight
        offset=-actionBarHeight
      end
      onAnimUpdate(offset)
     elseif action==MotionEvent.ACTION_UP or action==MotionEvent.ACTION_CANCEL then
      canPlayActionBarAnimation=true
      local offset=y-searchEditDownYWithOffset
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

mContainerView.getChildAt(0).setOnTouchListener(topLayoutOnTouchListener)
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
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,appBarSpaceView,nil,false,appBarSpaceView.getHeight()+appBarSpaceView.getTranslationY())
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


--[[import "me.zhanghai.android.fastscroll.FastScrollerBuilder"
import "me.zhanghai.android.fastscroll.FastScrollScrollView"
FastScrollerBuilder(listView).useMd2Style().build()
]]

--[[
local oldFirstVisiblePosition,touchedBar
local hideOffset=0
local oldY,startScrollY
listView.onTouch=function(view,event)
  local action=event.action
  local y=event.getRawY()
  local firstVisiblePosition=view.getFirstVisiblePosition()
  switch (action) do
   case MotionEvent.ACTION_DOWN then
    startScrollY=y
    --touchedBar=false
    touchedBar=(view.getWidth()-y)>math.dp2int(16)
   case MotionEvent.ACTION_MOVE then
    hideOffset=hideOffset+y-oldY
    local actionBarHeight=mContainerView.getHeight()
    --特殊情况判断，仅在没有触摸到滚动条或者当前位置不一样时执行
    if not(touchedBar) or firstVisiblePosition~=oldFirstVisiblePosition then
      if oldY>y and touchedBar then
        hideOffset=0
       elseif oldY<y and touchedBar then
        hideOffset=-actionBarHeight
       else
        if hideOffset>0 then
          hideOffset=0
         elseif hideOffset<-actionBarHeight then
          hideOffset=-actionBarHeight
        end
      end
      local progress=1+hideOffset/actionBarHeight
      mContainerView.setAlpha(progress)
      mContainerView.setTranslationY(hideOffset)
      appBarSpaceView.setTranslationY(hideOffset)
      appBarElevationCard.parent.setTranslationY(hideOffset)
      titleLay.setTranslationY(hideOffset)
    end
  end
  oldY=y
  oldFirstVisiblePosition=firstVisiblePosition
end]]

--[[
local field=actionBar.getClass().getDeclaredField("mUpdateListener")
field.setAccessible(true)
local oldUpdateListener=field.get(actionBar)
local method=oldUpdateListener.getClass().getMethod("onAnimationUpdate",{View})
--print(method)
import "androidx.core.view.ViewPropertyAnimatorUpdateListener"
local updateListener=ViewPropertyAnimatorUpdateListener({
  onAnimationUpdate=function(view)
    if oldEvent and (oldEvent.getAction()==MotionEvent.ACTION_DOWN or oldEvent.getAction()==MotionEvent.ACTION_MOVE) then
      --print(1)
      listView.onTouchEvent(oldEvent)
    end
    oldUpdateListener.onAnimationUpdate(view)
  end,
})
field.set(actionBar,updateListener)]]
--print(actionBar.mHideListener)

searchEdit.onEditorAction=function(view,i,keyEvent)
  if not searching then
    searchItem(view.text)
  end
  return true
end

searchEdit.addTextChangedListener({onTextChanged=function(text)
    checkTextError(tostring(text))
end})
