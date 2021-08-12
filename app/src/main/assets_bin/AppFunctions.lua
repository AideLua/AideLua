editorFunc={
  save=function()
    if IsEdtor then
      local success,message=saveFile()
      if success then
        showSnackBar(R.string.save_succeed)
      end
      return success,message
    end
  end,
  open=function()
    if screenConfigDecoder.device=="phone" then
      if drawerOpened then
        drawer.closeDrawer(Gravity.LEFT)
       else
        drawer.openDrawer(Gravity.LEFT)
      end
     else
      if drawerOpened then
        drawerChild.setVisibility(View.GONE)
        drawerOpened=false
       else
        drawerChild.setVisibility(View.VISIBLE)
        drawerOpened=true
      end
    end
  end,
  gotoline=function()
    if IsEdtor then
      NowEditor.gotoLine()
    end
  end,
  seach=function()
    if IsEdtor then
      NowEditor.search()
    end
  end,
  closeFile=function()
    if OpenedFile then
      local filePath=string.lower(NowFile.getPath())
      local tab=FilesTabList[filePath].tab
      closeFileAndTab(tab)
    end
  end,
  check=function(b)
    if NowEditor==luaEditor then
      local src=luaEditor.getText()
      src=src.toString()
      --[[
      if NowFile.getPath():find("%.aly$") then
        src="return "..src
      end]]
      local _,err=loadstring(src)
      if err then
        local line,data=err:match("%[string \".-%\"]:(%d+): (.+)")
        luaEditor.gotoLine(tonumber(line))
        showSnackBar(line..": "..data)
        return false
       else
        showSnackBar(R.string.checkCode_noGrammaticalErrors)
        return true
      end
     else
      showSnackBar(R.string.file_not_supported)
      return false
    end
  end,
  format=function()
    if IsEdtor then
      if (NowFileType=="lua" or NowFileType=="aly") then
        NowEditor.format()
        return true
        --[[
       elseif NowFileType=="java" then
        local code=""
        local scroll=NowEditor.getScrollY()
        local selection= NowEditor.getSelectionEnd()

        for advance,text,column in LuaLexerIteratorBuilder(NowEditor.text)
          code=code..text
        end
        NowEditor.setText(code,true)
        NowEditor.setSelection(selection)
        NowEditor.setScrollY(scroll)
]]
       else
        showSnackBar(R.string.file_not_supported)
        return false

      end
     else
      showSnackBar(R.string.file_not_supported)
      return false
    end
  end,
  undo=function()
    if IsEdtor then
      NowEditor.undo()
    end
  end,
  redo=function()
    if IsEdtor then
      NowEditor.redo()
    end
  end,
  run=function(path)
    local code,projectMainFile
    if IsEdtor then
      code=NowEditor.text
    end
    if OpenedProject then--打开了工程
      local projectPath=NowProjectDirectory.getPath()
      local configPath=ReBuildTool.getConfigPathByProjectDir(projectPath)

      local configFile=File(configPath)
      local succeed
      if OpenedFile and IsEdtor then
        succeed=saveFile()
       else
        succeed=true
      end
      if configFile.isFile() then--如果有文件
        if succeed then--保存成功
          local config=ReBuildTool.getConfigByFilePath(configPath)
          local projectMainPath=path or ReBuildTool.getMainProjectDirByConfig(projectPath,config).."/assets_bin/main.lua"
          projectMainFile=File(projectMainPath)

          if config.packageName then--如果可以使用另一个他自己打开就是用他自己，不能的话使用IDE
            local success,err=pcall(function()
              local intent=Intent(Intent.ACTION_VIEW,Uri.parse(projectMainPath))
              local componentName=ComponentName(config.packageName,"com.androlua.LuaActivity")
              intent.setComponent(componentName)
              activity.startActivity(intent)
            end)
            if not(success) then--无法通过调用其他app打开时
              runLuaFile(projectMainFile,code)
              MyToast.showToast(R.string.runCode_noApp)
            end
           else
            runLuaFile(projectMainFile,code)
            MyToast.showToast(R.string.runCode_noPackageName)
          end
         else
          showSnackBar(R.string.save_failed)
        end
       else
        showSnackBar(R.string.save_failed)
      end
     else
      if path then
        projectMainFile=File(path)
      end
      runLuaFile(projectMainFile,code)
    end
  end,
  commented=function(view)
    if IsEdtor then
      view=view or NowEditor
      local selectedText=view.getSelectedText()
      if #selectedText~=0 then
        if NowFileType=="lua" or NowFileType=="aly" or not(NowFileType) then--Lua类型
          if selectedText:find("\n") then
            local equals=""
            while selectedText:find("]"..equals.."]") do
              equals=equals.."="
            end
            view.paste("--["..equals.."["..selectedText.."]"..equals.."]")
           else
            view.paste("--"..selectedText.."")
          end
         else
          showSnackBar(R.string.file_not_supported)

        end
      end
    end
  end,
  search=function()
    if IsEdtor then
      local ids
      local idx=0
      ids=SearchActionMode({
        onEditorAction=function(view,actionId,event)
          if event then
            NowEditor.findNext(view.text)
          end
        end,
        onTextChanged=function(text)
          application.set("editor_search_text",text)
        end,
        onActionItemClicked=function(mode,item)
          local title=item.title
          if title==activity.getString(R.string.abc_searchview_description_search) then
            NowEditor.findNext(ids.searchEdit.text)
          end
        end,
        onDestroyActionMode=function(mode)
        end,
      })
      local searchContent=application.get("editor_search_text")
      if searchContent then
        ids.searchEdit.text=searchContent
        ids.searchEdit.setSelection(utf8.len(tostring(searchContent)))
      end
    end
  end
}
shortPath=ProjectUtil.shortPath

--[[
function setActiveFileItem(item,notifyDataSetChanged)
  if notSafeModeEnable then
    if NowFileShowData then
      --NowFileShowData.icon.colorFilter=nil;
      local fileType=NowFileShowData.fileType
      if fileType then
        fileType=string.upper(fileType)
      end
      NowFileShowData.icon.colorFilter=FileColor[fileType or "normal"] or FileColor.normal
      NowFileShowData.title.textColor=theme.color.textColorPrimary
      if NowFileShowData.highLightCard then
        NowFileShowData.highLightCard.cardBackgroundColor=0
      end
    end
    NowFileShowData=item
    if item and item.file.isFile() then
      --item.icon.colorFilter=theme.color.colorAccent;
      local fileType=item.fileType
      if fileType then
        fileType=string.upper(fileType)
      end
      item.icon.colorFilter=FileColor.active
      item.title.textColor=theme.color.colorAccent
      if item.highLightCard then
        item.highLightCard.cardBackgroundColor=theme.color.rippleColorAccent
      end
    end
  end
  if notifyDataSetChanged then
    adp.notifyDataSetChanged()
  end
end
]]

function getPathTab(index)
  local tag=PathsTabShowList[index]
  if tag then
    return tag.tab
   else
    local tab=pathsTabLay.newTab()--有就用以前的，没有就新建一个Tab
    if index==1 then
      tab.setIcon(nil)
     else
      tab.setIcon(R.drawable.ic_chevron_right)
    end
    local tabTag={tab=tab}
    tab.tag=tabTag
    pathsTabLay.addTab(tab)--在区域添加Tab

    local view=tab.view
    tabTag.view=view
    view.setPadding(math.dp2int(4),math.dp2int(4),math.dp2int(2),math.dp2int(4))
    view.setMinimumWidth(0)
    --local imageView=view.getChildAt(0)

    --print(imageView)

    table.insert(PathsTabShowList,tabTag)
    return tab
  end
end

function refreshPathsTab(path)
  local pathNames={}
  local rootPath=ProjectsPath
  for name in string.split(path,"/") do
    rootPath=rootPath.."/"..name
    table.insert(pathNames,{name,rootPath})
  end
  local maxTab=table.maxn(pathNames)
  local scrolled=pathsTabLay.getScrollX()

  for index,content in ipairs(pathNames) do
    local tab=getPathTab(index)
    tab.setText(content[1])--设置显示的文字
    local tabTag=tab.tag
    tabTag.path=content[2]

    local view=tab.view
    local textView=view.getChildAt(1)
    tabTag.textView=textView
    textView
    .setAllCaps(false)--关闭全部大写
    .setTextSize(12)

    if maxTab==index then
      pathsTabLay.setScrollX(scrolled)
      --tab.select()
      if safeModeEnable then
        tab.select()
       else
        task(10,function()
          tab.select()
        end)--选中Tab
      end
    end
  end
  local showListNum=table.maxn(PathsTabShowList)
  if showListNum>maxTab then
    for index=maxTab+1,showListNum do
      pathsTabLay.removeTab(PathsTabShowList[index].tab)
      PathsTabShowList[index]=nil
    end
  end
end

local loadingFiles=false--正在加载文件列表
function refresh(file,upFile,force)
  --recyclerView
  if force or not(loadingFiles) then--强制加载或者没有正在加载
    if file and ProjectUtil.isSelfFile(file,NowDirectory or ProjectsFile) then
      NowDirectoryFilesList={}
    end
    file=file or NowDirectory or ProjectsFile--增强兼容性
    swipeRefresh.setRefreshing(true)
    loadingFiles=true--正在加载列表

    if NowDirectory then
      local nowDirectoryPath=NowDirectory.getPath()--获取已打开文件夹路径
      if upFile then--如果是向上
        FilesListScroll[nowDirectoryPath]=nil--将当前已打开文件夹滚动设为0
       else
        local pos=layoutManager.findFirstVisibleItemPositions({0})[0]
        local listViewFirstChild=recyclerView.getChildAt(0)--获取列表第一个控件
        local scroll=0
        if listViewFirstChild then--有控件
          scroll=listViewFirstChild.getTop()--获取顶部距离
        end
        if pos==0 and scroll>=0 then
          FilesListScroll[nowDirectoryPath]=nil
         else
          FilesListScroll[nowDirectoryPath]={pos,scroll}
        end
      end
    end
    activity.newTask(function(NowDirectory,ProjectsPath)
      require "import"
      import "java.util.ArrayList"
      import "java.io.File"
      local filesList=NowDirectory.listFiles()
      local filePath=NowDirectory.getPath()
      if filesList then
        filesList=luajava.astable(filesList)--转换为LuaTable
       else
        filesList={}
      end
      local newList={}
      if not(filePath) or filePath==ProjectsPath then--未打开项目
        --按时间排序
        table.sort(filesList,function(a,b)
          return a.lastModified()<b.lastModified()
        end)
        for index,content in ipairs(filesList) do
          local contentPath=content.getPath()
          local aideluaDir=contentPath.."/.aidelua"
          if content.isDirectory() and File(aideluaDir).isDirectory() then
            table.insert(newList,content)
          end
        end

       else
        local newFilesList={}
        --按名称排序
        table.sort(filesList,function(a,b)
          return string.upper(a.getName())<string.upper(b.getName())
        end)
        for index,content in ipairs(filesList) do
          if content.isDirectory() then
            table.insert(newList,content)
           else
            table.insert(newFilesList,content)
          end
        end
        for index,content in ipairs(newFilesList) do
          table.insert(newList,content)
        end
      end

      return ArrayList(newList),NowDirectory
    end,
    function(filesList,NowDirectory)
      _G.NowDirectory=NowDirectory
      local nowPath=NowDirectory.getPath()
      if OpenedProject then
        if nowPath==ProjectsPath then
          closeProject()
         else
          pathsTabLay.setVisibility(View.VISIBLE)
          refreshPathsTab(shortPath(nowPath,true,ProjectsPath))
        end
      end

      NowDirectoryFilesList=luajava.astable(filesList)
      adp.notifyDataSetChanged()

      local scroll=FilesListScroll[NowDirectory.getPath()]
      if scroll then
        local pos=scroll[1] or 0
        layoutManager.scrollToPositionWithOffset(pos,0)
        --layoutManager.scrollToPosition(pos)--没反应
      end

      loadingFiles=false
      swipeRefresh.setRefreshing(false)
    end).execute({file,ProjectsPath})

  end
end



function runLuaFile(file,code)
  if file and file.isFile() then
    newActivity(file.getPath())
   else
    newSubActivity("RunCode",{code})
  end
end

function showSnackBar(text)
  if drawerOpened then
    MyToast(text,mainLay)
   else
    MyToast(text,editorGroup)
  end
end

--符号栏按钮点击时输入符号
function psButtonClick(view)
  NowEditor.paste(view.text)
end

--初始化符号栏按钮
function newPsButton(text)
  return loadlayout({
    AppCompatTextView;
    onClick=psButtonClick;
    text=text;
    gravity="center";
    layout_height="fill";
    --padding="8dp";
    typeface=Typeface.DEFAULT_BOLD;
    paddingLeft="8dp";
    paddingRight="8dp";
    minWidth="40dp";
    allCaps=false;
    --padding="16dp";
    focusable=true;
    textColor=theme.color.textColorPrimary;
    background=ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary)
  })
end


function isCompiledLuaFile(filePath)
  local ioFile = io.open(filePath, "r")
  if ioFile then
    local code=ioFile:read("*all")
    ioFile:close()
    if code~="" then
      local c=string.byte(code)
      if c <= 0x1c and c>= 0x1a and c~=" " and c~="\t" then
        return true
      end
    end
    return code
   else
    return nil
  end
end


--刷新Menu状态
function refreshMenusState()
  if LoadedMenu then
    for index,content in ipairs(StateByFileMenus) do
      content.setEnabled(OpenedFile)
    end
    for index,content in ipairs(StateByProjectMenus) do
      content.setEnabled(OpenedProject)
    end
    for index,content in ipairs(StateByFileAndEditorMenus) do
      content.setEnabled(OpenedFile and IsEdtor)
    end
    for index,content in ipairs(StateByEditorMenus) do
      content.setEnabled(IsEdtor)
    end
  end
end

function initFileTabView(tab,tabTag)
  local view=tab.view
  tabTag.view=view
  view.setPadding(math.dp2int(8),math.dp2int(4),math.dp2int(8),math.dp2int(4))
  view.setGravity(Gravity.LEFT|Gravity.CENTER)
  TooltipCompat.setTooltipText(view,tabTag.shortFilePath)
  local imageView=view.getChildAt(0)
  local textView=view.getChildAt(1)
  tabTag.imageView=imageView
  tabTag.textView=textView
  imageView.setPadding(math.dp2int(2),math.dp2int(2),math.dp2int(2),0)
  textView
  .setAllCaps(false)--关闭全部大写
  .setTextSize(12)
end

--用外部应用打开文件
function openFileITPS(path)
  import "android.webkit.MimeTypeMap"
  --import "android.content.Intent"
  --import "android.net.Uri"
  --import "java.io.File"
  local file=File(path)
  local name=file.getName()
  local extensionName=ProjectUtil.getFileTypeByName(name)
  local mime=MimeTypeMap.getSingleton().getMimeTypeFromExtension(extensionName)
  if mime then
    local intent=Intent()
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.setAction(Intent.ACTION_VIEW)
    intent.setType(mime)
    intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    --intent.putExtra(Intent.EXTRA_STREAM, activity.getUriForFile(file))
    intent.setDataAndType(activity.getUriForFile(file),mime)
    activity.startActivity(Intent.createChooser(intent,name))
  end
end

--打开文件
function openFile(file,reOpen,line)
  local succeeded,errMessage,inThirdPartySoftware
  local fileName=file.getName()
  local fileType=ProjectUtil.getFileTypeByName(fileName)
  local filePath=file.getPath()
  local lowerFilePath=string.lower(filePath)--因为文件路径不分大小写，所以统一转换为小写方便比较
  if OpenedFile and IsEdtor and not(reOpen) then--已经打开了文件并且不是重新打开
    local succeeded=saveFile()
    if not(succeeded) then
      local oldFileTabTag=FilesTabList[string.lower(NowFile.getPath())]
      if oldFileTabTag then
        oldFileTabTag.tab.select()
      end
      return false
    end
  end
  if fileType then
    --根据类型处理文件 开始
    if ProjectUtil.isTextFile(fileType) then
      --处理Lua文件
      if file.isFile() then
        local code=isCompiledLuaFile(filePath)
        if code==true then
          errMessage=R.string.file_cannot_open_compiled_file
         elseif code then
          local isSelfFile=false
          if OpenedFile then
            isSelfFile=ProjectUtil.isSelfFile(file,NowFile)
          end

          if isSelfFile then--重复打开文件
            if code~=NowEditor.text then
              NowEditor.setText(code,true)--打开文件并且保留历史记录
            end
           else--新的打开
            EditorUtil.switchEditor(EditorUtil.TextFileType2EditorType[fileType],EditorUtil.TextFileType2EditorLanguage[fileType])--将编辑器切换为Lua编辑器
            NowEditor.setText(code)
            --listenFile(filePath)
          end
          NowEditor.setSelection(line or activity.getSharedData("Selection"..file.getPath()) or 0)
          local scroll=getSharedData("Scroll"..file.getPath())
          if scroll then
            NowEditor.setScrollY(scroll)
          end
          succeeded=true
         else--没有东西
          errMessage=R.string.file_not_find--文件未找到
        end
       else--文件不存在
        errMessage=R.string.file_not_find--文件未找到
      end

     elseif fileType=="png" or fileType=="jpg" or fileType=="gif" then
      succeeded=true
      EditorUtil.switchEditor("PhotoView")--将编辑器切换为Lua编辑器
      
      local options=RequestOptions()
      options.skipMemoryCache(true)--跳过内存缓存
      options.diskCacheStrategy(DiskCacheStrategy.NONE)--不缓冲disk硬盘中
      Glide.with(activity).load(filePath).apply(options).into(NowEditor)
      appBarLayout.setElevation(0)

     elseif fileType=="svg" then
      succeeded=true
      EditorUtil.switchEditor("PhotoView")--将编辑器切换为Lua编辑器
      Sharp.loadFile(file).into(NowEditor)
      appBarLayout.setElevation(0)

     elseif fileType=="apk" then
      --处理Apk文件
      activity.installApk(filePath)--安装Apk
      succeeded=true
      inThirdPartySoftware=true
     else
      --啥也没处理
      succeeded=true
      inThirdPartySoftware=true
      openFileITPS(filePath)
      --errMessage=R.string.file_not_supported--文件不支持
    end--根据类型处理文件 结束
    if succeeded and not(inThirdPartySoftware) then--打开成功并且不是在第三方软件打开
      NowFile=file
      NowFileType=fileType
      OpenedFile=true--标记为已经打开了文件
      if not(loadingFiles) then
        adp.notifyDataSetChanged()
      end
      --setActiveFileItem(FilesDataList[filePath],true)--设置文件列表高亮

      local shortFilePath=shortPath(file.getPath(),true,ProjectsPath)

      refreshMenusState()
      setSharedData("openedfilepath_"..NowProjectDirectory.getName(),file.getPath())--保存已打开文件路径

      --[[if not(keepOpenDrawer) and not(reOpen) then
        drawer.closeDrawer(Gravity.LEFT)
      end]]
      --[[
      if not(drawerOpened) then
        actionBar.setSubtitle(shortFilePath)
      end]]
      local tab
      if FilesTabList[lowerFilePath] then--如果打开过文件，这直接返回Tab的table
        tab=FilesTabList[lowerFilePath].tab
       else
        tab=filesTabLay.newTab()--新建一个Tab
        tab.setText(fileName)--设置显示的文字
        if oldTabIcon and notSafeModeEnable then
          tab.setIcon(ProjectUtil.getFileIconResIdByType(fileType))
        end
        local tabTag={tab=tab,file=file,fileType=fileType,shortFilePath=shortFilePath}
        tab.tag=tabTag
        FilesTabList[lowerFilePath]=tabTag
        filesTabLay.addTab(tab)--在区域添加Tab
        initFileTabView(tab,tabTag)
      end
      if not(tab.isSelected()) then--避免调用tab里面的重复点击事件
        task(1,function()
          tab.select()
        end)--选中Tab
      end
      filesTabLay.setVisibility(View.VISIBLE)--显示Tab区域
      --[[
      if not(drawerOpened) and actionBar.getElevation()~=0 then--没有关闭ActionBar阴影
        actionBar.setElevation(0)--关闭ActionBar阴影
      end]]
     elseif not(succeeded) then--没有成功
      showSnackBar(errMessage)--显示错误信息
      if errMessage==R.string.file_not_find then
        closeFileAndTabByPath(lowerFilePath,true)
      end
    end
   else
    showSnackBar(R.string.file_not_supported)--没有扩展名的文件不支持
  end
  return succeeded,errMessage,inThirdPartySoftware
end

function reOpenFile()
  openFile(NowFile,true)
end

function saveFile()
  local succeeded,message
  if OpenedFile and IsEdtor then
    local file=NowFile
    local fileName=file.getName()
    local fileType=NowFileType
    local filePath=file.getPath()
    --print(fileType)
    if fileType then
      if ProjectUtil.isTextFile(fileType) then
        local ioFile=io.open(filePath,"w")
        if ioFile then
          ioFile:write(NowEditor.text)--写入文件
          ioFile:close()--关闭文件
          setSharedData("Selection"..file.getPath(),NowEditor.getSelectionEnd())--保存光标位置
          setSharedData("Scroll"..file.getPath(),NowEditor.getScrollY())--保存光标位置
          succeeded=true--已成功
         else--不存在文件
          succeeded,message=false,activity.getString(R.string.file_not_find)
        end
       else--不支持的文件类型
        succeeded,message=false,activity.getString(R.string.file_not_supported)
      end
    end
   else--文件未打开
    succeeded,message=false,activity.getString(R.string.file_not_find)
  end
  if not(succeeded) and IsEdtor then--没有成功
    if message then--有错误信息
      showSnackBar(formatResStr(R.string.save_failed_withMessage,{message}))
     else--没有错误信息
      showSnackBar(R.string.save_failed)
    end
  end
  return succeeded,message
end

function closeFile(doNotSave,keepSharedData)
  if OpenedFile then
    if not(doNotSave) then
      saveFile()
    end
    --setActiveFileItem(nil,true)

    --activity.setSharedData("openedfilepath_"..NowProjectDirectory.getName(),nil)
  end
  NowFile=nil
  NowFileType=nil
  OpenedFile=false
  EditorUtil.switchEditor("LuaEditor")--将编辑器切换为Lua编辑器
  NowEditor.text=DefaultEditorText[EditorUtil.NowEditorType]
  --[[
  if not(drawerOpened) then
    actionBar.setSubtitle(nil)
  end]]

  refreshMenusState()
  if OpenedProject and not(keepSharedData) then
    setSharedData("openedfilepath_"..NowProjectDirectory.getName(),nil)--将已打开的文件路径设置为空
  end
end

function closeFileAndTab(tab,doNotSave)--关闭文件并移除Tab
  local tag=tab.tag
  local filePath=string.lower(tag.file.getPath())
  if OpenedFile and string.lower(NowFile.getPath())==filePath then--如果是当前文件就关闭文件
    closeFile(doNotSave)
  end
  FilesTabList[filePath]=nil
  filesTabLay.removeTab(tab)
  if table.size(FilesTabList)==0 then--如果列表为0时
    filesTabLay.setVisibility(View.GONE)
    adp.notifyDataSetChanged()
    --[[
    if actionBar.getElevation()~=theme.integer.actionBarElevation and not(drawerOpened) then
      actionBar.setElevation(theme.integer.actionBarElevation)
    end]]
  end
end

function closeFileAndTabByPath(path,doNotSave)
  local tabConfig=FilesTabList[string.lower(path)]
  if tabConfig then
    local tab=tabConfig.tab
    closeFileAndTab(tab,doNotSave)
  end
end

--打开工程调用函数
function openProject(projectDirectory,file)
  if OpenedProject then
    closeProject()
  end
  local projectPath=projectDirectory.getPath()
  NowProjectDirectory=projectDirectory
  local nowDirectory=projectDirectory
  OpenedProject=true

  --pathsTabLay.setVisibility(View.VISIBLE)

  local configPath=ReBuildTool.getConfigPathByProjectDir(projectPath)
  local configFile=File(configPath)
  local config=ReBuildTool.getConfigByFilePath(configPath)
  local mainFolder=ReBuildTool.getMainProjectDirByConfig(projectPath,config)
  local openedFilePath=getSharedData("openedfilepath_"..projectDirectory.getName())
  local openedFileFile
  if openedFilePath then
    openedFileFile=File(openedFilePath)
   else
    openedFileFile=nil
  end
  local openFiles={
    file,
    openedFileFile,
    File(mainFolder.."/assets_bin/main.lua"),
    File(mainFolder.."/assets/main.lua"),
    File(mainFolder.."/AndroidManifest.xml")
  }
  for index,content in pairs(openFiles) do
    if content and content.isFile() then
      nowDirectory=content.getParentFile()
      if not(NowDirectory) then
        NowDirectory=nowDirectory
      end
      refresh(nowDirectory)
      openFile(content)
      break
    end
  end

  AppName=activity.getString(R.string.unknown)
  if configFile.isFile() then
    AppName=config.appName
  end

  --弹出提示
  --showSnackBar(formatResStr(R.string.project_open_toast,{appName}))

  --设置标题栏为工程名称
  activity.setTitle(formatResStr(R.string.project_appTitle,{AppName}))
  refreshSubTitle()
  setSharedData("openedproject",projectDirectory.getPath())
  --刷新菜单状态
  refreshMenusState()
end

--关闭工程调用函数
function closeProject()
  closeFile(nil,true)
  filesTabLay.removeAllTabs()
  table.clear(FilesTabList)
  buildKeysCache()

  filesTabLay.setVisibility(View.GONE)

  pathsTabLay.setVisibility(View.GONE)

  EditorUtil.switchEditor("LuaEditor")
  --设置默认文字
  luaEditor.text=DefaultEditorText.LuaEditor

  --删掉一些变量
  NowProjectDirectory=nil
  --NowDirectory=ProjectsFile
  --NowDirectoryFilesList={}

  OpenedProject=false
  --设置标题栏为未打开
  activity.setTitle(R.string.app_name)
  refreshSubTitle()
  setSharedData("openedproject",nil)
  --刷新菜单状态
  refreshMenusState()
end

function refreshSubTitle()
  if OpenedProject then
    if ScreenWidthDp then
      if ScreenWidthDp<360 then
        actionBar.setSubtitle(AppName)
       elseif ScreenWidthDp<380 then
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_360dp,{AppName}))
       elseif ScreenWidthDp<390 then
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_380dp,{AppName}))
       else
        actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_390dp,{AppName}))
      end
     else
      actionBar.setSubtitle(AppName)
    end
   else
    actionBar.setSubtitle(R.string.project_no_open)
  end
end



function removePackages(packages)
  for index,package in pairs(packages) do
    luaEditor.removePackage(package)
  end
end

function screenToViewX(_textField,x)
  return x-_textField.getPaddingLeft()+_textField.getScrollX()
end
function screenToViewY(_textField,y)
  return y-_textField.getPaddingTop()+_textField.getScrollY()
end

function isNearChar(bounds,x,y)
  local TOUCH_SLOP=12
  return (y >= (bounds.top - TOUCH_SLOP)
  and y < (bounds.bottom + TOUCH_SLOP*2)
  and x >= (bounds.left - TOUCH_SLOP)
  and x < (bounds.right + TOUCH_SLOP))
end

function isNearChar2(relativeCaretX,relativeCaretY,x,y)
  local TOUCH_SLOP=luaEditor.getTextSize()+10
  --print(TOUCH_SLOP)
  return (y >= (relativeCaretY - TOUCH_SLOP)
  and y < (relativeCaretY + TOUCH_SLOP+100)
  and x >= (relativeCaretX - TOUCH_SLOP-40)
  and x < (relativeCaretX + TOUCH_SLOP+40))
end

local _clipboardActionMode=nil
function onEditorSelectionChangedListener(view,status,start,end_)
  if not(_clipboardActionMode) and status then
    local actionMode=luajava.new(ActionMode.Callback,
    {
      onCreateActionMode=function(mode,menu)
        _clipboardActionMode=mode
        mode.setTitle(android.R.string.selectTextMode)

        local inflater=mode.getMenuInflater()
        inflater.inflate(R.menu.menu_editor,menu)
        --[[
        local array=activity.getTheme().obtainStyledAttributes({
          android.R.attr.actionModeSelectAllDrawable,
          android.R.attr.actionModeCutDrawable,
          android.R.attr.actionModeCopyDrawable,
          android.R.attr.actionModePasteDrawable,
        })

        menu.add(0,0,0,android.R.string.selectAll)
        .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
        .setIcon(array.getResourceId(0,0))

        menu.add(0,1,0,android.R.string.cut)
        .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
        .setIcon(array.getResourceId(1,0))

        menu.add(0,2,0,android.R.string.copy)
        .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
        .setIcon(array.getResourceId(2,0))

        menu.add(0,3,0,android.R.string.paste)
        .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
        .setIcon(array.getResourceId(3,0))

        array.recycle()]]
        return true
      end,
      onActionItemClicked=function(mode,item)
        local id=item.getItemId()
        if id==R.id.menu_selectAll then
          view.selectAll()
         elseif id==R.id.menu_cut then
          view.cut()
         elseif id==R.id.menu_copy then
          view.copy()
         elseif id==R.id.menu_paste then
          view.paste()
         elseif id==R.id.menu_code_commented then
          editorFunc.commented(view)
        end
        return false;
      end,
      onDestroyActionMode=function(mode)
        view.selectText(false)
        _clipboardActionMode=nil
      end,
    })
    activity.startSupportActionMode(actionMode)
   elseif _clipboardActionMode and not(status) then
    _clipboardActionMode.finish()
    _clipboardActionMode=nil
  end
end


function buildKeysCache()
  KeysCache={
    isResDir={},
  }
end


WindmillTools={
  手册=2,
  ["Java API"]=3,
  ["Http 调试"]=4,
}

function startWindmillActivity(toolName)
  local success=pcall(function()
    local uri = Uri.parse("wm://tool:"..WindmillTools[toolName])
    local intent = Intent(Intent.ACTION_VIEW, uri)
    activity.startActivity(intent)
  end)
  if not(success) then
    openUrl("https://www.coolapk.com/apk/com.agyer.windmill")
  end
end

local loadedSymbolBar=false
function refreshSymbolBar(state)
  if state then
    if not(loadedSymbolBar) then
      loadedSymbolBar=true
      local ps={"function()","(",")","[","]","{","}","\"","=",":",".",",",";","_","+","-","*","/","\\","%","#","^","$","?","&","|","<",">","~","'"};
      for index,content in ipairs(ps) do
        ps_bar.addView(newPsButton(content))
      end
      ps=nil
    end
    bottomAppBar.setVisibility(View.VISIBLE)
   else
    bottomAppBar.setVisibility(View.GONE)
  end
end

function checkSharedActivity(name,update)
  local sdActivityPath=AppPath.LuaExtDir.."/"..name
  local sdActivityDir=File(sdActivityPath)
  local exists=sdActivityDir.exists()
  if not(exists) or update then
    if exists then
      LuaUtil.rmDir(sdActivityDir)
    end
    LuaUtil.copyDir(File(activity.getLuaDir("sub/"..name)),sdActivityDir)
  end
  return sdActivityPath.."/main.lua"
end