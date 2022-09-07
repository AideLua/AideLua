require "import"
initApp = true -- 首页面，初始化
require "Jesse205"
-- 检测是否需要进入欢迎页面
import "agreements"
welcomeAgain = not(getSharedData("welcome"))
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


import "android.text.TextUtils$TruncateAt"
import "android.content.ComponentName"
import "android.provider.DocumentsContract"
--import "androidx.core.widget.ListViewCompat"
import "androidx.drawerlayout.widget.DrawerLayout"

import "com.google.android.material.tabs.TabLayout"
import "com.google.android.material.chip.Chip"
import "com.google.android.material.chip.ChipGroup"

import "com.bumptech.glide.request.RequestOptions"
import "com.bumptech.glide.load.engine.DiskCacheStrategy"

import "com.nwdxlgzs.view.photoview.PhotoView"
import "com.pixplicity.sharp.Sharp"

import "com.Jesse205.layout.MyEditDialogLayout"
import "com.Jesse205.app.actionmode.SearchActionMode"
import "com.Jesse205.app.dialog.EditDialogBuilder"
import "com.Jesse205.util.FileUtil"
import "com.Jesse205.util.ScreenFixUtil"
import "com.Jesse205.FileInfoUtils"

import "AppFunctions" -- 必须先导入这个，因为下面的导入直接要用
import "DialogFunctions"
import "createFile"
import "LuaEditorHelper"

import "CopyMenuUtil"
import "buildtools.RePackTool"

import "FilesBrowserManager"
import "EditorsManager"
import "FilesTabManager"
import "ProjectManager"

import "layouts.item"
import "layouts.pathItem"
import "layouts.infoItem"
import "layouts.buildingLayout"

--import "sub.LayoutHelper2.loadpreviewlayout"

import "layouts.FileDecoders"
import "layouts.FileTemplates"

import "adapter.FileListAdapter"
import "adapter.FilePathAdapter"

PluginsUtil.setActivityName("main")
PluginsUtil.loadPlugins()
plugins = PluginsUtil.getPlugins()
--print(dump(plugins))
-- 申请存储权限
PermissionUtil.smartRequestPermission({"android.permission.WRITE_EXTERNAL_STORAGE",
  "android.permission.READ_EXTERNAL_STORAGE"})

oldJesse205LibHl = getSharedData("Jesse205Lib_Highlight")
oldAndroidXHl = getSharedData("AndroidX_Highlight")
oldTheme = ThemeUtil.getAppTheme()
oldDarkActionBar = getSharedData("theme_darkactionbar")
oldRichAnim = getSharedData("richAnim")
oldTabIcon = getSharedData("tab_icon")
oldEditorSymbolBar = getSharedData("editor_symbolBar")
oldEditorPreviewButton = getSharedData("editor_previewButton")

lastBackTime = 0 -- 上次点击返回键时间
lastPencilkeyTime = 0 -- 上次双击笔时间

SDK_INT = Build.VERSION.SDK_INT
packageInfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 64)
lastUpdateTime = packageInfo.lastUpdateTime

activityStopped = false
nowDevice="phone"
screenWidthDp=0

receivedData={...}

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layouts.layout"))
actionBar.setTitle(R.string.app_name)
actionBar.setDisplayHomeAsUpEnabled(true)


LuaReservedCharacters = {"switch", "if", "then", "and", "break", "do", "else", "elseif", "end", "false", "for",
  "function", "in", "local", "nil", "not", "or", "repeat", "return", "true", "until", "while"} -- lua关键字

deviceChangeLTFixList={largeDrawerLay,largeMainLay,mainEditorLay,layoutTransition}

function onCreate(savedInstanceState)
  -- todo:根据savedInstanceState和getIntent判断打开项目
  --FilesBrowserManager.open()
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
    local dirPath=savedInstanceState.getString("dirpath")
    data=prjPath
    data3=dirPath
  end
  if data then
    pathPlaceholderView.setVisibility(View.VISIBLE)
    ProjectManager.openProject(data,data2,data3)
   else
    ProjectManager.closeProject(false)
    pathPlaceholderView.setVisibility(View.GONE)
    FilesBrowserManager.open()
  end

  PluginsUtil.callElevents("onCreate", savedInstanceState)
  toggle.syncState()
end

function onCreateOptionsMenu(menu)
  local inflater = activity.getMenuInflater()
  inflater.inflate(R.menu.menu_main_aidelua, menu)
  -- 获取一下Menu
  closeFileMenu = menu.findItem(R.id.menu_file_close)
  saveFileMenu = menu.findItem(R.id.menu_file_save)
  binMenu = menu.findItem(R.id.menu_project_bin)
  binRunMenu = menu.findItem(R.id.menu_project_bin_run)
  closeProjectMenu = menu.findItem(R.id.menu_project_close)

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
  if id == aRid.home then -- 菜单键
    FilesBrowserManager.switchState()
   elseif id == Rid.menu_undo then -- 撤销
    editorActions.undo()
   elseif id == Rid.menu_redo then -- 重装
    editorActions.redo()
   elseif id == Rid.menu_run then -- 运行
    ProjectManager.runProject()
   elseif id == Rid.menu_project_bin_run then -- 二次打包
    FilesTabManager.saveAllFiles()
    RePackTool.repackApk(ProjectManager.nowConfig,ProjectManager.nowPath,true,true)
   elseif id == Rid.menu_project_bin then -- 二次打包
    FilesTabManager.saveAllFiles()
    RePackTool.repackApk(ProjectManager.nowConfig,ProjectManager.nowPath,false,false)
   elseif id == Rid.menu_project_close then -- 关闭项目
    ProjectManager.closeProject()
   elseif id == Rid.menu_file_save then -- 保存
    FilesTabManager.saveAllFiles(true)
   elseif id == Rid.menu_file_close then -- 关闭文件
    FilesTabManager.closeFile()
   elseif id == Rid.menu_code_format then -- 格式化
    editorActions.format()
   elseif id == Rid.menu_code_search then -- 代码搜索
    EditorsManager.startSearch()
   elseif id == Rid.menu_code_checkImport then -- 检查导入
   elseif id == Rid.menu_tools_javaApiViewer then -- JavaAPI浏览器
    newSubActivity("JavaApi",true)
   elseif id == Rid.menu_tools_javaApiViewer_windmill then -- JavaAPI浏览器
    startWindmillActivity("Java API")
   elseif id == Rid.menu_tools_logCat then -- 日志猫
    if ProjectManager.openState then
      ProjectManager.runProject(checkSharedActivity("LogCat"))
     else
      newSubActivity("LogCat",true)
    end
   elseif id == Rid.menu_tools_httpDebugging_windmill then -- Http 调试
    startWindmillActivity("Http 调试")
   elseif id == Rid.menu_tools_luaManual_windmill then -- Lua 手册
    startWindmillActivity("手册")
   elseif id == Rid.menu_tools_manual then -- Lua 手册
    --openUrl("https://gitee.com/Jesse205/AideLua/blob/master/README.md")
    openUrl("https://gitee.com/Jesse205/AideLua/wikis/pages")
   elseif id == Rid.menu_more_settings then -- 设置
    newSubActivity("Settings")
   elseif id == Rid.menu_more_about then -- 关于
    newSubActivity("About")
   elseif id == Rid.menu_code_checkCode then -- 代码查错
    editorActions.check(true)
   elseif id == Rid.menu_tools_layoutHelper then -- 布局助手
    --print("错误：暂不支持")
    FilesTabManager.saveFile()
    local prjPath,filePath
    if ProjectManager.openState then
      prjPath=ProjectManager.nowConfig.projectMainPath.."/"
    end
    if FilesTabManager.openState and FilesTabManager.fileType=="aly" then
      filePath=FilesTabManager.file.getPath()
    end
    newSubActivity("LayoutHelper",{prjPath,filePath})
   elseif id == Rid.menu_more_openNewWindow then -- 打开新窗口
    activity.newActivity("main",{"projectPicker"},true,int(System.currentTimeMillis()))
  end
  PluginsUtil.callElevents("onOptionsItemSelected", item)
end

function onKeyShortcut(keyCode, event)
  --print(keyCode)
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
  PluginsUtil.callElevents("onKeyShortcut", keyCode, event)
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
  local smallestScreenWidthDp = config.smallestScreenWidthDp
  screenWidthDp = config.screenWidthDp--设置为全局变量，其他地方要用到
  local drawerChildLinearParams = drawerChild.getLayoutParams()
  if screenWidthDp < 448 then
    drawerChildLinearParams.width = -1
   elseif screenWidthDp <800 then
    drawerChildLinearParams.width = math.dp2int(448-56)
   elseif screenWidthDp <1176 then
    drawerChildLinearParams.width = math.dp2int(328)
   else
    drawerChildLinearParams.width = math.dp2int(392)
  end
  drawerChild.setLayoutParams(drawerChildLinearParams)
  EditorsManager.refreshEditorScrollState()
  refreshSubTitle(screenWidthDp)
  FilesTabManager.refreshMoveCloseHeight(config.screenHeightDp)
  PluginsUtil.callElevents("onConfigurationChanged", config)
end

function onDeviceByWidthChanged(device, oldDevice)
  --print(device, oldDevice)
  nowDevice=device
  local browserOpenState=FilesBrowserManager.openState
  --print(browserOpenState)
  if oldDevice == "pc" then -- 切换为手机时
    -- 暂时关闭动画，因为动画有延迟
    local applyLT=fixLT(deviceChangeLTFixList)

    largeDrawerLay.removeView(drawerChild)
    largeMainLay.removeView(mainEditorLay)
    drawer.addView(mainEditorLay)
    drawer.addView(drawerChild)

    local linearParams = drawerChild.getLayoutParams()
    linearParams.gravity = Gravity.LEFT
    drawerChild.setLayoutParams(linearParams)
    largeMainLay.setVisibility(View.GONE)
    drawer.setVisibility(View.VISIBLE)

    if browserOpenState then
      Handler().postDelayed(Runnable({
        run = function()
          drawer.openDrawer(Gravity.LEFT)
        end
      }), 50)
    end
    if browserOpenState == nil then
      FilesBrowserManager.setOpenState(false)
    end
    drawerChild.setVisibility(View.VISIBLE)
    toggle.syncState()

    applyLT()
   elseif device == "pc" then -- 切换为电脑时
    local applyLT=fixLT(deviceChangeLTFixList)

    drawer.removeView(mainEditorLay)
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
    toggle.syncState()

    applyLT()
  end
end

notFirstOnResume = false
function onResume()
  local reload = false
  if oldJesse205LibHl ~= getSharedData("Jesse205Lib_Highlight")
    or oldAndroidXHl ~= getSharedData("AndroidX_Highlight") then
    reload = true
    application.set("luaeditor_initialized", false)
  end
  if reload
    or (oldTheme ~= ThemeUtil.getAppTheme())
    or (oldDarkActionBar ~= getSharedData("theme_darkactionbar"))
    or (oldRichAnim ~= getSharedData("richAnim"))
    -- or ProjectsPath~=File(getSharedData("projectsDir")).getPath()
    then
    activity.recreate()
    return
  end
  refreshMagnifier()


  if notFirstOnResume then
    ProjectManager.refreshProjectsPath()
    FilesTabManager.reopenFile()
    local newTabIcon = getSharedData("tab_icon") -- 刷新标签栏按钮状态
    if oldTabIcon ~= newTabIcon then
      oldTabIcon = newTabIcon
      if newTabIcon then
        for index, content in pairs(FilesTabList) do
          local tab = content.tab
          tab.setIcon(ProjectUtil.getFileIconResIdByType(content.fileType))
          initFileTabView(tab, content) -- 再次初始化一下标签栏，下方同理
        end
       else
        for index, content in pairs(FilesTabList) do
          local tab = content.tab
          tab.setIcon(nil)
          initFileTabView(tab, content)
        end
      end
    end
    local newEditorSymbolBar = getSharedData("editor_symbolBar")
    if oldEditorSymbolBar ~= newEditorSymbolBar then
      oldEditorSymbolBar = newEditorSymbolBar
      EditorsManager.symbolBar.refresh(newEditorSymbolBar)
    end
    -- todo:更新预览，刷新代码
  end
  FilesBrowserManager.refresh()
  notFirstOnResume = true
  PluginsUtil.callElevents("onResume", notFirstOnResume)
end

function onResult(name, action, content)
  local processed=false
  if action == "project_created_successfully" then
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
  --print(true)
  if FilesTabManager.openState then
    FilesTabManager.saveFile()
  end
end

function onStart()
  activityStopped = false
end

function onStop()
  --print(true)
  activityStopped = true
end

function onDestroy()
  if magnifierUpdateTi and magnifierUpdateTi.isRun() then
    magnifierUpdateTi.stop()
  end
  PluginsUtil.callElevents("onDestroy")
end

function onKeyDown(keyCode, event)
  TouchingKey = true
end

function onKeyUp(keyCode, event)
  if TouchingKey then
    if keyCode == KeyEvent.KEYCODE_BACK then -- 返回键事件
      if FilesBrowserManager.openState and nowDevice ~= "pc" then -- 没有打开键盘且已打开侧滑，且设备为手机
        if ProjectManager.openState then
          -- todo:转到上一级文件夹
          local directoryFile=FilesBrowserManager.directoryFile
          local directoryPath=directoryFile.getPath()
          if directoryPath=="/" or isSamePathFileByPath(directoryPath,ProjectManager.nowPath) then
            ProjectManager.closeProject()
           else
            FilesBrowserManager.refresh(directoryFile.getParentFile())
          end
         else
          FilesBrowserManager.close()
        end
        return true
        -- todo:elseif 已打开预览模式
        -- todo:关闭预览模式
       else -- 啥都没打开
        if (System.currentTimeMillis() - lastBackTime) > 2000 then
          showSnackBar(R.string.exit_toast)
          lastBackTime = System.currentTimeMillis()
          return true
        end
      end
     else
      local success,result=pcall(function()--华为MPencil双击功能
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
end

function onRestoreInstanceState(savedInstanceState)
  toggle.syncState()
  local fileBrowserOpenState=savedInstanceState.getBoolean("filebrowser_openstate")
  if fileBrowserOpenState then
    FilesBrowserManager.open()
   else
    FilesBrowserManager.close()
  end
end

function onSaveInstanceState(savedInstanceState)
  savedInstanceState.putBoolean("filebrowser_openstate",FilesBrowserManager.openState)
  savedInstanceState.putString("prjpath",ProjectManager.nowPath)
  if ProjectManager.openState then
    savedInstanceState.putString("dirpath",FilesBrowserManager.directoryFile.getPath())
  end
end


toggle = ActionBarDrawerToggle(activity, drawer, R.string.drawer_open, R.string.drawer_close)
drawer.addDrawerListener(toggle)

FilesTabManager.init()
EditorsManager.init()
FilesBrowserManager.init()


--[[

task(500,function()
  if safeModeEnable then
    appBarLayout.setElevation(0)
   else
    MyAnimationUtil.ScrollView.onScrollChange(NowEditor,NowEditor.getScrollX(),NowEditor.getScrollY(),0,0,appBarLayout,nil,true)
  end
end)]]



mainLay.ViewTreeObserver
.addOnGlobalLayoutListener(function()
  mainWidth=mainLay.getMeasuredWidth()
end)

screenConfigDecoder = ScreenFixUtil.ScreenConfigDecoder({
  onDeviceByWidthChanged=onDeviceByWidthChanged
})

onConfigurationChanged(activity.getResources().getConfiguration())
--[[
nowDevice=screenConfigDecoder.deviceByWidth
mainWidth=math.dp2int(screenConfigDecoder.screenWidthDp)
if nowDevice~="phone" then
  onDeviceByWidthChanged(nowDevice,"phone")
end
mainLay.ViewTreeObserver
.addOnGlobalLayoutListener(ScreenFixUtil.LayoutListenersBuilder.deviceByWidth(mainLay,onDeviceByWidthChanged,nowDevice))

]]

--在刷新后仍然为空，那就是关闭状态
if screenConfigDecoder.deviceByWidth~="pc" and FilesBrowserManager.openState == nil then
  FilesBrowserManager.setOpenState(false)
end

