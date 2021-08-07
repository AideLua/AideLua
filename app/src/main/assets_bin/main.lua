require "import"
initApp=true
--useCustomAppToolbar=true
import "Jesse205"
import "agreements"

welcomeAgain=not(getSharedData("welcome"))
if not(welcomeAgain) then
  for index,content in ipairs(agreements) do
    if getSharedData(content.name)~=content.date then
      welcomeAgain=true
    end
  end
end
if welcomeAgain then
  pcall(function()--百度移动统计稍微有一点bug
    StatService.setAuthorizedState(activity,false)
  end)
  newSubActivity("Welcome")
  activity.finish()
  return
end
pcall(function()
  StatService.setAuthorizedState(activity,true)
end)
StatService.start(activity)

import "android.text.TextUtils$TruncateAt"
import "android.content.ComponentName"
import "androidx.drawerlayout.widget.DrawerLayout"

--import "com.google.android.material.textfield.*"
--import "com.google.android.material.appbar.AppBarLayout"
--import "com.google.android.material.bottomappbar.BottomAppBar"
--import "com.google.android.material.chip.*"
--import "com.google.android.material.snackbar.Snackbar"
--import "com.google.android.material.bottomsheet.BottomSheetDialog"
--import "com.google.android.material.navigation.NavigationView"
import "com.google.android.material.tabs.TabLayout"

--import "com.mythoi.androluaj.editor.LuaEditorX"
--import "com.Jesse205.aidelua.MyCodeEditor"
--import "com.Jesse205.aidelua2.JavaEditor"
import "com.nwdxlgzs.view.photoview.PhotoView"
import "com.pixplicity.sharp.Sharp"

import "com.Jesse205.app.actionmode.SearchActionMode"
import "com.Jesse205.util.FileUtil"
import "com.Jesse205.util.ScreenFixUtil"

import "ProjectUtil"
import "ReBuildTool"
import "CreateFile"
--import "CreateProject"
import "EditorUtil"
import "DefaultEditorText"
import "FileTemplates"

import "AppFunctions"
import "DialogFunctions"

import "getImportCode"

import "item"

import "adapter.FileListAdapter"


safeModeEnable=File("/sdcard/aidelua_safemode").exists()
notSafeModeEnable=not(safeModeEnable)
application.set("safeModeEnable",safeModeEnable)

subWindow_ProjectPath,subWindow_FilePath=...

--初始化变量(虽然没什么用)
SdPath=ProjectUtil.SdPath--内部存储路径
ProjectsPath=ProjectUtil.ProjectsPath--所有项目路径
ProjectsFile=ProjectUtil.ProjectsFile
LibsRelativePathMatch=ProjectUtil.LibsRelativePathMatch

--TemplatesPath=activity.getLuaDir("templates")--模版路径
--LibrariesPath=activity.getLuaDir("libraries")--库路径

--ProjectsPathLength=utf8.len(ProjectsPath)
NowFile=nil--已打开文件
NowFileShowData=nil
NowFileType=nil
NowDirectory=nil--已打开文件夹
NowDirectoryFilesList={}

NowProjectDirectory=nil--项目根路径
OpenedProject=false--是否打开了工程
OpenedFile=false--是否打开了文件
AppName=nil

DirDatas=nil

--FilesDataList={}

FilesTabList={}
FilesListScroll={}

PathsTabList={}
PathsTabShowList={}

buildKeysCache()

oldJesse205LibHl=getSharedData("Jesse205Lib_Highlight")
oldAndroidXHl=getSharedData("AndroidX_Highlight")
oldTheme=ThemeUtil.getAppTheme()
oldDarkActionBar=getSharedData("theme_darkactionbar")
oldRichAnim=getSharedData("richAnim")
oldTabIcon=getSharedData("tab_icon")
oldEditorSymbolBar=getSharedData("editor_symbolBar")

--editor_magnify=getSharedData("editor_magnify")

--文件颜色
FilesColor={
  normal=0xFF9E9E9E,--普通颜色
  --active=theme.color.colorAccent,--一已打开文件颜色
  folder=0xFFF9A825,--文件夹颜色

  --按文件类型
  APK=0xFF00E676,
  LUA=0xFF448AFF,
  ALY=0xFF64B5F6,
  PNG=0xFFF44336,
  GRADLE=0xFF0097A7,
  XML=0xffff6f00,
  DEX=0xFF00BCD4,
  JAVA=0xFF2962FF,
  JAR=0xffe64a19,
  ZIP=0xFF795548,
  HTML=0xffff5722,
  JSON=0xffffa000,
}
FilesColor.JPG=FilesColor.PNG
FilesColor["7Z"]=FilesColor.ZIP
FilesColor.tar=FilesColor.ZIP
FilesColor.RAR=FilesColor.ZIP
FilesColor.SVG=FilesColor.XML
--FilesColor.JSON=FilesColor.XML

lastBackTime=0

SDK_INT=Build.VERSION.SDK_INT

function MyLuaEditor(context)
  local lastX=0
  return luajava.override(LuaEditor,{
    onKeyShortcut=function(super,keyCode,event)
      onKeyShortcut(keyCode,event)
    end,
    onKeyPreIme=function(super,keyCode,event)
      print("ime",keyCode,event)
    end
  })
end

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getSupportActionBar()
actionBar.setTitle(R.string.app_name)
actionBar.setDisplayHomeAsUpEnabled(true)

EditorUtil.IsEditors={
  LuaEditor=true,
  PhotoView=false,
}
EditorUtil.Editors={
  LuaEditor=luaEditor,
  PhotoView=photoView,
}
EditorUtil.EditorsGroup={
  LuaEditor=luaEditorParent,
  PhotoView=photoViewParent,
}
EditorUtil.switchEditor("LuaEditor")

--[[
setTypeface(Typeface.MONOSPACE);
        File df = new File(fontDir + "default.ttf");
        if (df.exists())
            setTypeface(Typeface.createFromFile(df));
        File bf = new File(fontDir + "bold.ttf");
        if (bf.exists())
            setBoldTypeface(Typeface.createFromFile(bf));
        File tf = new File(fontDir + "italic.ttf");
        if (tf.exists())
            setItalicTypeface(Typeface.createFromFile(tf));
    }]]

LuaReservedCharacters={"switch","if","then","and","break","do",
  "else","elseif","end","false",
  "for","function","in","local","nil","not",
  "or","repeat","return","true","until","while"}--lua关键字

if notSafeModeEnable then
  pcall(function()--放大镜
    import "android.widget.Magnifier"
    magnifier=Magnifier(editorGroup)
    magnifierUpdateTi=Ticker()--放大镜的定时器，定时刷新放大镜
    magnifierUpdateTi.setPeriod(100)
    magnifierUpdateTi.onTick=function()
      magnifier.update()
    end
    magnifierUpdateTi.setEnabled(false)--先禁用放大镜
  end)
end

function onCreate(savedInstanceState)
  local openedProject=subWindow_ProjectPath or getSharedData("openedproject")
  openedProject=tostring(openedProject)
  if openedProject=="nil" then
    openedProject=nil
  end
  if openedProject and openedProject~=ProjectsPath and not(savedInstanceState) then
    --print(openedProject,type(openedProject))
    local projectDirectory=File(tostring(openedProject))
    if projectDirectory.isDirectory() then
      --NowProjectDirectory=projectDirectory
      --NowDirectory=NowProjectDirectory
      local openFile=tostring(subWindow_FilePath)
      if openFile=="nil" then
        openFile=nil
       else
        openFile=File(openFile)
      end
      openProject(projectDirectory,openFile)
      --refresh(NowProjectDirectory)
      NowEditor.setScrollY(0)
    end
   else
    closeProject()
    refresh()
  end
end

function onCreateOptionsMenu(menu)
  local inflater=activity.getMenuInflater()
  inflater.inflate(R.menu.menu_main_aidelua,menu)
  --获取一下Menu
  closeFileMenu=menu.findItem(R.id.menu_file_close)
  saveFileMenu=menu.findItem(R.id.menu_file_save)
  binMenu=menu.findItem(R.id.menu_project_bin)
  binRunMenu=menu.findItem(R.id.menu_bin_run)
  closeProjectMenu=menu.findItem(R.id.menu_project_close)

  codeMenu=menu.findItem(R.id.subMenu_code)
  toolsMenu=menu.findItem(R.id.subMenu_tools)
  fileMenu=menu.findItem(R.id.subMenu_file)
  projectMenu=menu.findItem(R.id.subMenu_project)
  moreMenu=menu.findItem(R.id.subMenu_more)

  --菜单组
  StateByFileAndEditorMenus={saveFileMenu}
  StateByFileMenus={closeFileMenu}
  StateByEditorMenus={codeMenu}
  StateByProjectMenus={binMenu,closeProjectMenu,binRunMenu}

  screenConfigDecoder.events.menus={--自动刷新菜单显示
    [600]={binRunMenu,codeMenu,toolsMenu},
    [800]={fileMenu,projectMenu,moreMenu},
  }

  LoadedMenu=true
  refreshMenusState()--刷新Menu状态
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  local Rid=R.id
  local aRid=android.R.id
  if id==aRid.home then--菜单键
    editorFunc.open()
   elseif id==Rid.menu_undo then--撤销
    editorFunc.undo()
   elseif id==Rid.menu_redo then--重装
    editorFunc.redo()
   elseif id==Rid.menu_run then--运行
    editorFunc.run()
   elseif id==Rid.menu_bin_run then--二次打包
    local succeed
    if OpenedFile and IsEdtor then
      succeed=saveFile()
     else
      succeed=true
    end
    if succeed then
      ReBuildTool(NowProjectDirectory.getPath(),true)
    end
   elseif id==Rid.menu_project_bin then--二次打包
    local succeed
    if OpenedFile and IsEdtor then
      succeed=saveFile()
     else
      succeed=true
    end
    if succeed then
      ReBuildTool(NowProjectDirectory.getPath())
    end
   elseif id==Rid.menu_project_close then--关闭项目
    --closeProject()
    refresh(ProjectsFile)--打开项目文件夹，就自动关闭了项目
   elseif id==Rid.menu_file_save then--保存
    editorFunc.save()
   elseif id==Rid.menu_file_close then--关闭文件
    editorFunc.closeFile()
   elseif id==Rid.menu_code_format then--格式化
    editorFunc.format()
   elseif id==Rid.menu_code_search then
    editorFunc.search()
   elseif id==Rid.menu_code_checkImport then--检查导入
    local packageName=activity.getPackageName()
    if OpenedProject then--打开了工程
      local projectPath=NowProjectDirectory.getPath()
      local configPath=projectPath.."/.aidelua/config.lua"
      local configFile=File(configPath)
      if configFile.isFile() then--如果有文件
        local config=getConfigFromFile(configPath)
        if config.packageName then
          packageName=config.packageName
        end
      end
    end
    newSubActivity("FixImport",{NowEditor.text,packageName})
   elseif id==Rid.menu_tools_javaApiViewer then--JavaAPI浏览器
    newSubActivity("JavaApi")
   elseif id==Rid.menu_tools_javaApiViewer_windmill then--JavaAPI浏览器
    startWindmillActivity("Java API")
   elseif id==Rid.menu_tools_logCat then--日志猫
    --newSubActivity("LogCat")
    --editorFunc.run(sdLogCatPath)
    if OpenedProject then
      editorFunc.run(checkSharedActivity("LogCat"))
     else
      newSubActivity("LogCat")
    end
   elseif id==Rid.menu_tools_httpDebugging_windmill then--Http 调试
    startWindmillActivity("Http 调试")
   elseif id==Rid.menu_tools_luaManual_windmill then--Lua 手册
    startWindmillActivity("手册")
   elseif id==Rid.menu_more_settings then--设置
    newSubActivity("Settings")
   elseif id==Rid.menu_more_about then--关于
    newSubActivity("About")
   elseif id==Rid.menu_code_checkCode then--代码查错
    editorFunc.check()
   elseif id==Rid.menu_tools_layoutHelper then--布局助手
    if OpenedProject then
      newSubActivity("LayoutHelper",{NowProjectDirectory.getPath().."/app/src/main/assets_bin",NowFile.getPath()})
     else
      newSubActivity("LayoutHelper")
    end
   elseif id==Rid.menu_more_openNewWindow then--打开新窗口
    activity.newActivity("main",{ProjectsPath},true)
  end
end

function onKeyShortcut(keyCode,event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    if keyCode==KeyEvent.KEYCODE_O then
      editorFunc.open()
      return true
     elseif keyCode==KeyEvent.KEYCODE_S then
      editorFunc.save()
      return true
     elseif keyCode==KeyEvent.KEYCODE_L then
      editorFunc.search()
      return true
     elseif keyCode==KeyEvent.KEYCODE_E then
      editorFunc.check()
      return true
     elseif keyCode==KeyEvent.KEYCODE_R then
      editorFunc.run()
      return true
     elseif keyCode==KeyEvent.KEYCODE_Z then
      editorFunc.undo()
      return true
     elseif keyCode==KeyEvent.KEYCODE_F then
      editorFunc.format()
      return true
    end
  end
end


function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
  local smallestScreenWidthDp=config.smallestScreenWidthDp
  local screenWidthDp=config.screenWidthDp
  ScreenWidthDp=screenWidthDp
  local drawerChildLinearParams=drawerChild.getLayoutParams()
  if screenConfigDecoder.device=="pad" then
    if screenWidthDp>384 then
      drawerChildLinearParams.width=math.dp2int(328)
     else
      drawerChildLinearParams.width=-1
    end
   else
    if screenWidthDp>448 then
      drawerChildLinearParams.width=math.dp2int(392)
     else
      drawerChildLinearParams.width=-1
    end
  end
  drawerChild.setLayoutParams(drawerChildLinearParams)
  MyAnimationUtil.ScrollView.onScrollChange(NowEditor,NowEditor.getScrollX(),NowEditor.getScrollY(),0,0,appBarLayout,nil)
  refreshSubTitle()
end

notFirstOnResume=false
function onResume()
  if notFirstOnResume then
    if OpenedFile and IsEdtor then
      reOpenFile()
    end
  end
  local reload=false
  if oldJesse205LibHl~=getSharedData("Jesse205Lib_Highlight")
    or oldAndroidXHl~=getSharedData("AndroidX_Highlight")
    then
    reload=true
    application.set("luaeditor_initialized",false)
  end
  if reload
    or oldTheme~=ThemeUtil.getAppTheme()
    or oldDarkActionBar~=getSharedData("theme_darkactionbar")
    or oldRichAnim~=getSharedData("richAnim")
    then
    local aRanim=android.R.anim
    newActivity("main",aRanim.fade_in,aRanim.fade_out)
    activity.finish()
    return
  end
  if magnifier then--刷新放大镜状态
    editor_magnify=getSharedData("editor_magnify")
  end
  if notFirstOnResume then
    if notSafeModeEnable then
      --task(500,refresh)--刷新列表
      refresh()--因为已经重写了，所以应该没有闪退bug了

      local newTabIcon=getSharedData("tab_icon")--刷新标签栏按钮状态
      if oldTabIcon~=newTabIcon then
        oldTabIcon=newTabIcon
        if newTabIcon then
          for index,content in pairs(FilesTabList) do
            local tab=content.tab
            tab.setIcon(ProjectUtil.getFileIconResIdByType(content.fileType))
            initFileTabView(tab,content)--再次初始化一下标签栏，下方同理
          end
         else
          for index,content in pairs(FilesTabList) do
            local tab=content.tab
            tab.setIcon(nil)
            initFileTabView(tab,content)
          end
        end
      end
      local newEditorSymbolBar=getSharedData("editor_symbolBar")
      if oldEditorSymbolBar~=newEditorSymbolBar then
        oldEditorSymbolBar=newEditorSymbolBar
        refreshSymbolBar(newEditorSymbolBar)
      end

    end
  end
  notFirstOnResume=true
end

function onResult(name,action,content)
  if action=="project_created_successfully" then
    showSnackBar(R.string.create_success)
    AlertDialog.Builder(this)
    .setTitle(activity.getString(R.string.reminder))
    .setMessage(activity.getString(R.string.project_create_tip))
    .setPositiveButton(android.R.string.ok,nil)
    .show()
   else
    showSnackBar(action)
  end
end

function onPause()
  if OpenedFile and IsEdtor then
    saveFile()
  end
end

function onDestroy()
  if magnifierUpdateTi and magnifierUpdateTi.isRun() then
    magnifierUpdateTi.stop()
  end
end

function onKeyDown(KeyCode,event)
  TouchingKey=true
end

function onKeyUp(KeyCode,event)
  if TouchingKey then
    TouchingKey=false
    if KeyCode==KeyEvent.KEYCODE_BACK then--返回键事件
      if drawerOpened and screenConfigDecoder.device=="phone" then--没有打开键盘且已打开侧滑，且设备为手机
        if NowDirectory then
          if OpenedProject then--已打开项目
            refresh(NowDirectory.getParentFile(),true)--返回上一个路径
           else--未打开项目
            drawer.closeDrawer(Gravity.LEFT)--关闭侧滑
          end
         else
          drawer.closeDrawer(Gravity.LEFT)--没有当前文件夹，当做啥时也没发生，关闭侧滑
        end
        return true
       else--啥都没打开
        if (System.currentTimeMillis()-lastBackTime)> 2000 then
          showSnackBar(R.string.exit_toast)
          lastBackTime=System.currentTimeMillis()
          return true
        end
      end
    end
  end
end

function onVersionChanged()
  checkSharedActivity("LogCat",true)
end

--onConfigurationChanged(activity.getResources().getConfiguration())

drawerOpened=drawer.isDrawerOpen(Gravity.LEFT)
drawer.addDrawerListener(DrawerLayout.DrawerListener({
  onDrawerSlide=function(view,slideOffset)
    if screenConfigDecoder.device=="phone" then
      if slideOffset>0.5 and not(drawerOpened) then
        drawerOpened=true
       elseif slideOffset<=0.5 and drawerOpened then
        drawerOpened=false
      end
    end
  end,
  onDrawerOpened=function(view)
    if OpenedFile and IsEdtor then
      saveFile()
    end
  end,
  onDrawerClosed=function(view)
  end,
  onDrawerStateChanged=function(newState)
  end
}))


toggle=ActionBarDrawerToggle(activity,drawer,R.string.drawer_open, R.string.drawer_close)
drawer.addDrawerListener(toggle)
toggle.syncState()

swipeRefresh.setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener{onRefresh=function()
    refresh(nil,nil,true)
  end
})
MyStyleUtil.appliedToSwipeRefreshLayout(swipeRefresh)

DirDatas={}
adp=FileListAdapter(DirDatas,item)
recyclerView.setAdapter(adp)
layoutManager=StaggeredGridLayoutManager(1,StaggeredGridLayoutManager.VERTICAL)
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy,sideAppBarLayout,"LastSideActionBarElevation")
  end
})
if notSafeModeEnable then
  recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
    onGlobalLayout=function()
      if activity.isFinishing() then
        return
      end
      MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0,sideAppBarLayout,"LastSideActionBarElevation")
    end
  })
end

--[[
adp=MyLuaMultiAdapter(activity,DirDatas,item)
listView.Adapter=adp
--文件点击
listView.onItemClick=function(id,v,zero,one)
  local data=DirDatas[one]
  local file=data.file
  local action=data.action
  switch action do
   case "createProject" then
    CreateProject()
   case "openProject" then
    openProject(file)
   case "openFolder" then
    refresh(file,data.upFile)
   case "openFile" then
    local succeed,_,inThirdPartySoftware=openFile(file)
    if succeed and not(inThirdPartySoftware) then
      drawer.closeDrawer(Gravity.LEFT)
    end
  end
  --binProject(data.file.getPath())
end
--文件长按
listView.onItemLongClick=function(id,v,zero,one)
  local data=DirDatas[one]
  local file=data.file
  local title=data.title.text

  if file and title~=".." then
    local Rid=R.id

    local parentFile,parentName
    local action=data.action
    local fileName=file.getName()
    local fileType=data.fileType
    local isFile=file.isFile()
    local filePath=file.getPath()
    local fileRelativePath
    if OpenedProject then
      fileRelativePath=ProjectUtil.shortPath(filePath,true,NowProjectDirectory.getPath())
    end
    local pop=PopupMenu(activity,v)
    local menu=pop.Menu
    if OpenedProject and fileType and ProjectUtil.CallCodeFileType[fileType] then--已经打开了项目并且文件类型受支持
      local inLibDir,inLibDirIndex
      for index,content in ipairs(LibsRelativePathMatch) do
        inLibDir=fileRelativePath:match(content)
        inLibDirIndex=index
        if inLibDir then
          break
        end
      end
      if inLibDir then--是库目录
        pop.inflate(R.menu.menu_javaapi_item_package)
        local callFilePath=inLibDir:gsub("/",".")
        local noTypeFileName=fileName:match("(.+)%.")--没有扩展名的文件名

        local copyNameMenu=menu.findItem(R.id.menu_copy_className)
        local copyClassPathMenu=menu.findItem(R.id.menu_copy_classPath)
        local copyClassPath2Menu=menu.findItem(R.id.menu_copy_classPath2)
        local copyImportMenu=menu.findItem(R.id.menu_copy_import)
        copyNameMenu.title=noTypeFileName
        copyImportMenu.title=getImportCode(callFilePath)
        copyClassPathMenu.setVisible(callFilePath~=noTypeFileName)
        copyClassPath2Menu.setVisible(inLibDirIndex==3)--smali仅在java目录下支持
        if callFilePath~=noTypeFileName then--有重复的时候
          copyClassPathMenu.title=callFilePath
        end
        if inLibDirIndex==3 then
          copyClassPath2Menu.title="L"..inLibDir..";"
        end
      end
    end
    pop.inflate(R.menu.menu_main_file)
    --local reNameMenu=menu.findItem(R.id.menu_rename)
    --local deleteMenu=menu.findItem(R.id.menu_delete)
    local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
    local referencesMenu=menu.findItem(Rid.menu_references)--引用资源
    local renameMenu=menu.findItem(Rid.menu_rename)--重命名

    --reNameMenu.setVisible(not(isUpFile))
    openInNewWindowMenu.setVisible(isFile or data.action=="openProject")
    referencesMenu.setVisible(toboolean(data.isResFile))
    renameMenu.setVisible(OpenedFile)

    if data.isResFile then--是资源文件
      parentFile=file.getParentFile()
      parentName=parentFile.getName()
    end

    pop.show()
    pop.onMenuItemClick=function(item)
      local id=item.getItemId()
      if id==Rid.menu_delete then--删除
        deleteFileDialog(title,file)
       elseif id==Rid.menu_rename then--重命名
        renameDialog(file)
       elseif id==Rid.menu_openInNewWindow then--新窗口打开
        if OpenedProject then--已打开项目
          activity.newActivity("main",{NowProjectDirectory,file.getPath()},true)
         else--未打开项目
          activity.newActivity("main",{file.getPath()},true)
        end
       elseif id==Rid.menu_references then--引用资源
        NowEditor.paste(("R.%s.%s"):format(parentName:match("(.-)%-")or parentName,fileName:match("(.+)%.")or fileName))
        drawer.closeDrawer(Gravity.LEFT)
        elseif id==R.id.menu_copy_import or id==R.id.menu_copy_classPath2 or id==R.id.menu_copy_classPath or id==R.id.menu_copy_className then
        MyToast.copyText(item.title)
      end
    end
    return true
  end
end
]]

task(500,function()
  if safeModeEnable then
    appBarLayout.setElevation(0)
   else
    MyAnimationUtil.ScrollView.onScrollChange(NowEditor,NowEditor.getScrollX(),NowEditor.getScrollY(),0,0,appBarLayout,nil,true)
  end
end)
--[[
listView.onScroll=function(view,firstVisibleItem,visibleItemCount,totalItemCount)
  MyAnimationUtil.ListView.onScroll(view,firstVisibleItem,visibleItemCount,totalItemCount,sideAppBarLayout,"LastSideActionBarContrast")
end]]


filesTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
  onTabSelected=function(tab)
    local tag=tab.tag
    local file=tag.file
    if (not(OpenedFile) or file.getPath()~=NowFile.getPath()) then
      openFile(file)
    end
  end,
  onTabReselected=function(tab)
    if OpenedFile and IsEdtor then
      saveFile()
    end
  end,
  onTabUnselected=function(tab)
  end
}))

pathsTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
  onTabSelected=function(tab)
    local tag=tab.tag
    local path=tag.path
    if path and path~=NowDirectory.getPath() then
      refresh(File(path),true)
    end
  end,
  onTabReselected=function(tab)
  end,
  onTabUnselected=function(tab)
  end
}))



--application.set("luaeditor_initialized",false)--强制初始化编辑器
--设置编辑器
if notSafeModeEnable then
  safeModeText.setVisibility(View.GONE)
  if not(application.get("luaeditor_initialized")) then--编辑器未初始化
    luaEditorParent.removeView(luaEditor)
    local editorText=luaEditor.text
    luaEditor.text=""
    activity.newTask(function()
      require "import"
      notLoadTheme=true
      import "Jesse205"
      import "androidApis.editor.androluaApis"
      import "androidApis.editor.systemApis"
      import "androidApis.editor.androidxApis"
      import "EditorKeyWords"

      local namesCheck={}

      function addPackages(lang,packages)
        for index,package in pairs(packages) do
          local methods={}
          local packageTable=_G[package]
          local packageType=type(packageTable)

          if packageType=="table" then
            for method,func in pairs(packageTable) do
              table.insert(methods,method)
            end
           elseif packageType=="userdata" then
            local inserted={}
            local class=packageTable.getClass()
            for index,content in ipairs(luajava.astable(class.getMethods())) do
              local name=content.getName()
              if not(inserted[name]) then
                inserted[name]=true
                table.insert(methods,name)
              end
            end
          end
          lang.a(package,methods)
        end
      end
      local Lexer=luajava.bindClass("b.b.a.b.k")
      local lang=Lexer.e()

      local names=application.get("editorBaseList")
      if not(names) then
        names=lang.g()--获取现在的names
        application.set("editorBaseList",names)
      end
      names=luajava.astable(names)
      for index,content in ipairs(names) do
        namesCheck[content]=true
      end

      for index,content in ipairs({androluaApis,systemApis,EditorKeyWords}) do--插入新的names
        for index,content in ipairs(content) do
          if not(namesCheck[content]) then
            table.insert(names,content)
            namesCheck[content]=true
          end
        end
      end
      if activity.getSharedData("AndroidX_Highlight") then
        for index,content in ipairs(androidxApis) do
          if not(namesCheck[content]) then
            table.insert(names,content)
            namesCheck[content]=true
          end
        end
      end

      addPackages(lang,{"activity","application","LuaUtil","android","R"})

      if activity.getSharedData("Jesse205Lib_Highlight") then--添加杰西205库
        for index,content in ipairs(Jesse205.APIS) do
          if not(namesCheck[content]) then
            table.insert(names,content)
            namesCheck[content]=true
          end
        end
        addPackages(lang,{"string","utf8","math","theme","Jesse205","AppPath","MyToast"})
      end
      lang.B(names)--设置成新的names
      return true
    end,
    function(success)
      luaEditor.respan()
      luaEditor.invalidate()--不知道干啥的，调用一下就对了
      if editorText~="" then
        luaEditor.text=editorText
      end
      luaEditorParent.addView(luaEditor)
      luaEditorParent.removeView(luaEditorProgressBar)--移除进度条
      application.set("luaeditor_initialized",success)
      MyAnimationUtil.ScrollView.onScrollChange(NowEditor,NowEditor.getScrollX(),NowEditor.getScrollY(),0,0,appBarLayout,nil,true)
    end).execute({})

   else
    luaEditorParent.removeView(luaEditorProgressBar)--移除进度条
  end


  for index,content in pairs(EditorUtil.Editors)
    if EditorUtil.IsEditors[index] then
      content.onScrollChange=function(view,l,t,oldl,oldt)
        MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt,appBarLayout)
      end
      content.OnSelectionChangedListener=function(status,start,end_)
        onEditorSelectionChangedListener(content,status,start,end_)
      end
    end
  end

  --LuaEditor放大镜
  showingMagnifier=false
  clickingLuaEitorEvent=nil
  luaEditor.onTouch=function(view,event)
    --print(view.getRowWidth())
    if magnifier and editor_magnify then
      local action=event.action
      local relativeCaretX=view.getCaretX()-view.getScrollX()
      local relativeCaretY=view.getCaretY()-view.getScrollY()
      local x=event.getX()
      local y=event.getY()
      local magnifierX=x
      local magnifierY=relativeCaretY-view.getTextSize()/2+math.dp2int(2)
      local isNearChar

      if action==MotionEvent.ACTION_DOWN or action==MotionEvent.ACTION_MOVE then
        if not(clickingLuaEitorEvent) or (clickingLuaEitorEvent.x~=x or clickingLuaEitorEvent.y~=y) then
          isNearChar=isNearChar2(relativeCaretX,relativeCaretY,x,y)
          clickingLuaEitorEvent={x=x,y=y}
          if isNearChar then
            magnifier.show(magnifierX,magnifierY)
            --print(magnifierX,magnifierY,x,y)
            showingMagnifier=true
            if not(magnifierUpdateTi.isRun()) then
              magnifierUpdateTi.start()
            end
            if not(magnifierUpdateTi.getEnabled()) then
              magnifierUpdateTi.setEnabled(true)
            end
           else
            if showingMagnifier then
              magnifierUpdateTi.setEnabled(false)
              magnifier.dismiss()
              showingMagnifier=false
            end
          end
        end
       elseif action==MotionEvent.ACTION_CANCEL or action==MotionEvent.ACTION_UP then
        clickingLuaEitorEvent=nil
        if showingMagnifier then
          magnifierUpdateTi.setEnabled(false)
          magnifier.dismiss()
          showingMagnifier=false
        end
      end
    end
  end
 else
  safeModeText.setForeground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary))
  luaEditorParent.removeView(luaEditorProgressBar)
end


refreshSymbolBar(oldEditorSymbolBar)

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  onDeviceChanged=function(device,oldDevice)
    if device=="phone" then--切换为手机时
      largeDrawerLay.removeView(drawerChild)
      largeMainLay.removeView(mainEditorLay)
      largeMainLay.setVisibility(View.GONE)
      drawer.addView(mainEditorLay)
      drawer.addView(drawerChild)
      drawer.setVisibility(View.VISIBLE)
      drawerOpened=false
      drawerChild.setVisibility(View.VISIBLE)
     elseif oldDevice=="phone" then--切换为平板或电脑时
      drawer.removeView(mainEditorLay)
      drawer.removeView(drawerChild)
      drawer.setVisibility(View.GONE)
      largeDrawerLay.addView(drawerChild)
      largeMainLay.addView(mainEditorLay)
      largeMainLay.setVisibility(View.VISIBLE)
      drawerOpened=true
      drawerChild.setVisibility(View.VISIBLE)
    end
  end,
})
--screenConfigDecoder.device="phone"--默认为手机

onConfigurationChanged(activity.getResources().getConfiguration())

