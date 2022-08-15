--检查是不是路径相同的文件
function isSamePathFileByPath(filePath1,filePath2)--通过文件路径
  return string.lower(filePath1)==string.lower(filePath2)
end
function isSamePathFile(file1,file2)--通过文件本身
  return isSamePathFileByPath(file1.getPath(),file2.getPath())
end
function createVirtualClass(normalTable)
  local smartTable={}
  local metatable={__index=function(self,key)
      if normalTable[key] then
        return normalTable[key]
       else
        local getter="get"..key:gsub("^%l",string.upper)
        if normalTable[getter] then
          return normalTable[getter]()
        end
      end
  end}
  setmetatable(smartTable,metatable)
  return smartTable,metatable
end

function runLuaFile(file,code)
  if file and file.isFile() then
    newActivity(file.getPath())
   else
    newSubActivity("RunCode",{code})
  end
end

--自动识别显示toast的方式进行显示
function showSnackBar(text)
  if drawer.isDrawerOpen(Gravity.LEFT) then
    return MyToast(text,mainLay)
   else
    return MyToast(text,editorGroup)
  end
end

function isBinaryFile(filePath)
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

function safeCloneTable(oldTable,newTable)
  for index,content in pairs(oldTable) do
    if newTable[index]==nil then
      newTable[index]=oldTable[index]
    end
  end
end


--[[
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
  local rootPath
  if String(path).startsWith("/") then
    rootPath="/"
   else
    rootPath=ProjectsPath
  end
  for name in string.split(path,"/") do
    if name~="" then
      rootPath=rootPath.."/"..name
      table.insert(pathNames,{name,rootPath})
    end
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
        task(1,function()
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
end]]
--[[
local loadingFiles=false--正在加载文件列表
function refresh(file,upFile,force)
  --recyclerView
  if force or not(loadingFiles) then--强制加载或者没有正在加载
    if file and ProjectUtil.isSelfFile(file,NowDirectory or ProjectsFile) then
      NowDirectoryFilesList={}
    end
    file=file or NowDirectory or ProjectsFile--增强兼容性
    if file.getPath()=="/" then
      file=ProjectsFile
    end
    Handler().postDelayed(Runnable({
      run=function()
        if loadingFiles then
          swipeRefresh.setRefreshing(true)
        end
      end
    }),100)
    loadingFiles=true--正在加载列表

    if NowDirectory then
      local nowDirectoryPath=NowDirectory.getPath()--获取已打开文件夹路径
      if upFile then--如果是向上
        FilesListScroll[nowDirectoryPath]=nil--将当前已打开文件夹滚动设为0
       else
        local pos=layoutManager.findFirstVisibleItemPosition()
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
      NowFilePosition=nil
      table.clear(FilesPositions)
      _G.NowDirectory=NowDirectory
      local nowPath=NowDirectory.getPath()
      if OpenedProject then
        if nowPath==ProjectsPath then
          closeProject()
         else
          pathsTabLay.setVisibility(View.VISIBLE)
          refreshPathsTab(shortPath(nowPath,true,ProjectsPath.."/"))
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
]]

--刷新Menu状态
function refreshMenusState()
  if LoadedMenu then
    local fileOpenState,projectOpenState=FilesTabManager.openState,ProjectManager.openState
    local menus={
      {StateByFileMenus,fileOpenState},
      {StateByProjectMenus,projectOpenState},
      {StateByFileAndEditorMenus,fileOpenState and IsEdtor},
      {StateByEditorMenus,IsEdtor},
    }
    for index,content in pairs(menus)do
      for index,menu in ipairs(content[1]) do
        menu.setEnabled(toboolean(content[2]))
      end
    end

    PluginsUtil.callElevents("refreshMenusState")
  end
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
--[==[
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
          local editorType=EditorUtil.TextFileType2EditorType[fileType]
          if isSelfFile and editorType~="CodeEditor" then--重复打开文件
            if code~=NowEditor.text then
              NowEditor.setText(code,true)--打开文件并且保留历史记录
            end
           else--新的打开
            EditorUtil.switchEditor(editorType,EditorUtil.TextFileType2EditorLanguage[fileType])--将编辑器切换为Lua编辑器
            NowEditor.setText(code)
            --listenFile(filePath)
          end
          if NowEditorType=="LuaEditor" then
            NowEditor.setSelection(line or activity.getSharedData("Selection"..file.getPath()) or 0)
          end
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
      --[[
      if not(loadingFiles) then
        adp.notifyDataSetChanged()
      end]]
      if oldEditorPreviewButton then
        if ProjectUtil.SupportPreviewType[fileType] then
          previewChipCardView.setVisibility(View.VISIBLE)
         else
          previewChipCardView.setVisibility(View.GONE)
        end
      end

      if not(loadingFiles) and not(reOpen) then
        if NowFilePosition then
          adp.notifyItemChanged(NowFilePosition)
        end
        local newFilePosition=FilesPositions[filePath]
        NowFilePosition=newFilePosition
        if newFilePosition then
          adp.notifyItemChanged(newFilePosition)
        end
      end
      --setActiveFileItem(FilesDataList[filePath],true)--设置文件列表高亮

      local shortFilePath=shortPath(file.getPath(),true,NowProjectDirectory.getParent().."/")

      refreshMenusState()
      setSharedData("openedfilepath_"..NowProjectDirectory.getPath(),file.getPath())--保存已打开文件路径

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

]==]


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
  local TOUCH_SLOP=editor.getTextSize()+10
  --print(TOUCH_SLOP)
  return (y >= (relativeCaretY - TOUCH_SLOP)
  and y < (relativeCaretY + TOUCH_SLOP+100)
  and x >= (relativeCaretX - TOUCH_SLOP-40)
  and x < (relativeCaretX + TOUCH_SLOP+40))
end

local _clipboardActionMode=nil
function onEditorSelectionChangedListener(view,status,start,end_)
  if not(_clipboardActionMode) and status and not(Searching) then
    local actionMode=luajava.new(ActionMode.Callback,
    {
      onCreateActionMode=function(mode,menu)
        _clipboardActionMode=mode
        mode.setTitle(android.R.string.selectTextMode)

        local inflater=mode.getMenuInflater()
        inflater.inflate(R.menu.menu_editor,menu)
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
          EditorsManager.actions.commented(view)
         elseif id==R.id.menu_code_viewApi then
          local selectedText=view.getSelectedText()
          newSubActivity("JavaApi",{selectedText})
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




--公共Activity
local sharedActivityPath=AppPath.Sdcard.."/Android/media/%s/.aidelua/activities/%s"

function updateSharedActivity(name,sdActivityDir)
  LuaUtil.copyDir(File(activity.getLuaDir("sub/"..name)),sdActivityDir)
end

function checkSharedActivity(name,packageName)
  local sdActivityPath=sharedActivityPath:format(packageName,name)--AppPath.AppShareCacheDir.."/activities/"..name
  local sdActivityMainPath=sdActivityPath.."/main.lua"
  local sdActivityDir=File(sdActivityPath)
  local sdActivityMainFile=File(sdActivityMainPath)
  local exists=sdActivityDir.exists()
  local mainExists=sdActivityMainFile.isFile()
  if not(mainExists) or getSharedData("sharedactivity_"..name)~=lastUpdateTime then
    if exists then
      LuaUtil.rmDir(sdActivityDir)
    end
    updateSharedActivity(name,sdActivityDir)
  end
  return sdActivityMainPath
end




