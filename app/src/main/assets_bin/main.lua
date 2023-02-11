require "import"
initApp = true -- 首页面，初始化
require "jesse205"
local normalkeys=jesse205.normalkeys
normalkeys.magnifierUpdateTi=true
normalkeys.magnifier=true
normalkeys.FilesBrowserManager=true
normalkeys.EditorsManager=true
normalkeys.FilesTabManager=true
normalkeys.ProjectManager=true

-- 检测是否需要进入欢迎页面
import "agreements"
local welcomeAgain = not(getSharedData("welcome"))
if not(welcomeAgain) then
  for index=1, #agreements do
    local content=agreements[index]
    if getSharedData(content.name) ~= content.date then
      welcomeAgain = true
      setSharedData("welcome",false)
      break
    end
  end
end
if welcomeAgain then
  newSubActivity("Welcome")
  activity.finish()
  return
end

StatService.start(activity)

import "android.animation.AnimatorSet"
import "android.graphics.drawable.ColorDrawable"
import "android.text.TextUtils$TruncateAt"
import "android.content.ComponentName"
import "android.provider.DocumentsContract"
import "android.text.SpannableString"
import "android.text.style.ForegroundColorSpan"
import "android.text.style.BackgroundColorSpan"
import "android.text.Spannable"
import "android.graphics.Bitmap"
import "android.graphics.Canvas"

import "android.content.ClipData"
import "android.content.ClipDescription"
import "android.view.View$DragShadowBuilder"
import "android.content.FileProvider"
import "android.webkit.MimeTypeMap"
import "android.webkit.WebView"

import "androidx.drawerlayout.widget.DrawerLayout"
import "androidx.core.graphics.ColorUtils"
import "androidx.core.content.res.ResourcesCompat"
import "androidx.slidingpanelayout.widget.SlidingPaneLayout"
import "androidx.documentfile.provider.DocumentFile"

import "com.google.android.material.tabs.TabLayout"
import "com.google.android.material.chip.Chip"
import "com.google.android.material.chip.ChipGroup"

import "com.bumptech.glide.request.RequestOptions"
import "com.bumptech.glide.load.engine.DiskCacheStrategy"
import "com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions"
import "com.bumptech.glide.request.RequestListener"

import "com.nwdxlgzs.view.photoview.PhotoView"
import "com.caverock.androidsvg.SVG"
import "com.termux.shared.termux.TermuxConstants"
local RUN_COMMAND_SERVICE=TermuxConstants.TERMUX_APP.RUN_COMMAND_SERVICE
import "com.drakeet.drawer.FullDraggableContainer"
import "me.zhanghai.android.fastscroll.FastScrollerBuilder"
import "org.apache.http.util.EncodingUtils"

import "com.jesse205.widget.MyRecyclerView"
import "com.jesse205.layout.MyEditDialogLayout"
import "com.jesse205.app.actionmode.SearchActionMode"
import "com.jesse205.app.dialog.EditDialogBuilder"
import "com.jesse205.util.FileUtil"
import "com.jesse205.util.ScreenFixUtil"

import "com.jesse205.util.FileInfoUtils"
import "com.jesse205.util.ColorUtil"

--https://github.com/limao996/LuaDB
db=require "db"
filesScrollingDB=db.open(AppPath.AppSdcardDataDir..'/filesScrolling.db')

import "androidx"

require "AppFunctions" -- 必须先导入这个，因为下面的导入模块要直接使用
require "DialogFunctions"
CreateFileUtil=require "CreateFileUtil"
LuaEditorHelper=require "LuaEditorHelper"
SubActivityUtil=require "SubActivityUtil"

CopyMenuUtil=require "CopyMenuUtil"
BuildToolUtil=require "buildtools.BuildToolUtil"

--各种管理器
FilesBrowserManager=require "FilesBrowserManager"
EditorsManager=require "EditorsManager"
FilesTabManager=require "FilesTabManager"
ProjectManager=require "ProjectManager"

--各种布局
item=require "layouts.item"
pathItem=require "layouts.pathItem"

--加载插件
PluginsUtil.clearOpenedPluginPaths()
PluginsUtil.setActivityName("main")
PluginsUtil.loadPlugins()
plugins = PluginsUtil.getPlugins()

--请求权限
PermissionUtil.askForRequestPermissions({
  {
    name=R.string.jesse205_permission_storage,
    tool=R.string.app_name,
    todo=getLocalLangObj("获取文件列表，读取文件和保存文件","Get file list, read file and save file"),
    permissions={"android.permission.WRITE_EXTERNAL_STORAGE","android.permission.READ_EXTERNAL_STORAGE"};
  },
})

--个性化设置
oldJesse205Support = getSharedData("jesse205Lib_support")
oldAndroidXSupport = getSharedData("androidX_support")
oldTheme = ThemeUtil.getAppTheme()
oldDarkActionBar = getSharedData("theme_darkactionbar")
oldRichAnim = getSharedData("richAnim")
oldTabIcon = getSharedData("tab_icon")
oldEditorSymbolBar = getSharedData("editor_symbolBar")
oldEditorFontId = getSharedData("editor_font") or 0
oldEditorPreviewButton = getSharedData("editor_previewButton")

--计时间戳器
local lastBackTime = 0 -- 上次点击返回键时间
local lastPencilkeyTime = 0 -- 上次双击笔时间

--软件信息
SDK_INT = Build.VERSION.SDK_INT
packageInfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 64)
lastUpdateTime = packageInfo.lastUpdateTime

activityStopped = false
LoadedMenu = false
local notFirstOnResume = false
local touchingKey = false

nowDevice = "phone"
screenWidthDp = 0

import "FileDecoders"
import "FileTemplates"
import "ActivityTemplates"

import "adapter.FileListAdapter"
import "adapter.FilePathAdapter"

--传入的数据
local receivedData={...}

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layouts.layout"))
actionBar.setTitle("Aide Lua")
actionBar.setDisplayHomeAsUpEnabled(true)

deviceChangeLTFixList={largeDrawerLay,largeMainLay,mainEditorLay,layoutTransition}

function onCreate(savedInstanceState)
  if PluginsUtil.callElevents("onCreate", savedInstanceState) then
    return
  end
  local data,data2,data3=receivedData[1],receivedData[2],receivedData[3]
  if data=="projectPicker" then
    data=nil
   else
    if not(data) then
      data=getSharedData("openedProject")
    end
  end

  if savedInstanceState then
    local prjPath=savedInstanceState.getString("prjpath")
    local filePath=savedInstanceState.getString("filepath")
    local dirPath=savedInstanceState.getString("dirpath")
    data=prjPath
    data2=filePath or false
    data3=dirPath or false
  end
  if data then
    pathPlaceholderView.setVisibility(View.VISIBLE)
    ProjectManager.openProject(data,data2,data3)
   else
    ProjectManager.closeProject(false)
    pathPlaceholderView.setVisibility(View.GONE)
    FilesBrowserManager.open()
  end
  toggle.syncState()
end

function onCreateOptionsMenu(menu)
  local inflater = activity.getMenuInflater()
  inflater.inflate(R.menu.menu_main_aidelua, menu)
  -- 获取一下Menu
  reopenFileMenu = menu.findItem(R.id.menu_file_reopen)
  closeFileMenu = menu.findItem(R.id.menu_file_close)
  saveFileMenu = menu.findItem(R.id.menu_file_save)
  runMenu = menu.findItem(R.id.menu_run)
  binMenu = menu.findItem(R.id.menu_project_bin)
  binRunMenu = menu.findItem(R.id.menu_project_bin_run)
  reopenProjectMenu = menu.findItem(R.id.menu_project_reopen)
  closeProjectMenu = menu.findItem(R.id.menu_project_close)
  projectPropertiesMenu = menu.findItem(R.id.menu_project_properties)
  buildMenu = menu.findItem(R.id.menu_project_build)

  codeMenu = menu.findItem(R.id.subMenu_code)
  toolsMenu = menu.findItem(R.id.subMenu_tools)
  fileMenu = menu.findItem(R.id.subMenu_file)
  projectMenu = menu.findItem(R.id.subMenu_project)
  moreMenu = menu.findItem(R.id.subMenu_more)
  pluginsMenu = menu.findItem(R.id.subMenu_plugins)

  -- 菜单组
  StateByFileAndEditorMenus = {saveFileMenu}
  StateByFileMenus = {fileMenu}
  StateByEditorMenus = {codeMenu}
  StateByProjectMenus = {projectMenu}
  StateByNotBadPrjMenus = {runMenu,binMenu,binRunMenu}

  projectPropertiesMenu.setEnabled(false)
  --buildMenu.setEnabled(false)

  screenConfigDecoder.events.menus = { -- 自动刷新菜单显示
    [600] = {codeMenu, toolsMenu},
    [800] = {fileMenu, projectMenu, moreMenu, pluginsMenu}
  }

  -- 添加插件菜单
  local pluginsActivities = plugins.activities
  local pluginsActivitiesName = plugins.activitiesName
  if #pluginsActivities == 0 then
    pluginsMenu.setVisible(false)
   else
    local pluginsMenuBuilder = pluginsMenu.getSubMenu()
    for index, content in ipairs(pluginsActivities) do
      pluginsMenuBuilder.add(pluginsActivitiesName[index]).onMenuItemClick = function()
        FilesTabManager.saveFile()
        local prjPath,filePath
        if ProjectManager.openState then
          prjPath=ProjectManager.nowPath.."/"
        end
        if FilesTabManager.openState then
          filePath=FilesTabManager.file.getPath()
        end
        activity.newActivity(pluginsActivities[index],{prjPath,filePath},true)
      end
    end
  end
  PluginsUtil.callElevents("onCreateOptionsMenu", menu)

  LoadedMenu = true
  refreshMenusState() -- 刷新Menu状态
end

function onOptionsItemSelected(item)
  local id = item.getItemId()
  local Rid = R.id
  local aRid = android.R.id
  local editorActions = EditorsManager.actions
  --小心switch的bug
  switch id do
   case aRid.home then -- 菜单键
    FilesBrowserManager.switchState()
   case Rid.menu_undo then -- 撤销
    editorActions.undo()
   case Rid.menu_redo then -- 重装
    editorActions.redo()
   case Rid.menu_run then -- 运行
    ProjectManager.smartRunProject()
   case Rid.menu_project_bin_run then -- 二次打包
    if ProjectManager.openState then
      FilesTabManager.saveAllFiles()
      BuildToolUtil.repackApk(ProjectManager.nowConfig,ProjectManager.nowPath,true,true)
    end
   case Rid.menu_project_bin then -- 二次打包
    if ProjectManager.openState then
      FilesTabManager.saveAllFiles()
      BuildToolUtil.repackApk(ProjectManager.nowConfig,ProjectManager.nowPath,false,false)
    end
   case Rid.menu_project_build then
    if not ProjectManager.openState then
      return
    end
    if PermissionUtil.checkPermission("com.termux.permission.RUN_COMMAND") then
      local intent=Intent()
      intent.setClassName(TermuxConstants.TERMUX_PACKAGE_NAME, TermuxConstants.TERMUX_APP.RUN_COMMAND_SERVICE_NAME);
      intent.setAction(RUN_COMMAND_SERVICE.ACTION_RUN_COMMAND)
      intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_COMMAND_PATH,"/data/data/com.termux/files/usr/bin/gradle")
      intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_ARGUMENTS,String{"assembleRelease"})
      intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_BACKGROUND, false)
      intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_WORKDIR, ProjectManager.nowPath.."/"..ProjectManager.nowConfig.mainModuleName)
      intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_COMMAND_LABEL, "Building "..ProjectManager.nowConfig.appName)
      local resultIntent=activity.buildNewActivityIntent(0,"sub/TermuxResult/main.lua",nil,true,0)
      resultIntent.putExtra("title",getString(R.string.project_build))
      local pendingIntent = PendingIntent.getActivity(activity, 1, resultIntent, PendingIntent.FLAG_ONE_SHOT)
      intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_PENDING_INTENT, pendingIntent)
      if Build.VERSION.SDK_INT >= 26 then
        activity.startForegroundService(intent)
       else
        activity.startService(intent)
      end
      local manager = activity.getPackageManager()
      local intent = manager.getLaunchIntentForPackage(TermuxConstants.TERMUX_PACKAGE_NAME)
      activity.startActivity(intent)

     else
      PermissionUtil.askForRequestPermissions({
        {
          name=R.string.permission_termux_runCode,
          tool=R.string.project_build,
          todo=getLocalLangObj("支持 Gradle 运行","Support gradle running"),
          permissions={"com.termux.permission.RUN_COMMAND"},
          helpUrl="https://jesse205.github.io/AideLua/function/build.html",
        },
      })
    end
   case Rid.menu_project_reopen then -- 重新打开项目
    ProjectManager.reopenProject()--函数内已判断打开状态
   case Rid.menu_project_close then -- 关闭项目
    ProjectManager.closeProject()
   case Rid.menu_file_save then -- 保存
    FilesTabManager.saveAllFiles(true)
   case Rid.menu_file_reopen then -- 重新打开文件
    FilesTabManager.reopenFile()--函数内已判断打开状态
   case Rid.menu_file_close then -- 关闭文件
    FilesTabManager.closeFile()
   case Rid.menu_code_format then -- 格式化
    editorActions.format()
   case Rid.menu_code_search then -- 代码搜索
    EditorsManager.startSearch()
   case Rid.menu_code_checkImport then -- 检查导入
    if EditorsManager.isEditor() then
      local packageName=activity.getPackageName()
      if ProjectManager.openState then--打开了工程
        packageName=ProjectManager.nowConfig.packageName
      end
      newSubActivity("FixImport",{EditorsManager.actions.getText(),packageName})
    end
   case Rid.menu_tools_javaApiViewer then -- JavaAPI浏览器
    newSubActivity("JavaApi",true)
   case Rid.menu_tools_javaApiViewer_windmill then -- JavaAPI浏览器
    startWindmillActivity("Java API")
   case Rid.menu_tools_logCat then -- 日志猫
    if ProjectManager.openState then
      ProjectManager.runProject(checkSharedActivity("LogCat"))
     else
      newSubActivity("LogCat",true)
    end
   case Rid.menu_tools_httpDebugging_windmill then -- Http 调试
    startWindmillActivity("Http 调试")
   case Rid.menu_tools_luaManual_windmill then -- Lua 手册
    startWindmillActivity("手册")
   case Rid.menu_tools_manual then -- Lua 手册
    openUrl(DOCS_URL)
   case Rid.menu_more_settings then -- 设置
    newSubActivity("Settings")
   case Rid.menu_more_about then -- 关于
    newSubActivity("About")
   case Rid.menu_code_checkCode then -- 代码查错
    editorActions.check(true)
   case Rid.menu_tools_layoutHelper then -- 布局助手
    FilesTabManager.saveFile()
    local prjPath,filePath
    if ProjectManager.openState then
      prjPath=ProjectManager.nowConfig.projectMainPath.."/"
    end
    if FilesTabManager.openState and FilesTabManager.fileType=="aly" then
      filePath=FilesTabManager.file.getPath()
    end
    newSubActivity("LayoutHelper",{prjPath,filePath})
   case Rid.menu_more_openNewWindow then -- 打开新窗口
    activity.newActivity("main",{"projectPicker"},true,int(System.currentTimeMillis()))
  end
  PluginsUtil.callElevents("onOptionsItemSelected", item)
end

function onKeyShortcut(keyCode, event)
  if PluginsUtil.callElevents("onKeyShortcut", keyCode, event) then
    return true
  end
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    local editorActions = EditorsManager.action
    if keyCode == KeyEvent.KEYCODE_O then
      editorActions.open()
      return true
     elseif keyCode == KeyEvent.KEYCODE_S then
      FilesTabManager.saveFile(nil,true)
      return true
     elseif keyCode == KeyEvent.KEYCODE_L then
      EditorsManager.startSearch()
      return true
     elseif keyCode == KeyEvent.KEYCODE_E then
      editorActions.check()
      return true
     elseif keyCode == KeyEvent.KEYCODE_R then
      ProjectManager.runProject()
      return true
     elseif keyCode == KeyEvent.KEYCODE_Z then
      editorActions.undo()
      return true
     elseif keyCode == KeyEvent.KEYCODE_F then
      editorActions.format()
      return true
    end
  end
end

function onConfigurationChanged(newConfig)
  screenConfigDecoder:decodeConfiguration(newConfig)
  local smallestScreenWidthDp = newConfig.smallestScreenWidthDp
  screenWidthDp = newConfig.screenWidthDp--设置为全局变量，其他地方要用到
  local drawerChildLinearParams = drawerChild.getLayoutParams()
  if screenWidthDp < 448 then
    drawerChildLinearParams.width = -1
   elseif screenWidthDp < 800 then
    drawerChildLinearParams.width = math.dp2int(448-56)
   elseif screenWidthDp < 1176 then
    drawerChildLinearParams.width = math.dp2int(328)
   else
    drawerChildLinearParams.width = math.dp2int(392)
  end
  drawerChild.setLayoutParams(drawerChildLinearParams)
  EditorsManager.refreshEditorScrollState()
  refreshSubTitle(screenWidthDp)
  PluginsUtil.callElevents("onConfigurationChanged", newConfig)
  toggle.onConfigurationChanged(newConfig)
end


function onDeviceByWidthChanged(device, oldDevice)
  nowDevice=device
  local browserOpenState=FilesBrowserManager.openState

  -- 暂时关闭动画，因为动画有延迟
  local applyLT=fixLT(deviceChangeLTFixList)
  if oldDevice == "pc" then -- 切换为手机时
    largeDrawerLay.removeView(drawerChild)
    largeMainLay.removeView(mainEditorLay)
    drawerContainer.addView(mainEditorLay)
    drawer.addView(drawerChild)

    local linearParams = drawerChild.getLayoutParams()
    linearParams.gravity = Gravity.LEFT
    drawerChild.setLayoutParams(linearParams)
    largeMainLay.setVisibility(View.GONE)
    drawer.setVisibility(View.VISIBLE)

    if browserOpenState then
      Handler().postDelayed(Runnable({
        run = function()
          if nowDevice==device then
            drawer.openDrawer(Gravity.LEFT)
          end
        end
      }), 50)
    end
    if browserOpenState == nil then
      FilesBrowserManager.setOpenState(false)
    end
    drawerChild.setVisibility(View.VISIBLE)
   elseif device == "pc" then -- 切换为电脑时
    drawerContainer.removeView(mainEditorLay)
    drawer.removeView(drawerChild)
    largeDrawerLay.addView(drawerChild)
    largeMainLay.addView(mainEditorLay)

    largeMainLay.setVisibility(View.VISIBLE)
    drawer.setVisibility(View.GONE)
    if browserOpenState or browserOpenState == nil then
      FilesBrowserManager.setOpenState(true)
      drawerChild.setVisibility(View.VISIBLE)
     else
      drawerChild.setVisibility(View.GONE)
    end
  end
  toggle.syncState()
  applyLT()
end

function onResume()
  if PluginsUtil.callElevents("onResume", notFirstOnResume)
    return
  end
  local reload = false
  if oldJesse205Support ~= getSharedData("jesse205Lib_support")
    or oldAndroidXSupport ~= getSharedData("androidX_support") then
    reload = true
    application.set("luaeditor_initialized", false)
  end
  if reload
    or (oldTheme ~= ThemeUtil.getAppTheme())
    or (oldDarkActionBar ~= getSharedData("theme_darkactionbar"))
    or (oldRichAnim ~= getSharedData("richAnim"))
    then
    activity.recreate()
    return
  end
  EditorsManager.magnifier.refresh()

  if notFirstOnResume then
    ProjectManager.refreshProjectsPath()
    FilesTabManager.reopenFile()--包含了刷新预览按钮
    local newTabIcon = getSharedData("tab_icon") -- 刷新标签栏按钮状态
    if oldTabIcon ~= newTabIcon then
      oldTabIcon = newTabIcon
      if newTabIcon then
        for index, content in pairs(FilesTabManager.openedFiles) do
          local tab = content.tab
          tab.setIcon(FilesBrowserManager.fileIcons[content.fileType])
          FilesTabManager.initFileTabView(tab, content) -- 再次初始化一下标签栏，下方同理
        end
       else
        for index, content in pairs(FilesTabManager.openedFiles) do
          local tab = content.tab
          tab.setIcon(nil)
          FilesTabManager.initFileTabView(tab, content)
        end
      end
    end
    local newEditorSymbolBar = getSharedData("editor_symbolBar")
    if oldEditorSymbolBar ~= newEditorSymbolBar then
      oldEditorSymbolBar = newEditorSymbolBar
      EditorsManager.symbolBar.refresh(newEditorSymbolBar)
    end
    EditorsManager.checkAndRefreshTypeface()
    EditorsManager.checkAndRefreshSharedDataListeners()
  end
  FilesBrowserManager.refresh()
  notFirstOnResume = true
end

function onResult(name, action, content)
  local processed=false
  if action == "project_created_successfully" then
    FilesBrowserManager.refresh(nil,File(content).getName())
    showSnackBar(R.string.create_success).setAction(R.string.open, function(view)
      if ProjectManager.openState then -- 已打开项目
        ProjectManager.closeProject(false)
      end
      ProjectManager.openProject(content)
    end)
    processed=true
  end
  processed=PluginsUtil.callElevents("onResult", name, action, content) or processed or false
  if processed==false then
    showSnackBar(action)
  end
end


function onPause()
  if FilesTabManager.openState then
    FilesTabManager.saveFile()
  end
  PluginsUtil.callElevents("onPause")
end

function onStart()
  activityStopped = false
  PluginsUtil.callElevents("onStart")
end

function onStop()
  activityStopped = true
  PluginsUtil.callElevents("onStop")
end

function onDestroy()
  if magnifierUpdateTi and magnifierUpdateTi.isRun() then
    magnifierUpdateTi.stop()
  end
  filesScrollingDB:close()
  AppPath.cleanTemp()

  PluginsUtil.callElevents("onDestroy")
end

function onKeyDown(keyCode, event)
  touchingKey = true
end

function onKeyUp(keyCode, event)
  if touchingKey then
    touchingKey=false
    --华为MPencil双击功能
    local success,result=pcall(function()
      if keyCode==KeyEvent.KEYCODE_F20 then
        if (System.currentTimeMillis() - lastPencilkeyTime) < 2000 then
          ProjectManager.runProject()
        end
        lastPencilkeyTime = System.currentTimeMillis()
        return true
      end
    end)
    if success then
      return result
    end
  end
end

function onBackPressed()
  if FilesBrowserManager.openState and nowDevice ~= "pc" then -- 没有打开键盘且已打开侧滑，且设备为手机
    if ProjectManager.openState then
      -- todo:转到上一级文件夹
      local directoryFile=FilesBrowserManager.directoryFile
      --当工程打开，但没有directoryFile的情况：打开工程后没有来得及*加载文件列表，然后按返回键
      --关闭工程的情况：
      --没有directoryFile
      --directoryFile为根目录
      --directoryFile为工程路径的上一层文件夹
      if not directoryFile or directoryFile.getPath()=="/" or directoryFile==ProjectManager.nowFile then
        ProjectManager.closeProject()
       else
        FilesBrowserManager.refresh(directoryFile.getParentFile())
      end
     else
      FilesBrowserManager.close()
    end
    return true
   elseif EditorsManager.isPreviewing then
    EditorsManager.switchPreview(false)
    return true
   else -- 啥都没打开
    if (System.currentTimeMillis() - lastBackTime) > 2000 then
      showSnackBar(R.string.exit_toast)
      .addCallback(Snackbar.BaseCallback({
        onDismissed=function()
          lastBackTime=0
        end
      }))
      lastBackTime = System.currentTimeMillis()
      return true
    end
  end
end

function onRestoreInstanceState(savedInstanceState)
  local fileBrowserOpenState=savedInstanceState.getBoolean("filebrowser_openstate")
  if fileBrowserOpenState then
    FilesBrowserManager.open()
   else
    FilesBrowserManager.close()
  end
  toggle.syncState()
end

function onSaveInstanceState(savedInstanceState)
  savedInstanceState.putBoolean("filebrowser_openstate",FilesBrowserManager.openState)
  --只有当d打开了工程才保存工程路径
  if ProjectManager.openState and FilesBrowserManager.directoryFile then
    savedInstanceState.putString("prjpath",ProjectManager.nowPath)
    savedInstanceState.putString("dirpath",FilesBrowserManager.directoryFile.getPath())
  end
  --只有当打开了文件z才保存文件路径
  if FilesTabManager.openState then
    savedInstanceState.putString("filepath",FilesTabManager.file.getPath())
  end
end

toggle = ActionBarDrawerToggle(activity, drawer, R.string.drawer_open, R.string.drawer_close)
drawer.addDrawerListener(toggle)

FilesTabManager.init()
EditorsManager.init()
FilesBrowserManager.init()

screenConfigDecoder = ScreenFixUtil.ScreenConfigDecoder({
  onDeviceByWidthChanged=onDeviceByWidthChanged
})

onConfigurationChanged(activity.getResources().getConfiguration())

--在刷新后仍然为空，那就是关闭状态
if screenConfigDecoder.deviceByWidth~="pc" and FilesBrowserManager.openState == nil then
  FilesBrowserManager.setOpenState(false)
end

