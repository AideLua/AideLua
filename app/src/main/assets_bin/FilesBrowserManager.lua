---@class FilesBrowserManager
--[[
FilesBrowserManager: metatable(class): 文件浏览器管理器
FilesBrowserManager.providers：提供者映射
FilesBrowserManager.providers.menuProviders：ContextMenu提供者列表
FilesBrowserManager.providers.copyMenuProviders：复制菜单提供者列表
FilesBrowserManager.openState; FilesBrowserManager.getOpenState(): boolean: 文件浏览器打开状态
FilesBrowserManager.directoryFile; FilesBrowserManager.getDirectoryFile(): java.io.File: 获取当前文件夹File
FilesBrowserManager.directoryFilesList: String[]: 获取当前文件列表
FilesBrowserManager.folderIcons: table(map): 文件夹图标
FilesBrowserManager.fileColors: table(map): 文件图标颜色
FilesBrowserManager.relLibPathsMatch.paths: table(list): 相对文件路径匹配的字符串列表
FilesBrowserManager.relLibPathsMatch.types: table(list): 支持匹配的文件类型
FilesBrowserManager.open(): 打开文件浏览器
FilesBrowserManager.close(): 关闭文件浏览器
FilesBrowserManager.switchState(): 切换文件浏览器开启状态
FilesBrowserManager.refresh(file,upFile,force,atOnce): 刷新文件浏览器
  file: java.io.File: 要刷新或者进入的文件夹
  upFile: boolean: 是否是向上
  force: boolean: 强制刷新
  atOnce: boolean: 立刻显示进度条
FilesBrowserManager.init(): 初始化管理器
FilesBrowserManager.highlightIndex: 高亮显示的项目索引
]]
local FilesBrowserManager = {}
local lastContextMenu--上一次的ContextMenu，用于拖放时关闭Menu
local passDragFileTime=0--拖放排除次数，因为自己本身就有拖动事件
local providers={
  menuProviders={--参数：menuBuilder,config
  },
  copyMenuProviders={
    function(menuBuilder,config)--复制菜单默认提供者
      if ProjectManager.openState then
        CopyMenuUtil.addSubMenus(menuBuilder,{config.javaRReference})
        CopyMenuUtil.addSubMenus(menuBuilder,getFilePathCopyMenus(config.inLibDirPath,
        config.filePath,
        config.fileRelativePath,
        config.fileName,
        config.isFile,
        config.isResDir,
        config.fileType))
      end
    end
  }
}--提供者们
FilesBrowserManager.providers=providers

local openState = false
local adapterData={}
FilesBrowserManager.adapterData = adapterData
local directoryFile,adapter,layoutManager
local pathAdapter,pathLayoutManager
local pathSplitList={}
FilesBrowserManager.pathSplitList = pathSplitList
local filesPositions={}
FilesBrowserManager.filesPositions = filesPositions

local folderIcons={
  [".git"]=R.drawable.ic_folder_cog_outline,
  [".github"]=R.drawable.ic_folder_cog_outline,
  [".gradle"]=R.drawable.ic_folder_cog_outline,
  [".idea"]=R.drawable.ic_folder_cog_outline,
  [".vscode"]=R.drawable.ic_folder_cog_outline,
  [".obsidian"]=R.drawable.ic_folder_cog_outline,
  build=R.drawable.ic_folder_cog_outline,
  wrapper=R.drawable.ic_folder_cog_outline,
  gradle=R.drawable.ic_folder_cog_outline,
  [".aidelua"]=R.drawable.ic_folder_cog_outline,
  res=R.drawable.ic_folder_table_outline,
  assets=R.drawable.ic_folder_zip_outline,
  assets_bin=R.drawable.ic_folder_zip_outline,
  key=R.drawable.ic_folder_key_outline,
  keys=R.drawable.ic_folder_key_outline,
  node_modules=R.drawable.ic_folder_cog_outline,
  assets_bin=R.drawable.ic_folder_home_outline,
  assets=R.drawable.ic_folder_home_outline,
}
setmetatable(folderIcons,{__index=function(self,key)
    return R.drawable.ic_folder_outline--默认是普通文件夹图标
end})
FilesBrowserManager.folderIcons=folderIcons

local fileIcons={--各种文件的图标
  --Lua
  lua=R.drawable.ic_language_lua,
  luac=R.drawable.ic_language_lua,
  aly=R.drawable.ic_language_lua,

  --Java
  java=R.drawable.ic_language_java,
  kt=R.drawable.ic_language_kotlin,

  --Python
  py=R.drawable.ic_language_python,
  pyw=R.drawable.ic_language_python,
  pyc=R.drawable.ic_language_python,

  xml=R.drawable.ic_xml,
  json=R.drawable.ic_code_json,

  --网页
  html=R.drawable.ic_language_html5,
  htm=R.drawable.ic_language_html5,

  --压缩类
  zip=R.drawable.ic_zip_box_outline,
  rar=R.drawable.ic_zip_box_outline,
  ["7z"]=R.drawable.ic_zip_box_outline,
  jar=R.drawable.ic_zip_box_outline,

  gradle=R.drawable.ic_language_gradle,

  --word类
  pdf=R.drawable.ic_file_pdf_box_outline,
  ppt=R.drawable.ic_file_powerpoint_box_outline,
  pptx=R.drawable.ic_file_powerpoint_box_outline,
  doc=R.drawable.ic_file_word_box_outline,
  docx=R.drawable.ic_file_word_box_outline,
  xls=R.drawable.ic_file_table_box_outline,
  xlsx=R.drawable.ic_file_table_box_outline,
  txt=R.drawable.ic_file_document_outline,
  md=R.drawable.ic_language_markdown_outline,
  markdown=R.drawable.ic_language_markdown_outline,

  --图片类
  png=R.drawable.ic_image_outline,
  jpg=R.drawable.ic_image_outline,
  gif=R.drawable.ic_image_outline,
  jpeg=R.drawable.ic_image_outline,
  webp=R.drawable.ic_image_outline,
  svg=R.drawable.ic_image_outline,

  --安装包类
  apk=R.drawable.ic_android,
  apks=R.drawable.ic_android,
  aab=R.drawable.ic_android,
  hap=R.drawable.ic_all_application,
  exe=R.drawable.ic_windows,

  --终端脚本类(不包含py，lua)
  sh=R.drawable.ic_terminal,
  bat=R.drawable.ic_terminal,
}
setmetatable(fileIcons,{__index=function(self,key)
    return R.drawable.ic_file_outline--默认是未知文件图标
end})
FilesBrowserManager.fileIcons=fileIcons


local fileColors = {
  normal = 0xFF9E9E9E, -- 普通颜色
  active = theme.color.colorAccent, -- 一已打开文件颜色
  folder = 0xFFF9A825, -- 文件夹颜色

  -- 按文件类型
  APK = 0xFF00E676, -- 安卓应用程序
  APKS = 0xFF00E676,
  AAB = 0xFF00E676,
  HAP = 0xff304ffe,
  EXE = 0xff2979ff,

  LUA = 0xff2962ff,
  ALY = 0xff2196f3,

  PNG = 0xFFF44336, -- 图片文件
  JPG = 0xFFF44336,
  WEBP = 0xFFF44336,

  XML = 0xffff6f00, -- XML文件
  SVG = 0xffff6f00,

  DEX = 0xFF00BCD4,
  JAVA = 0xFF2962FF,
  KT=0xff7c4dff,
  JAR = 0xffe64a19,

  GRADLE = 0xFF0097A7,
  MD=theme.color.textColorPrimary,
  MARKDOWN=theme.color.textColorPrimary,

  HTML = 0xffff5722,
  HTM = 0xffff5722,
  JSON = 0xffffa000,

  ZIP = 0xFF795548, -- 压缩文件
  ["7Z"] = 0xFF795548,
  TAR = 0xFF795548,
  RAR = 0xFF795548,

  DOC=0xff448aff,
  DOCX=0xff448aff,
  PPT=0xffff5722,
  PPTX=0xffff5722,
  XLS=0xff4caf50,
  XLSX=0xff4caf50,
  PDF=0xfff44336,

  BAT=theme.color.textColorPrimary,
  SH=theme.color.textColorPrimary,
}
FilesBrowserManager.fileColors = fileColors

setmetatable(fileColors,{__index=function(self,key)
    return self.normal
end})

--隐藏文件映射
local hiddenFiles={
  gradlew=true,
  ["gradlew.bat"]=true,
  ["luajava-license.txt"]=true,
  ["lua-license.txt"]=true,
  [".gitignore"]=true,
  gradle=true,
  build=true,
  ["init.lua"]=true,
  libs=true,
  cache=true,
  caches=true,
}

--将布尔值转换为透明度
local hiddenBool2Alpha={
  ["true"]=0.5,
  ["false"]=1
}

local loadingFiles = false -- 正在加载文件列表
local showProgressHandler=Handler()
local showProgressRunnable=Runnable({
  run = function()
    swipeRefresh.setRefreshing(true)
  end
})

local recyclerViewCardTranslationXAnimator
local recyclerViewAlphaAnimator
local homingRunnable=Runnable({
  run = function()
    if recyclerViewCard.getTranslationX()~=0 then
      recyclerViewCardTranslationXAnimator=ObjectAnimator.ofFloat(recyclerViewCard,"translationX",{0})
      .setDuration(200)
      .setInterpolator(DecelerateInterpolator())
      .start()
    end
    if recyclerView.getAlpha()~=1 then
      recyclerViewAlphaAnimator=ObjectAnimator.ofFloat(recyclerView,"alpha",{1})
      .setDuration(200)
      .setInterpolator(DecelerateInterpolator())
      .start()
    end
  end
})

--通过文件名获取透明度，智能判断文件名前缀
function FilesBrowserManager.getIconAlphaByName(fileName)
  return hiddenBool2Alpha[tostring(toboolean(hiddenFiles[fileName] or fileName:find("^%.")))]
end

---为Gradle获取项目路径
---在 v5.1.0(51099) 废除
function FilesBrowserManager.getProjectIconForGlide(projectPath,config,mainProjectPath)
  print("警告:","FilesBrowserManager.getProjectIconForGlide","此API在 v5.1.0 (51099) 废弃")
  local adaptiveIcon
  if type(config.icon)=="table" then
    if ThemeUtil.isNightMode() then
      adaptiveIcon=config.icon.night or config.icon.day
     else
      adaptiveIcon=config.icon.day or config.icon.night
    end
   else
    adaptiveIcon=config.icon
  end
  if adaptiveIcon then
    adaptiveIcon=rel2AbsPath(adaptiveIcon,projectPath)
  end
  local icons={
    adaptiveIcon,
    projectPath.."/ic_launcher-playstore.png",
    projectPath.."/ic_launcher-aidelua.png",
    mainProjectPath.."/ic_launcher-playstore.png",
    mainProjectPath.."/ic_launcher-aidelua.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher_round.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher.png",
    mainProjectPath.."/res/drawable/ic_launcher.png",
    mainProjectPath.."/res/drawable/icon.png",
  }
  for index,content in pairs(icons) do
    local file=File(content)
    if content and file.isFile() then
      luajava.clear(file)
      return content
    end
    luajava.clear(file)
  end
  return android.R.drawable.sym_def_app_icon
end



local relLibPathsMatch = {} -- 相对库路径匹配
FilesBrowserManager.relLibPathsMatch = relLibPathsMatch

local relLibPathsMatchPaths = {
  "^[^/]-/src/main/assets_bin/sub/.-/(.+)%.",
  "^[^/]-/src/main/assets_bin/sub/.-/(.+)$",
  "^[^/]-/src/main/assets_bin/activity/.-/(.+)%.",
  "^[^/]-/src/main/assets_bin/activity/.-/(.+)$",
  "^[^/]-/src/main/assets_bin/(.+)%.",
  "^[^/]-/src/main/assets_bin/(.+)$",
  "^[^/]-/src/main/assets/(.+)%.",
  "^[^/]-/src/main/assets/(.+)$",
  "^[^/]-/src/main/luaLibs/(.+)%.",
  "^[^/]-/src/main/luaLibs/(.+)$",
  "^[^/]-/src/main/jniLibs/.-/lib(.+)%.so",
  "^[^/]-/src/main/java/lua/(.+)%.",
  "^[^/]-/src/main/java/lua/(.+)$",
  "^[^/]-/src/main/java/(.+)%.java",
  "^[^/]-/src/main/java/(.+)%.kt",
}
relLibPathsMatch.paths = relLibPathsMatchPaths

local relLibPathsMatchTypes = {
  java = true,
  so = true,
  lua = true,
  luac = true,
  aly = true
}
relLibPathsMatch.types = relLibPathsMatchTypes

--路径RecyclerView，解决与侧滑手势的冲突
function FilesBrowserManager.PathRecyclerViewBuilder(context)
  local view
  view=luajava.override(RecyclerView,{
    onInterceptTouchEvent=function(super,event)
      if view.canScrollHorizontally(1) then
        sideAppBarLayout.requestDisallowInterceptTouchEvent(true)--不能请求自己，因为会导致不滚动
      end
      return super(event)
    end,
  },context)
  return view
end

---在 v5.1.0(51099) 添加
---添加了拖放的RecyclerView
function FilesBrowserManager.FilesRecyclerViewBuilder(context)
  local view
  view=luajava.override(MyRecyclerView,{
    onInterceptTouchEvent=function(super,event)
      local action=event.getAction()
      local tag=view.tag
      local downEvent=tag.downEvent
      local x,y=event.getX(),event.getY()
      if action==MotionEvent.ACTION_DOWN then
        downEvent.x,downEvent.y=x,y
        tag.longClickedView=nil--刚按下时不可能有正在长按的view，但可能有记录过的view，所以先清空一下记录
       elseif action==MotionEvent.ACTION_MOVE then
        local longClickedView=tag.longClickedView
        if longClickedView then
          local relativeX,relativeY=x-downEvent.x,y-downEvent.y
          --拖放，有bug，现在只能在华为文件管理使用
          local data=longClickedView.tag._data--有数据
          if data and Build.VERSION.SDK_INT>24 and data.file and data.file.isFile() then--系统大于安卓N，并且当前是文件
            if relativeX>math.dp2int(16) or relativeX<-math.dp2int(16) or relativeY>math.dp2int(16) or relativeY<-math.dp2int(16) then
              if lastContextMenu then
                lastContextMenu.close()
                lastContextMenu=nil
              end
              passDragFileTime=passDragFileTime+1
              local uri=activity.getUriForFile(data.file)

              --授予应用权限（虽然这种方式很拉，但我可以兼容华为文件管理）
              pcall(authorizeHWApplicationPermissions,uri)

              local clipData=ClipData.newUri(activity.getContentResolver(),"data", uri)
              local shadow=DragShadowBuilder(longClickedView)
              --local shadow=DragShadowBuilder(shadowView)
              longClickedView.startDrag(clipData,shadow,"drag to other activity",View.DRAG_FLAG_GLOBAL|View.DRAG_FLAG_GLOBAL_URI_READ)
            end
            swipeRefresh.requestDisallowInterceptTouchEvent(true)--阻止侧滑关闭
            return nil--阻止滚动
          end
        end

       elseif action==MotionEvent.ACTION_UP or action==MotionEvent.ACTION_CANCEL then
        downEvent.x,downEvent.y=nil,nil
        tag.longClickedView=nil
      end
      return super(event)
    end
  },context)
  return view
end

FilesBrowserManager.RecyclerViewCardView={
  _baseClass=CardView,
  __call=function(self,context)
    local view
    local initialMotionX
    local lastOffset,lastBackState
    view=luajava.override(CardView,{
      onInterceptTouchEvent=function(super,event)
        local action=event.getAction()
        local x=event.getRawX()
        if action==MotionEvent.ACTION_DOWN then
          initialMotionX=x
          if view.getTranslationX()~=0 then
            initialMotionX=initialMotionX-math.pow(view.getTranslationX(),10/8)
          end
          lastBackState=false
          lastOffset=0
        end
        local offset=x-initialMotionX
        if offset<0 then
          offset=0
        end
        if ProjectManager.openState and offset>math.dp2int(32) then
          initialMotionX=x-math.pow(view.getTranslationX(),10/8)
          if recyclerViewAlphaAnimator then
            recyclerViewAlphaAnimator.cancel()
          end
          if recyclerViewCardTranslationXAnimator then
            recyclerViewCardTranslationXAnimator.cancel()
          end
          showProgressHandler.removeCallbacks(homingRunnable)
          --view.parent.requestDisallowInterceptTouchEvent(true)--不能请求自己，因为会导致不滚动
          return true
        end
        return super(event)
      end,
      onTouchEvent=function(super,event)
        local action=event.getAction()
        local x=event.getRawX()
        local offset=math.pow(x-initialMotionX,0.8)
        if offset<0 or tostring(offset)=="nan" then
          offset=0
        end
        if action==MotionEvent.ACTION_MOVE then
          view.setTranslationX(offset)
          recyclerView.setAlpha(math.dp2int(16)/offset)
          local nowBackState=offset>math.dp2int(16)
          if lastBackState~=nowBackState then
            view.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS,HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING)
            lastBackState=nowBackState
          end
          lastOffset=offset
         elseif action==MotionEvent.ACTION_UP or action==MotionEvent.ACTION_CANCEL then
          if offset>math.dp2int(16) and action==MotionEvent.ACTION_UP then
            local directoryFile=FilesBrowserManager.directoryFile
            if directoryFile then
              FilesBrowserManager.refresh(directoryFile.getParentFile())
            end
          end
        end
        if action==MotionEvent.ACTION_UP and oldRichAnim then
          showProgressHandler.postDelayed(homingRunnable, 100)
         elseif action==MotionEvent.ACTION_CANCEL or action==MotionEvent.ACTION_UP then
          homingRunnable.run()
        end
        return true
      end
    },context)
    return view
  end,
}
setmetatable(FilesBrowserManager.RecyclerViewCardView,FilesBrowserManager.RecyclerViewCardView)


--加载更多菜单
function FilesBrowserManager.loadMoreMenu(moreView)
  local popupMenu=PopupMenu(activity,moreView)
  moreView.setOnTouchListener(popupMenu.getDragToOpenListener())
  popupMenu.inflate(R.menu.menu_main_file_upfile)
  local menu=popupMenu.getMenu()
  --打开当前路径菜单
  local currentFileMenu=menu.findItem(R.id.menu_openDir_currentFile)
  FilesBrowserManager.currentFileMenu=currentFileMenu--保存一下，方便标签管理器随时禁用
  currentFileMenu.setEnabled(FilesTabManager.openState)--万一是先打开文件后再加载的列表呢
  popupMenu.onMenuItemClick=function(item)
    local id=item.getItemId()
    local Rid=R.id
    local openDirPath--点击后要打开的路径，空为不打开
    if id==Rid.menu_createFile then
      CreateFileUtil.showSelectTypeDialog(directoryFile)
     elseif id==Rid.menu_createDir then
      createDirsDialog(directoryFile)
     elseif id==Rid.menu_newActivity then
      SubActivityUtil.showSelectTypeDialog(directoryFile)
     else
      local nowProjectPath=ProjectManager.nowPath--当前工程路径
      local nowModuleName=FilesBrowserManager.getNowModuleDirName() or ProjectManager.nowConfig.mainModuleName
      if id==Rid.menu_openDir_currentFile then
        openDirPath=FilesTabManager.file.getParent()
       elseif id==Rid.menu_openDir_assets then
        openDirPath=("%s/%s/src/main/assets_bin"):format(nowProjectPath,nowModuleName)
       elseif id==Rid.menu_openDir_java then
        openDirPath=("%s/%s/src/main/java"):format(nowProjectPath,nowModuleName)
       elseif id==Rid.menu_openDir_lua then
        openDirPath=("%s/%s/src/main/luaLibs"):format(nowProjectPath,nowModuleName)
       elseif id==Rid.menu_openDir_res then
        openDirPath=("%s/%s/src/main/res"):format(nowProjectPath,nowModuleName)
       elseif id==Rid.menu_openDir_projectRoot then
        openDirPath=nowProjectPath
      end
    end
    if openDirPath then
      FilesBrowserManager.refresh(File(openDirPath))
    end
  end
  local moreTag={}
  moreView.tag=moreTag
  moreTag.popupMenu=popupMenu

  return popupMenu
end


--打开文件浏览器
function FilesBrowserManager.open()
  if screenConfigDecoder.deviceByWidth == "pc" then
    drawerChild.setVisibility(View.VISIBLE)
   else
    drawer.openDrawer(Gravity.LEFT)
  end
  openState = true
end

--关闭文件浏览器
function FilesBrowserManager.close()
  if screenConfigDecoder.deviceByWidth == "pc" then
    drawerChild.setVisibility(View.GONE)
   else
    drawer.closeDrawer(Gravity.LEFT)
  end
  openState = false
end

--切换文件浏览器打开状态
function FilesBrowserManager.switchState()
  if openState then
    FilesBrowserManager.close()
   else
    FilesBrowserManager.open()
  end
end

---记录滚动位置
---在 v5.1.0(51099) 添加
function FilesBrowserManager.recordScrollPosition()
  local nowDirectoryPath=directoryFile and directoryFile.getPath() or ProjectManager.projectsPath--获取已打开文件夹路径
  local pos=layoutManager.findFirstVisibleItemPosition()
  local listViewFirstChild=recyclerView.getChildAt(0)--获取列表第一个控件
  local scroll=0
  if listViewFirstChild then--有控件
    scroll=listViewFirstChild.getTop()--获取顶部距离
  end
  if pos==0 and scroll>=0 then
    filesPositions[nowDirectoryPath]=nil
   else
    filesPositions[nowDirectoryPath]={pos,scroll}
  end
end

---刷新文件夹/进入文件夹
---有内存泄露问题
---@param file File 要刷新或者进入的文件夹
---@param upFile boolean 是否是向上，在 v3.1.0(31099) 作废，之后的版本无实际作用
---@param fileName string 文件名
---@param force boolean 强制刷新
---@param atOnce boolean 立刻显示进度条
function FilesBrowserManager.refresh(file,fileName,force,atOnce)
  if force or not (loadingFiles) then
    loadingFiles=true

    if ProjectManager.openState then
      file=file or directoryFile or ProjectManager.nowFile
      --如果是工程路径的父路径，也就是用户关闭工程
      if isSamePathFileByPath(file.getPath(),ProjectManager.nowFile.getParent()) then
        ProjectManager.closeProject(false)
        --设置文件夹为全局的工程文件夹，
        file=ProjectManager.projectsFile
      end
     else
      file=ProjectManager.projectsFile
    end

    if atOnce or isSamePathFile(file,ProjectManager.projectsFile) then
      swipeRefresh.setRefreshing(true)
     else
      showProgressHandler.postDelayed(showProgressRunnable, 100)
    end

    activity.newTask(function(newDirectory,fileName,projectOpenState)
      require "import"
      import "java.io.File"
      import "java.util.Collections"
      import "java.util.Comparator"
      import "java.util.List"
      local filesListJ=newDirectory.listFiles()
      local filesList
      if filesListJ then
        filesList=luajava.astable(filesListJ)--转换为LuaTable
        luajava.clear(filesListJ)
       else
        filesList={}
      end
      local newList={}--最终要返回的table
      local itemIndex
      if projectOpenState then
        --按名称排序
        table.sort(filesList,function(a,b)
          return string.upper(a.getName())<string.upper(b.getName())
        end)
        local folderIndex=0
        for index,content in ipairs(filesList) do
          local isMatchName=content.getName()==fileName
          if content.isDirectory() then
            if itemIndex and itemIndex>folderIndex then--项目索引比文件夹索引大，说明这个索引的是文件，要加1。因为folderIndex从0开始，itemIndex从1开始，因此不需要+1
              itemIndex=itemIndex+1
            end
            folderIndex=folderIndex+1
            table.insert(newList,folderIndex,content)
            if isMatchName then
              itemIndex=folderIndex--因为后续还要加返回上一级项目，所以需要+1
            end
           else
            table.insert(newList,content)
            if isMatchName then
              itemIndex=index--此时index就是现在文件的索引。因为后续还要加返回上一级项目，所以需要+1
            end
          end
        end
        folderIndex=nil
       else
        --按时间倒序(默认的就是按时间排序的)
        table.sort(filesList,function(a,b)
          return a.lastModified()>b.lastModified()
        end)

        for index,content in ipairs(filesList) do
          local contentPath=content.getPath()
          local aideluaDir=contentPath.."/.aidelua"
          if content.isDirectory() and File(aideluaDir).isDirectory() then
            table.insert(newList,content)
            if content.getName()==fileName then
              itemIndex=table.size(newList)
            end
          end
        end
      end
      local newListJ=File(newList)
      newList=nil
      filesList=nil

      return newListJ,newDirectory,itemIndex
    end,
    function(dataList,newDirectory,itemIndex)
      showProgressHandler.removeCallbacks(showProgressRunnable)
      showProgressHandler.removeCallbacks(homingRunnable)
      swipeRefresh.setRefreshing(false)
      local path=newDirectory.getPath()
      local isBack,isForward=false,false
      --刷新路径指示器
      if ProjectManager.openState then
        local oldPath=directoryFile and directoryFile.getPath()
        local nowPrjPathParent=ProjectManager.nowFile.getParent()

        local oldPathJ=oldPath and String(oldPath)
        local pathJ=String(path)

        --判断合法路径，用于按需显示路径
        local legalNewPath=pathJ.startsWith(nowPrjPathParent.."/")--新路径为工程路径，也就是合法路径
        local legalOldPath=oldPathJ and oldPathJ.startsWith(nowPrjPathParent.."/")--同理旧路径
        local legalPath=oldPath and legalOldPath == legalNewPath--有旧路径并且合法性相同

        if oldPath==path then
          FilesBrowserManager.recordScrollPosition()--路径相同，记录一下位置
         else
          --是否返回
          isBack=oldPath and oldPathJ.startsWith(path)
          --是否前进
          isForward=oldPath and pathJ.startsWith(oldPath)

          luajava.clear(oldPathJ)
          luajava.clear(pathJ)

          if isForward then--是前进就记录滚动位置
            FilesBrowserManager.recordScrollPosition()
           elseif oldPath then--有oldPath，并且不是前进，说明有后退操作
            filesPositions[oldPath]=nil--删除当前已打开文件夹滚动
          end

          --如果是返回
          if isBack and legalPath and oldRichAnim then
            local position=#pathSplitList
            for name in string.split(ProjectManager.shortPath(oldPath,true,path),"/") do
              table.remove(pathSplitList,position)
              if position>1 then
                pathAdapter.notifyItemChanged(position-2)
              end
              pathAdapter.notifyItemRemoved(position-1)
              position=position-1
            end
            --如果是前进
           elseif isForward and legalPath and oldRichAnim then
            local rootPath=oldPath=="/" and "" or oldPath--oldPath为/时设置为空
            local position=#pathSplitList
            for name in string.split(ProjectManager.shortPath(path,true,rootPath),"/") do
              if name~="" then
                rootPath=rootPath.."/"..name
                table.insert(pathSplitList,{name,rootPath})
                if position>0 then
                  pathAdapter.notifyItemChanged(position-1)
                end
                pathAdapter.notifyItemInserted(position)
                position=position+1
              end
            end
            --判断不出来
           else
            table.clear(pathSplitList)
            local rootPath=nowPrjPathParent
            if not legalNewPath then--新路径不合法，说明新路径不在工程内
              rootPath=""
              table.insert(pathSplitList,{"ROOT","/"})
            end
            for name in string.split(ProjectManager.shortPath(path,true,rootPath),"/") do
              rootPath=rootPath.."/"..name
              table.insert(pathSplitList,{name,rootPath})
            end
            pathAdapter.notifyDataSetChanged()
          end

          --动画参数
          local anim_propertyName,anim_values
          --播放动画
          if oldRichAnim then
            if isBack then--后退
              anim_propertyName,anim_values="x", {-math.dp2int(16),0}
             elseif isForward then--前进
              anim_propertyName,anim_values="x", {math.dp2int(16),0}
             else
              anim_propertyName="alpha"
            end
            if anim_propertyName then
              if anim_propertyName~="alpha" then--下面就是透明动画，所以无需执行card动画
                --先取消动画，防止多个动画同时播放
                if recyclerViewCardTranslationXAnimator then
                  recyclerViewCardTranslationXAnimator.cancel()
                end
                recyclerViewCardTranslationXAnimator=ObjectAnimator.ofFloat(recyclerViewCard, anim_propertyName,anim_values)
                .setDuration(150)
                .setInterpolator(DecelerateInterpolator())
                .start()
              end
              if recyclerViewAlphaAnimator then
                recyclerViewAlphaAnimator.cancel()
              end
              recyclerViewAlphaAnimator=ObjectAnimator.ofFloat(recyclerView, "alpha",{0,1})
              .setDuration(250)
              .setInterpolator(DecelerateInterpolator())
              .start()
            end
          end

          directoryFile=newDirectory
        end--路径不同判断完毕
       else--未打开工程
        if directoryFile then
          local scroll=filesPositions[path]
          table.clear(filesPositions)
          filesPositions[path]=scroll
         else
          table.clear(filesPositions)
          FilesBrowserManager.recordScrollPosition()
        end
        --把文件浏览器位置摆正
        if oldRichAnim then--此修复无需在精简动画下生效
          recyclerViewCard.setTranslationX(0)
          recyclerView.setAlpha(1)
        end
        table.clear(pathSplitList)--清空路径指示器
        directoryFile=nil--移除当前路径标识
        pathAdapter.notifyDataSetChanged()
      end
      table.clear(adapterData)

      FilesBrowserManager.clearAdapterData(false)
      FilesBrowserManager.directoryFilesList=dataList

      FilesBrowserManager.highlightIndex=itemIndex
      loadingFiles=false

      adapter.notifyDataSetChanged()
      pathPlaceholderView.setVisibility(View.GONE)--用于在开启完整动画前提下快速显示列表。。。
      pathLayoutManager.scrollToPosition(#pathSplitList-1)


      if itemIndex then
        layoutManager.scrollToPosition(itemIndex)
       else
        --恢复到之前保存的滚动位置
        local scroll=filesPositions[path]
        if scroll and not isForward then--前进必须不能有记录
          layoutManager.scrollToPositionWithOffset(scroll[1],scroll[2])
         else
          layoutManager.scrollToPosition(0)
        end
      end
    end).execute({file,fileName,ProjectManager.openState})
  end
end

---清空适配器数据
---@param notify boolean 通知适配器刷新，默认为true
function FilesBrowserManager.clearAdapterData(notify)
  table.clear(adapterData)
  if FilesBrowserManager.directoryFilesList then
    luajava.clear(FilesBrowserManager.directoryFilesList)
    FilesBrowserManager.directoryFilesList=nil
  end
  if notify~=false then
    FilesBrowserManager.adapter.notifyDataSetChanged()
  end
end

--文件长按菜单（包括右键菜单）
function FilesBrowserManager.onCreateContextMenu(menu,view,menuInfo)
  lastContextMenu=menu
  if menuInfo then
    local position=menuInfo.position
    local data=adapterData[position]
    if data and position~=0 then
      local file=data.file
      local filePath=data.filePath
      local title=data.title--显示的名称
      local fileName=data.fileName
      local Rid=R.id

      local parentFile=file.getParentFile()
      local parentName=parentFile.getName()
      local action=data.action
      local isFile,fileType,fileRelativePath,isResDir,javaRReference

      local inLibDirPath=data.inLibDirPath

      local openState=ProjectManager.openState--工程打开状态

      if openState then
        isFile=file.isFile()
        fileType=data.fileType
        fileRelativePath=ProjectManager.shortPath(filePath,true,ProjectManager.nowPath)
        isResDir=parentName~="values" and not(parentName:find("values%-")) and ProjectManager.shortPath(filePath,true):find(".-/src/.-/res/.-/") or false
        javaRReference=isResDir and ("R.%s.%s"):format(parentName:match("(.-)%-") or parentName,fileName:match("(.+)%.") or fileName) or nil
       else
        isResDir=false
      end

      if openState and ((fileType and relLibPathsMatch.types[fileType]) or not(isFile)) then--已经打开了项目并且文件类型受支持
        if not(inLibDirPath) then
          for index,content in ipairs(relLibPathsMatch.paths) do
            inLibDirPath=fileRelativePath:match(content)
            if inLibDirPath then
              data.inLibDirPath=inLibDirPath
              break
            end
          end
        end
      end
      local config={--主要是给提供者
        data=data,
        title=title,
        javaRReference=javaRReference,
        copyMenuVisible=ProjectManager.openState,
        openInNewWindowMenuVisible=isFile or data.action=="openProject",
        referenceMenuVisible=toboolean(isResDir),
        renameMenuVisible=ProjectManager.openState,

        inLibDirPath=inLibDirPath,--从 relLibPathsMatchPaths 匹配出来的路径
        filePath=filePath,--文件路径
        fileRelativePath=fileRelativePath,--相对于工程根目录的相对路径
        fileName=fileName,--文件名
        isFile=isFile,--是不是文件
        isResDir=isResDir,--是否在Res目录
        fileType=fileType,--扩展名（不是MimeType）
      }

      menu.setHeaderTitle(config.title)
      local menuInflater=activity.getMenuInflater()
      menuInflater.inflate(R.menu.menu_main_file,menu)
      local copyNameMenu=menu.findItem(R.id.subMenu_copy_name)
      local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
      local referenceMenu=menu.findItem(Rid.menu_reference)--引用资源
      local renameMenu=menu.findItem(Rid.menu_rename)--重命名
      local copyNameMenuBuilder=copyNameMenu.getSubMenu()

      table.foreach(providers.menuProviders,function(index,content)
        content(menu,config)
      end)
      table.foreach(providers.copyMenuProviders,function(index,content)
        content(copyNameMenuBuilder,config)
      end)

      copyNameMenu.setVisible(config.copyMenuVisible)
      openInNewWindowMenu.setVisible(config.openInNewWindowMenuVisible)
      referenceMenu.setVisible(config.referenceMenuVisible)
      renameMenu.setVisible(config.renameMenuVisible)

      menu.setCallback({
        onMenuItemSelected=function(menu,item)
          local id=item.getItemId()
          if id==Rid.menu_delete then--删除
            deleteFileDialog(title,file)
           elseif id==Rid.menu_createCopy then
            local newName=(fileName:match("(.+)%.") or fileName).." 副本"
            if fileType then
              newName=newName.."."..fileType
            end
            local newPath=parentFile.getPath().."/"..newName
            local newFile=File(newPath)
            if newFile.exists() then
              showSnackBar(R.string.file_exists)
             else
              LuaUtil.copyDir(file,newFile)
              FilesBrowserManager.refresh(parentFile,newName)
            end
           elseif id==Rid.menu_rename then--重命名
            renameDialog(file)
           elseif id==Rid.menu_openInNewWindow then--新窗口打开
            if openState then
              activity.newActivity("main",{ProjectManager.nowPath,filePath},true,int(System.currentTimeMillis()))
             else
              activity.newActivity("main",{filePath},true,int(System.currentTimeMillis()))
            end
           elseif id==Rid.menu_reference then--引用资源
            local javaR=("R.%s.%s"):format(javaRReference)
            EditorsManager.actions.paste(javaR)
          end
        end
      })
    end
  end
end

--初始化
function FilesBrowserManager.init()
  --设置下拉刷新监听器
  swipeRefresh.onRefresh = function()
    FilesBrowserManager.refresh()
  end

  --应用下拉刷新风格
  MyStyleUtil.applyToSwipeRefreshLayout(swipeRefresh)

  adapter=FileListAdapter(item)
  recyclerView.setAdapter(adapter)
  layoutManager = LinearLayoutManager()
  recyclerView.setLayoutManager(layoutManager)
  recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
    onScrolled = function(view, dx, dy)
      MyAnimationUtil.RecyclerView.onScroll(view, dx, dy, sideAppBarLayout, "LastSideActionBarElevation")
  end})
  recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
    onGlobalLayout = function()
      if activity.isFinishing() then return end
      MyAnimationUtil.RecyclerView.onScroll(recyclerView, 0, 0, sideAppBarLayout, "LastSideActionBarElevation")
  end})

  --路径查看器
  pathAdapter=FilePathAdapter(pathItem)
  pathRecyclerView.setAdapter(pathAdapter)
  pathLayoutManager = LinearLayoutManager()
  pathLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL)
  --pathLayoutManager.setStackFromEnd(true)
  pathRecyclerView.setLayoutManager(pathLayoutManager)

  --长按菜单
  activity.registerForContextMenu(recyclerView)
  recyclerView.onCreateContextMenu=function(menu,view,menuInfo)
    FilesBrowserManager.onCreateContextMenu(menu,view,menuInfo)
  end
  recyclerView.setTag({})

  --判断侧滑开启状态。
  --如果侧滑为开启状态，那么文件浏览器一定是开启的。
  --如果侧滑为关闭状态，那么可能处于平板模式下，没有侧滑，需要单独处理
  openState = drawer.isDrawerOpen(Gravity.LEFT)
  if openState == false then
    openState = nil
  end
  drawer.addDrawerListener(DrawerLayout.DrawerListener({
    onDrawerSlide = function(view, slideOffset)
      if nowDevice ~= "pc" then
        if slideOffset > 0.5 and not(openState) then
          openState = true
         elseif slideOffset <= 0.5 and openState then
          openState = false
        end
      end
    end,
    onDrawerOpened = function(view)
      --FilesTabManager.saveFile()--侧滑打开就保存文件
    end,
    onDrawerClosed = function(view)
    end,
    onDrawerStateChanged = function(newState)
    end
  }))
  local dropFileFrameBackground

  recyclerView.onDrag=function(view,event)
    local action=event.getAction()
    switch action do
     case DragEvent.ACTION_DRAG_STARTED then
      local desc=event.getClipDescription()--必须有描述
      if not(desc and ProjectManager.openState) then
        return false
      end
      if passDragFileTime>0 then
        passDragFileTime=passDragFileTime-1
        return false--排除自己次数
      end
      if not dropFileFrameBackground then
        import "android.graphics.drawable.GradientDrawable"
        local dp_16=math.dp2int(16)
        dropFileFrameBackground = GradientDrawable()
        .setShape(GradientDrawable.RECTANGLE)
        .setStroke(math.dp2int(4), theme.color.colorAccent)
        .setCornerRadius(math.dp2int(16))
      end
      view.setBackground(dropFileFrameBackground)
     case DragEvent.ACTION_DRAG_ENTERED then
      dropFileFrameBackground.setColor(theme.color.rippleColorAccent)
     case DragEvent.ACTION_DRAG_EXITED then
      dropFileFrameBackground.setColor(0)
     case DragEvent.ACTION_DROP then
      dropFileFrameBackground.setColor(0)
      if ProjectManager.openState then
        local data=event.getClipData()
        local count=data.getItemCount()
        if count>0 then
          local dropPermissions=activity.requestDragAndDropPermissions(event)
          for index=0,count-1 do
            local uri=data.getItemAt(index).getUri()
            local inputStream=activity.getContentResolver().openInputStream(uri)
            local name=File(uri.getPath()).getName()
            pcall(function()
              name=File(FileInfoUtils.getPath(activity,uri)).getName()
            end)
            local newPath=directoryFile.getPath().."/"..name
            if File(newPath).exists() then
              showSnackBar(R.string.file_exists)
             else
              local outStream=FileOutputStream(newPath)
              LuaUtil.copyFile(inputStream, outStream)
              outStream.close()
            end
          end
          FilesBrowserManager.refresh()
          dropPermissions.release()
        end
      end
     case DragEvent.ACTION_DRAG_ENDED then
      dropFileFrameBackground.setColor(0)
      view.setBackgroundColor(0)
    end
    return true
  end
  local downEvent={}
  recyclerView.tag.downEvent=downEvent
  --FastScrollerBuilder(recyclerView).useMd2Style().build();
end

---在 v5.1.1(51199) 添加
---判断是不是模块根路径
---@param path 路径
function FilesBrowserManager.isModuleRootPath(path)
  return File(path.."/build.gradle").isFile() or File(path.."/.aidelua").isDirectory()
end

---在 v5.1.1(51199) 添加
---获取当前模块目录名称，如果当前路径不在模块内，则返回主模块名称
---@param fileRelativePath string 相对与项目的路径
---@return string 模块目录名称
function FilesBrowserManager.getNowModuleDirName(fileRelativePath)
  local nowProjectPath=ProjectManager.nowPath--当前工程路径
  local nowModuleName,fileRelativePath--当前模块名称，文件相对路径
  if ProjectManager.openState then
    fileRelativePath=fileRelativePath or ProjectManager.shortPath(directoryFile.getPath(),true,nowProjectPath)
    nowModuleName=fileRelativePath:match("^([^/]+)") or ProjectManager.nowConfig.mainModuleName
  end
  local modulePath=nowProjectPath.."/"..nowModuleName
  if not FilesBrowserManager.isModuleRootPath(modulePath) then
    nowModuleName=nil
  end
  return nowModuleName
end

function FilesBrowserManager.getOpenState()
  return openState
end

function FilesBrowserManager.setOpenState(newOpenState)
  openState=newOpenState
end

function FilesBrowserManager.getAdapter()
  return adapter
end

function FilesBrowserManager.getDirectoryFile()
  return directoryFile
end

function FilesBrowserManager.setDirectoryFile(file)
  directoryFile=file
end

function FilesBrowserManager.setDirectoryFilesList(list)
  FilesBrowserManager.directoryFilesList=list
end

return createVirtualClass(FilesBrowserManager)


