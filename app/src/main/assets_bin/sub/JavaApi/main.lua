require "import"
import "Jesse205"
import "com.Jesse205.adapter.MyLuaAdapter"
import "com.Jesse205.layout.MySearchLayout"

import "getImportCode"
import "showPackageMenu"

import "item"

searchWord=...
searchWord=tostring(searchWord)
if searchWord=="nil" then
  searchWord=""
end
activity.setTitle(R.string.javaApiViewer)
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)
activity.setContentView(loadlayout("layout"))

function onCreate()
  searchItem(searchWord)
  searchEdit.text=searchWord
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


function searchItem(text)
  progressBar.setVisibility(View.VISIBLE)
  searchButton.clickable=false
  activity.newTask(search,function(classesList)
    adp.clear()
    adp.addAll(luajava.astable(classesList))
    adp.notifyDataSetChanged()
    progressBar.setVisibility(View.GONE)
    searchButton.clickable=true
  end).execute({tostring(text),application})
end

function checkTextError(text,searchLay)
  local success,err=pcall(string.find,"",text)
  if success then
    searchLay.setErrorEnabled(false)
    return false
   else
    searchLay
    .setError(err)
    .setErrorEnabled(true)
    return true
  end
end

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

searchButton.onClick=function()
  local text=searchEdit.text
  if checkTextError(text,searchLay) then
    return
  end
  searchItem(text)
end

searchEdit.onEditorAction=function(view,i,keyEvent)
  if searchButton.clickable then
    local text=view.text
    if checkTextError(text,searchLay) then
      return true
    end
    searchItem(text)
  end
  return true
end

searchEdit.addTextChangedListener({onTextChanged=function(text)
    checkTextError(tostring(text),searchLay)
end})
