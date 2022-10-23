--[[
FilesBrowserManager: metatable(class): 文件浏览器管理器
FilesBrowserManager.providers：提供者地图
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
]]
local FilesBrowserManager = {}
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
}
setmetatable(folderIcons,{__index=function(self,key)
    return R.drawable.ic_folder_outline
end})
FilesBrowserManager.folderIcons=folderIcons

local fileIcons={--各种文件的图标
  lua=R.drawable.ic_language_lua,
  luac=R.drawable.ic_language_lua,
  aly=R.drawable.ic_language_lua,
  xml=R.drawable.ic_xml,
  json=R.drawable.ic_code_json,
  java=R.drawable.ic_language_java,
  html=R.drawable.ic_language_html5,
  htm=R.drawable.ic_language_html5,
  txt=R.drawable.ic_file_document_outline,
  zip=R.drawable.ic_zip_box_outline,
  rar=R.drawable.ic_zip_box_outline,
  ["7z"]=R.drawable.ic_zip_box_outline,
  pdf=R.drawable.ic_file_pdf_box_outline,
  ppt=R.drawable.ic_file_powerpoint_box_outline,
  pptx=R.drawable.ic_file_powerpoint_box_outline,
  doc=R.drawable.ic_file_word_box_outline,
  docx=R.drawable.ic_file_word_box_outline,
  xls=R.drawable.ic_file_table_box_outline,
  xlsx=R.drawable.ic_file_table_box_outline,
  png=R.drawable.ic_image_outline,
  jpg=R.drawable.ic_image_outline,
  gif=R.drawable.ic_image_outline,
  jpeg=R.drawable.ic_image_outline,
  svg=R.drawable.ic_image_outline,
  apk=R.drawable.ic_android_debug_bridge,
  py=R.drawable.ic_language_python,
  pyw=R.drawable.ic_language_python,
  pyc=R.drawable.ic_language_python,
}
setmetatable(fileIcons,{__index=function(self,key)
    return R.drawable.ic_file_outline
end})
FilesBrowserManager.fileIcons=fileIcons


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

setmetatable(fileColors,{__index=function(self,key)
    return self.normal
end})

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

local hiddenBool2Alpha={
  ["true"]=0.5,
  ["false"]=1
}

function FilesBrowserManager.getIconAlphaByName(fileName)
  return hiddenBool2Alpha[tostring(toboolean(hiddenFiles[fileName] or fileName:find("^%.")))]
end


function FilesBrowserManager.getProjectIconForGlide(projectPath,config,mainProjectPath)
  --local mainProjectPath=ReBuildTool.getMainProjectDirByConfig(projectPath,config)
  local adaptiveIcon--自适应图标
  --判断是不是table类型，如果是则进行夜间判断，如果是字符串则直接赋值
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



local relLibPathsMatch = {} -- 相对库路径匹配
FilesBrowserManager.relLibPathsMatch = relLibPathsMatch

local relLibPathsMatchPaths = {
  "^.-/src/main/assets_bin/sub/.-/(.+)%.",
  "^.-/src/main/assets_bin/sub/.-/(.+)$",
  "^.-/src/main/assets_bin/activity/.-/(.+)%.",
  "^.-/src/main/assets_bin/activity/.-/(.+)$",
  "^.-/src/main/assets_bin/(.+)%.",
  "^.-/src/main/assets_bin/(.+)$",
  "^.-/src/main/assets/(.+)%.",
  "^.-/src/main/assets/(.+)$",
  "^.-/src/main/luaLibs/(.+)%.",
  "^.-/src/main/luaLibs/(.+)$",
  "^.-/src/main/jniLibs/.-/lib(.+)%.so",
  "^.-/src/main/java/lua/(.+)%.",
  "^.-/src/main/java/lua/(.+)$",
  "^.-/src/main/java/(.+)%.java",
  "^.-/src/main/java/(.+)%.kt",
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


--[[
刷新文件夹/进入文件夹
@param file 要刷新或者进入的文件夹
@param upFile 是否是向上
@param force 强制刷新
@param atOnce 立刻显示进度条
]]
local loadingFiles = false -- 正在加载文件列表
function FilesBrowserManager.refresh(file,upFile,force,atOnce)
  if force or not (loadingFiles) then
    loadingFiles=true
    if atOnce then
      swipeRefresh.setRefreshing(true)
     else
      Handler().postDelayed(Runnable({
        run = function()
          if loadingFiles then
            swipeRefresh.setRefreshing(true)
          end
        end
      }), 100)
    end

    if ProjectManager.openState then
      file=file or directoryFile
      if isSamePathFileByPath(file.getPath(),ProjectManager.nowFile.getParent()) then
        ProjectManager.closeProject(false)
        file=ProjectManager.projectsFile
      end
     else
      file=ProjectManager.projectsFile
    end


    if file then
      local nowDirectoryPath=file.getPath()--获取已打开文件夹路径
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
    activity.newTask(function(newDirectory,projectOpenState)
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
      if projectOpenState then
        --按名称排序
        table.sort(filesList,function(a,b)
          return string.upper(a.getName())<string.upper(b.getName())
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
      return File(newList),newDirectory
    end,
    function(dataList,newDirectory)
      local path=newDirectory.getPath()
      --刷新路径指示器
      if ProjectManager.openState then
        local oldPath
        local nowPrjPathParent=ProjectManager.nowFile.getParent()
        if directoryFile then
          oldPath=directoryFile.getPath()
          if not(String(oldPath).startsWith(nowPrjPathParent)) then
            oldPath=nowPrjPathParent
          end
          if not(String(path).startsWith(nowPrjPathParent)) then
            path=nowPrjPathParent
          end
         else
          oldPath=nowPrjPathParent
        end

        if oldPath~=path then
          --如果是返回
          if String(oldPath).startsWith(path) and oldRichAnim then
            local position=#pathSplitList
            for name in string.split(ProjectManager.shortPath(oldPath,true,path),"/") do
              if name~="" then
                table.remove(pathSplitList,position)
                if position>1 then
                  pathAdapter.notifyItemChanged(position-2)
                end
                pathAdapter.notifyItemRemoved(position-1)
                position=position-1
              end
            end
            --如果是前进
           elseif String(path).startsWith(oldPath) and oldRichAnim then
            local rootPath=oldPath
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
            local rootPath=ProjectManager.nowFile.getParent()
            for name in string.split(ProjectManager.shortPath(path,true,rootPath),"/") do
              if name~="" then
                rootPath=rootPath.."/"..name
                table.insert(pathSplitList,{name,rootPath})
              end
            end
            pathAdapter.notifyDataSetChanged()
          end
        end
        directoryFile=newDirectory
       else
        table.clear(pathSplitList)
        directoryFile=nil
        pathAdapter.notifyDataSetChanged()
      end
      table.clear(adapterData)

      --directoryFile=newDirectory
      FilesBrowserManager.directoryFilesList=dataList
      FilesBrowserManager.nowFilePosition=nil
      swipeRefresh.setRefreshing(false)
      loadingFiles=false

      adapter.notifyDataSetChanged()
      pathPlaceholderView.setVisibility(View.GONE)
      pathLayoutManager.scrollToPosition(#pathSplitList-1)
      local scroll=filesPositions[path]
      if scroll then
        layoutManager.scrollToPositionWithOffset(scroll[1],scroll[2])
       else
        layoutManager.scrollToPosition(0)
      end
    end).execute({file,ProjectManager.openState})
  end
end

function FilesBrowserManager.clearAdapterData()
  table.clear(adapterData)
  FilesBrowserManager.directoryFilesList=nil
  FilesBrowserManager.nowFilePosition=nil
  adapter.notifyDataSetChanged()
end

function FilesBrowserManager.onCreateContextMenu(menu,view,menuInfo)
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
      local config={
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
      local copyMenu=menu.findItem(R.id.subMenu_copy)
      local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
      local referenceMenu=menu.findItem(Rid.menu_reference)--引用资源
      local renameMenu=menu.findItem(Rid.menu_rename)--重命名
      local copyMenuBuilder=copyMenu.getSubMenu()

      table.foreach(providers.menuProviders,function(index,content)
        content(menu,config)
      end)
      table.foreach(providers.copyMenuProviders,function(index,content)
        content(copyMenuBuilder,config)
      end)

      copyMenu.setVisible(config.copyMenuVisible)
      openInNewWindowMenu.setVisible(config.openInNewWindowMenuVisible)
      referenceMenu.setVisible(config.referenceMenuVisible)
      renameMenu.setVisible(config.renameMenuVisible)

      menu.setCallback({
        onMenuItemSelected=function(menu,item)
          local id=item.getItemId()
          if id==Rid.menu_delete then--删除
            deleteFileDialog(title,file)
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
  --directoryFile=ProjectManager.projectsFile
  swipeRefresh.setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener {
    onRefresh = function()
      FilesBrowserManager.refresh()
    end
  })
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

  pathAdapter=FilePathAdapter(pathItem)
  pathRecyclerView.setAdapter(pathAdapter)
  pathLayoutManager = LinearLayoutManager()
  pathLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL)
  --pathLayoutManager.setStackFromEnd(true)
  pathRecyclerView.setLayoutManager(pathLayoutManager)
  activity.registerForContextMenu(recyclerView)
  recyclerView.onCreateContextMenu=function(menu,view,menuInfo)
    FilesBrowserManager.onCreateContextMenu(menu,view,menuInfo)
  end

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

  recyclerView.onDrag=function(view,event)
    local action=event.getAction()
    if action==DragEvent.ACTION_DRAG_STARTED then
      --[[
      local desc=event.getClipDescription()--必须有描述，必须为文件
      if not(desc and desc.getMimeTypeCount()~=0 and desc.getMimeType(0)~="text/plain") and ProjectManager.openState then
        return false
      end]]
     elseif action==DragEvent.ACTION_DRAG_ENTERED then
      view.setBackgroundColor(theme.color.rippleColorAccent)
     elseif action==DragEvent.ACTION_DRAG_EXITED then
      view.setBackgroundColor(0)
     elseif action==DragEvent.ACTION_DROP then
      view.setBackgroundColor(0)
      if ProjectManager.openState then
        local dropPermissions=activity.requestDragAndDropPermissions(event)
        local data=event.getClipData()
        local count=data.getItemCount()
        if count>0 then
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
              FilesBrowserManager.refresh()
            end
          end
        end
        dropPermissions.release()
      end
    end
    return true
  end
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


