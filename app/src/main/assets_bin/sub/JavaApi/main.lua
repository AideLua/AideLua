-- 在 v5.1.0(51099) 搜索框改到标题栏内
require "import"
import "jesse205"
import "android.widget.ListView"

import "com.jesse205.adapter.MyLuaAdapter"
--import "com.jesse205.layout.MySearchLayout"
import "com.jesse205.layout.MyCardTitleEditLayout"

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
actionBar.setDisplayHomeAsUpEnabled(true)
actionBar.setDisplayShowCustomEnabled(true)
actionBar.setCustomView(loadlayout2("titleLayout"))
activity.setContentView(loadlayout2("layout"))

searching=false

function onCreate()
  PluginsUtil.callElevents("onCreate", savedInstanceState)
  local trueWord=""
  if searchWord then
    trueWord=searchWord.."$"
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

function onCreateOptionsMenu(menu)
  local arry=actionBar.getThemedContext().getTheme().obtainStyledAttributes({android.R.attr.textColorPrimary})
  searchMenu=menu.add(R.string.abc_searchview_description_search)
  searchMenu.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
  searchMenu.setIcon(R.drawable.ic_magnify)
  searchMenu.setIconTintList(arry.getColorStateList(0))

  arry.recycle()
  LoadedMenu = true
  refreshMenusState()
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if item==searchMenu then
    searchItem(searchEdit.text)
   elseif id==android.R.id.home then
    activity.finish()
  end
end

function onResult(name,err)
  if err then
    MyToast(err)
  end
end

function refreshMenusState()
  if LoadedMenu then
    searchMenu.setEnabled(not(searching))
  end
end

function search(text,application)
  require "import"
  local allClasses=application.get("classes_table")
  if allClasses then
    allClasses=luajava.astable(allClasses)
   else
    --local classesTable=luajava.astable(classes)
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


function searchItem(text,callback)
  if not(searching) then
    if checkTextError(text) then
      return
    end
    refreshMenusState()

    --延迟展示进度条
    Handler().postDelayed(Runnable({
      run=function()
        if searching then
          progressBar.setVisibility(View.VISIBLE)
        end
      end
    }),100)

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

ClearContentHelper.setupEditor(searchEdit,clearSearchBtn)

local drawable=ThemeUtil.getRippleDrawable(theme.color.ActionBar.rippleColorPrimary)
if Build.VERSION.SDK_INT>=23 then
  drawable.setRadius(math.dp2int(16))
end
clearButton.setBackground(drawable)

--clearSearchBtn.tooltip=getString(R.string.jesse205_clear)

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
listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,topCard)
end

searchEdit.onEditorAction=function(view,i,keyEvent)
  if not searching then
    searchItem(view.text)
  end
  return true
end

searchEdit.addTextChangedListener({onTextChanged=function(text)
    checkTextError(tostring(text))
end})
