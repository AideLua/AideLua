--[[
FilesBrowserManager: 文件浏览器管理器
FilesBrowserManager.openState; FilesBrowserManager.getopenState(): 文件浏览器打开状态
FilesBrowserManager.directoryFile; FilesBrowserManager.getDirectoryFile(): 获取当前文件夹File
FilesBrowserManager.directoryFilesList: 获取当前文件列表
FilesBrowserManager.folderIcons: 文件夹图标
FilesBrowserManager.fileColors: 文件图标颜色
FilesBrowserManager.relLibPathsMatch.paths: 相对文件路径匹配的字符串列表
FilesBrowserManager.relLibPathsMatch.types: 支持匹配的文件类型
FilesBrowserManager.open(): 打开文件浏览器
FilesBrowserManager.close(): 关闭文件浏览器
FilesBrowserManager.switchState(): 切换文件浏览器开启状态
FilesBrowserManager.init(): 初始化管理器

]]local FilesBrowserManager = {}
local openState = false
local adapterData={}
local directoryFile,adapter,layoutManager
--local directoryFilesList=nil
local filesPositions={}
--local projectsPath=getSharedData("projectsDir")
--local projectsFile=File(projectsPath)
--FilesBrowserManager.directoryFilesList = directoryFilesList
FilesBrowserManager.filesPositions = filesPositions

local folderIcons={
  build=R.drawable.ic_folder_cog_outline,
  gradle=R.drawable.ic_folder_cog_outline,
  [".gradle"]=R.drawable.ic_folder_cog_outline,
  [".idea"]=R.drawable.ic_folder_cog_outline,
  [".aidelua"]=R.drawable.ic_folder_cog_outline,
  res=R.drawable.ic_folder_table_outline,
  assets=R.drawable.ic_folder_zip_outline,
  assets_bin=R.drawable.ic_folder_zip_outline,
  key=R.drawable.ic_folder_key_outline,
  keys=R.drawable.ic_folder_key_outline,
}
FilesBrowserManager.folderIcons=folderIcons

local fileColors = {
  normal = 0xFF9E9E9E, -- 普通颜色
  active = theme.color.colorAccent, -- 一已打开文件颜色
  folder = 0xFFF9A825, -- 文件夹颜色

  -- 按文件类型
  APK = 0xFF00E676, -- 安卓应用程序
  LUA = 0xFF448AFF,
  ALY = 0xFF64B5F6,
  PNG = 0xFFF44336, -- 图片文件
  GRADLE = 0xFF0097A7,
  XML = 0xffff6f00, -- XML文件
  DEX = 0xFF00BCD4,
  JAVA = 0xFF2962FF,
  JAR = 0xffe64a19,
  ZIP = 0xFF795548, -- 压缩文件
  HTML = 0xffff5722,
  JSON = 0xffffa000
}
FilesBrowserManager.fileColors = fileColors

fileColors.JPG = fileColors.PNG
fileColors["7Z"] = fileColors.ZIP
fileColors.tar = fileColors.ZIP
fileColors.RAR = fileColors.ZIP
fileColors.SVG = fileColors.XML

function FilesBrowserManager.getProjectIconForGlide(projectPath,config,mainProjectPath)
  --local mainProjectPath=ReBuildTool.getMainProjectDirByConfig(projectPath,config)
  local adaptiveIcon--自适应图标
  --判断是不是table类型，如果是则进行夜间判断，如果是字符串则直接赋值
  if type(config.icon)=="table" then
    if ThemeUtil.isSysNightMode() then
      adaptiveIcon=config.icon.night or config.icon.day
     else
      adaptiveIcon=config.icon.day or config.icon.night
    end
   else
    adaptiveIcon=config.icon
  end
  adaptiveIcon=rel2AbsPath(adaptiveIcon,projectPath)


  --图标可能存在的目录
  local icons={
    adaptiveIcon,
    projectPath.."/ic_launcher-aidelua.png",
    projectPath.."/ic_launcher-playstore.png",
    mainProjectPath.."/ic_launcher-aidelua.png",
    mainProjectPath.."/ic_launcher-playstore.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher_round.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher.png",
    mainProjectPath.."/res/drawable/ic_launcher.png",
    mainProjectPath.."/res/drawable/icon.png",
  }
  for index,content in pairs(icons) do
    if content and File(content).isFile() then
      return content
      --break--有图标，停止循环
    end
  end
  return android.R.drawable.sym_def_app_icon--前面没有返回，就返回默认图标
end

function FilesBrowserManager.getFileIconRIdByType(fileType)
  local icon=R.drawable.ic_file_outline
  if fileType then
    icon=ProjectUtil.FileIcons[fileType] or icon
  end
  return icon
end

function FilesBrowserManager.getFolderIconResIdByName(name)
  return folderIcons[name] or R.drawable.ic_folder_outline
end


local relLibPathsMatch = {} -- 相对库路径匹配
FilesBrowserManager.relLibPathsMatch = relLibPathsMatch

local relLibPathsMatchPath = {"^.-/src/main/assets_bin/(.+)%.", "^.-/src/main/luaLibs/(.+)%.",
  "^.-/src/main/jniLibs/.-/lib(.+)%.so", "^.-/src/main/java/(.+)%.",
  "^.-/src/main/assets/(.+)%."}
relLibPathsMatch.paths = relLibPathsMatchPath

local relLibPathsMatchTypes = {
  java = true,
  so = true,
  lua = true,
  luac = true,
  aly = true
}
relLibPathsMatch.types = relLibPathsMatchTypes

--打开文件浏览器
function FilesBrowserManager.open()
  if screenConfigDecoder.device == "phone" then
    drawer.openDrawer(Gravity.LEFT)
   else
    drawerChild.setVisibility(View.VISIBLE)
  end
  openState = true
end

--关闭文件浏览器
function FilesBrowserManager.close()
  if screenConfigDecoder.device == "phone" then
    drawer.closeDrawer(Gravity.LEFT)
   else
    drawerChild.setVisibility(View.VISIBLE)
  end
  openState = false
end

function FilesBrowserManager.switchState()
  if openState then
    FilesBrowserManager.close()
   else
    FilesBrowserManager.open()
  end
end


--[[
刷新文件夹/进入文件夹
@param file 要刷新或者进入的文件夹
@param upFile 是否是向上
@param force 强制刷新
]]
local loadingFiles = false -- 正在加载文件列表
function FilesBrowserManager.refresh(file,upFile,force)
  if force or not (loadingFiles) then
    loadingFiles=true
    Handler().postDelayed(Runnable({
      run = function()
        if loadingFiles then
          swipeRefresh.setRefreshing(true)
        end
      end
    }), 100)
    if not(ProjectManager.openState) then
      file=ProjectManager.projectsFile
      else
      file=file or directoryFile
    end
  

    if directoryFile then
      local nowDirectoryPath=directoryFile.getPath()--获取已打开文件夹路径
      if upFile then--如果是向上
        filesPositions[nowDirectoryPath]=nil--删除当前已打开文件夹滚动
       else
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
    end
    activity.newTask(function(newDirectory,projectopenState)
      require "import"
      import "java.io.File"
      import "java.util.Collections"
      import "java.util.Comparator"
      import "java.util.List"
      local filesList=newDirectory.listFiles()
      if filesList then
        filesList=luajava.astable(filesList)--转换为LuaTable
       else
        filesList={}
      end
      local newList={}--最终要返回的table
      if projectopenState then
        --按名称排序
        table.sort(filesList,function(a,b)
          return string.upper(a.getName())<string.upper(b.getName()) and a.isDirectory()
        end)
        local folderIndex=1
        for index,content in ipairs(filesList) do
          if content.isDirectory() then
            table.insert(newList,folderIndex,content)
            folderIndex=folderIndex+1
           else
            table.insert(newList,content)
          end
        end
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
          end
        end
      end
      return File(newList)
    end,
    function(dataList,newDirectory)
      --print(dataList[1])
      FilesBrowserManager.directoryFilesList=dataList
      swipeRefresh.setRefreshing(false)
      loadingFiles=false
      adapter.notifyDataSetChanged()

    end).execute({file,ProjectManager.openState})
  end
end

--初始化
function FilesBrowserManager.init()
  pathsTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
    onTabSelected = function(tab)
      local tag = tab.tag
      local path = tag.path
      --[[
    if path and path~=NowDirectory.getPath() then
      refresh(File(path),true)
    end]]
    end,
    onTabReselected = function(tab)
    end,
    onTabUnselected = function(tab)
    end
  }))

  if notSafeModeEnable then
    recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
      onGlobalLayout = function()
        if activity.isFinishing() then
          return
        end
        MyAnimationUtil.RecyclerView.onScroll(recyclerView, 0, 0, sideAppBarLayout, "LastSideActionBarElevation")
      end
    })
  end
  swipeRefresh.setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener {
    onRefresh = function()
      FilesBrowserManager.refresh(nil, nil, true)
    end
  })
  MyStyleUtil.applyToSwipeRefreshLayout(swipeRefresh)

  adapter=FileListAdapter(adapterData, item)
  recyclerView.setAdapter(adapter)
  layoutManager = LinearLayoutManager()
  recyclerView.setLayoutManager(layoutManager)
  recyclerView.addOnScrollListener(RecyclerView.OnScrollListener {
    onScrolled = function(view, dx, dy)
      MyAnimationUtil.RecyclerView.onScroll(view, dx, dy, sideAppBarLayout, "LastSideActionBarElevation")
    end
  })

  --判断侧滑开启状态。
  --如果侧滑为开启状态，那么文件浏览器一定是开启的。
  --如果侧滑为关闭状态，那么可能处于平板模式下，没有侧滑，需要单独处理
  openState = drawer.isDrawerOpen(Gravity.LEFT)
  if openState == false then
    openState = nil
  end
  drawer.addDrawerListener(DrawerLayout.DrawerListener({
    onDrawerSlide = function(view, slideOffset)
      if screenConfigDecoder.device == "phone" then
        if slideOffset > 0.5 and not (openState) then
          openState = true
         elseif slideOffset <= 0.5 and openState then
          openState = false
        end
      end
    end,
    onDrawerOpened = function(view)
      FilesTabManager.saveFile()--侧滑打开就保存文件
    end,
    onDrawerClosed = function(view)
    end,
    onDrawerStateChanged = function(newState)
    end
  }))

end

function FilesBrowserManager.getopenState()
  return openState
end
function FilesBrowserManager.getDirectoryFile()
  return directoryFile
end

function FilesBrowserManager.setDirectoryFile(file)
   directoryFile=file
end

return createVirtualClass(FilesBrowserManager)

--[[
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
]]
