package.path=package.path..activity.getLuaPath("../JavaApi2/?.lua;")
require "import"
import "jesse205"
local normalkeys=jesse205.normalkeys
normalkeys.LoadedMenu=true
normalkeys.LoadedData=true
normalkeys.code=true
normalkeys.packageName=true
normalkeys.classesList=true
normalkeys.StateByLoadedMenus=true

import "android.widget.ListView"
import "android.animation.Animator$AnimatorListener"
import "androidx.coordinatorlayout.widget.CoordinatorLayout"
import "com.google.android.material.floatingactionbutton.FloatingActionButton"
--import "android.content.res.ColorStateList"

import "addCopyPackageMenu"
import "CopyMenuUtil"

activity.setTitle(R.string.javaApiViewer_fixImport)
actionBar.setDisplayHomeAsUpEnabled(true)
activity.setContentView(loadlayout2("layout"))

code,packageName=...
LoadedData=false
data={}

function refreshMenusState()
  if LoadedMenu then
    for index,content in ipairs(StateByLoadedMenus) do
      content.setEnabled(LoadedData)
    end
  end
end

--复制按钮点击事件
function copyImports()
  local imports={}
  for index,content in pairs(data) do
    table.insert(imports,CodeHelper.getImportCode(index))--把代码添加到list
  end
  table.sort(imports,function(a,b)
    return string.lower(a)<string.lower(b)
  end)
  local importsStr=table.concat(imports,"\n")
  MyToast.copyText(importsStr)--复制文字
end


function selectAll(checked)
  if classesList then
    for index=0,#classesList-1 do
      listView.setItemChecked(index,checked)
      data[classesList[index]]=checked or nil
    end
  end
  if table.size(data)==0 then
    floatButton.hide()
   else
    floatButton.show()
  end
end

function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_javaapi_fiximport,menu)
  selectAllMenu=menu.findItem(R.id.menu_selectAll)
  unSelectAllMenu=menu.findItem(R.id.menu_unSelectAll)
  StateByLoadedMenus={selectAllMenu,unSelectAllMenu}
  LoadedMenu=true
  refreshMenusState()
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
   elseif id==R.id.menu_selectAll then
    selectAll(true)
   elseif id==R.id.menu_unSelectAll then
    selectAll(false)
  end
end

function onKeyShortcut(keyCode,event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    if keyCode==KeyEvent.KEYCODE_C then
      copyImports()
      return true
    end
  end
end

function fiximport(code,packageName,application)
  return pcall(function()
    require "import"
    --notLoadTheme=true
    --import "jesse205"
    import "helper.CodeHelper"

    local allClasses=application.get("classes_table_fiximport")
    if not(allClasses) then
      import "androidApis.androidxApis"
      import "androidApis.systemApis"
      import "androidApis.androluaApis"
      local insertedClasses={}
      allClasses={}
      function addAndroidClasses(classes,rootPath)
        for index,className in pairs(classes) do
          if type(index)=="number" then
            local fastReadClassesSelf=allClasses[className]
            if not(fastReadClassesSelf) then
              fastReadClassesSelf={}
              allClasses[className]=fastReadClassesSelf
            end
            local class=rootPath..className
            if not(insertedClasses[class]) then
              insertedClasses[class]=true
              table.insert(fastReadClassesSelf,class)
            end
           else
            addAndroidClasses(className,rootPath..index..".")
          end
        end
      end

      for index,content in ipairs({androidxApis,systemApis,androluaApis}) do
        addAndroidClasses(content,"")
      end

      for index,content in pairs(allClasses) do
        allClasses[index]=String(content)
      end
      allClasses=HashMap(allClasses)
      application.set("classes_table_fiximport",allClasses)
    end

    allClasses.R=String({
      "android.R",
      packageName..".R"
    })

    local importClassList={}
    local buf={}
    local last=nil

    for advance,text,column in CodeHelper.LuaLexerIteratorBuilder(code)
      if last~=LuaTokenTypes.DOT and advance==LuaTokenTypes.NAME then
        if not(buf[text]) then
          buf[text]=true
          local fastReadClassesSelf=allClasses.get(text)
          if fastReadClassesSelf then
            for index=0,#fastReadClassesSelf-1 do
              table.insert(importClassList,fastReadClassesSelf[index])
            end
          end
        end
      end
      last=advance
    end

    table.sort(importClassList,function(a,b)
      return string.lower(a)<string.lower(b)
    end)
    --Thread.sleep(5000)
    return String(importClassList)
  end)
end

--直接隐藏会有bug
floatButton.post(Runnable({
  run=function()
    floatButton.hide()
  end
}))

activity.newTask(fiximport,function(success,content)
  progressBar.setVisibility(View.GONE)
  if success then
    classesList=content
    adapter=ArrayListAdapter(activity,android.R.layout.simple_list_item_multiple_choice,classesList)
    listView.setAdapter(adapter)
    adapter.notifyDataSetChanged()
    LoadedData=true
   else
    showErrorDialog("onAnalysis",content)
  end
  refreshMenusState()
end).execute({code,packageName,application})

listView.onItemClick=function(parent,view,position,id)
  data[view.text]=view.checked or nil
  if table.size(data)==0 then--但data没有数据时候隐藏复制按钮
    floatButton.hide()
   else
    floatButton.show()
  end
end

listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount)
end

activity.registerForContextMenu(listView)

listView.onCreateContextMenu=function(menu,view,menuInfo)
  if menuInfo then
    local class=classesList[menuInfo.position]
    menu.setHeaderTitle(R.string.copy_popup)
    addCopyPackageMenu(menu,class)
  end
end

floatButton.onClick=copyImports
floatButton.addOnShowAnimationListener(AnimatorListener({
  onAnimationStart=function(animSet)
    listView.setPadding(0,0,0,floatButton.getHeight()+math.dp2int(16)*2)
  end
}))
floatButton.addOnHideAnimationListener(AnimatorListener({
  onAnimationStart=function(animSet)
    listView.setPadding(0,0,0,0)
  end
}))
