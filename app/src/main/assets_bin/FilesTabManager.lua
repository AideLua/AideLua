--[[
FilesTabManager: metatable(class): 文件标签管理器，兼职管理文件的读写与保存
FilesTabManager.openState; FilesTabManager.getOpenState(): boolean: 文件打开状态
FilesTabManager.file; FilesTabManager.getFile(): java.io.File: 现在打开的文件
FilesTabManager.fileConfig; FilesTabManager.getFileConfig(): table(map): 现在打开的文件的配置
FilesTabManager.fileType; FilesTabManager.getFileType(): string: 现在打开的文件扩展名
FilesTabManager.openedFiles; FilesTabManager.getOpenedFiles(): table(map): 已打开的文件列表，以lowerPath作为键
  数据格式:{
   ["/path1.lua"]={
     file=File(),
     path="/path1.lua",
     oldContent="content1",
     newContent="content2",
     lowerPath="/path1.lua",
     edited=true,
     }
   ...
   }
FilesTabManager.openFile(file,fileType): 打开文件
  file: java.io.File: 要打开的文件
  fileType: string: 文件扩展名
FilesTabManager.saveFile(): 保存当前编辑的文件
FilesTabManager.saveAllFiles(): 保存所有文件
FilesTabManager.closeFile(lowerFilePath,removeTab,changeEditor): 关闭文件
  lowerFilePath: string: 小写的文件路径
  removeTab: boolean: 是否移除Tab，默认为true
  changeEditor: boolean: 是否未打开文件时自动改变编辑器，默认为true
FilesTabManager.init(): 初始化管理器
]]
local FilesTabManager = {}
local openState, file, fileConfig,fileType = false, nil, nil, nil
local openedFiles = {}
FilesTabManager.backupPath=AppPath.AppMediaDir..os.date("/backup/%Y%m%d")
FilesTabManager.backupDir=File(FilesTabManager.backupPath)

local function applyTabMenu(view,config)
  local popupMenu=PopupMenu(activity,view)
  popupMenu.inflate(R.menu.menu_main_filetab)
  local menu=popupMenu.getMenu()
  local dropListener=popupMenu.getDragToOpenListener()
  local dropMenuState=false--当前拉动菜单状态
  local pathTipState=false
  local Rid=R.id
  popupMenu.onDismiss=function(popupMenu)
    dropMenuState=false
  end
  popupMenu.onMenuItemClick=function(item)
    local id=item.getItemId()
    if id==Rid.menu_close then
      FilesTabManager.closeFile(config.lowerPath)
      filesTabLay.post(Runnable({
        run=function()
          if openState then
            fileConfig.tab.select()
          end
        end
      }))
     elseif id==Rid.menu_close_all then
      FilesTabManager.closeAllFiles()
     elseif id==Rid.menu_close_other then
      local file,fileType=config.file,config.fileType
      FilesTabManager.closeAllFiles(false)
      FilesTabManager.openFile(file,fileType,true)
    end
  end
  local maxY=0--最大滑动垂直距离
  view.onTouch=function(view,event)
    local action=event.getAction()
    local y=event.getY()
    local x=event.getX()
    local time=event.getEventTime()
    if maxY<y then
      maxY=y
    end
    if action==MotionEvent.ACTION_DOWN then
      pathTipState=false
     elseif action==MotionEvent.ACTION_MOVE then
      if not(dropMenuState) then
        if y>filesTabLay.getHeight() then
          dropMenuState=true
          view.requestDisallowInterceptTouchEvent(true)
          view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY,HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING)
          popupMenu.show()
          ObjectAnimator.ofFloat(config.imageView, "rotationX", {view.getRotationX(),-60,-45,0})
          .setDuration(500)
          .setInterpolator(DecelerateInterpolator())
          .start()
          ObjectAnimator.ofFloat(config.textView, "rotationX", {view.getRotationX(),-60,-45,0})
          .setDuration(500)
          .setInterpolator(DecelerateInterpolator())
          .start()
         elseif not(pathTipState) and y<0 then
          pathTipState=true
          view.requestDisallowInterceptTouchEvent(true)
          view.performLongClick(event.x,event.y)
          ObjectAnimator.ofFloat(config.imageView, "rotationX", {view.getRotationX(),60,45,0})
          .setDuration(500)
          .setInterpolator(DecelerateInterpolator())
          .start()
          ObjectAnimator.ofFloat(config.textView, "rotationX", {view.getRotationX(),60,45,0})
          .setDuration(500)
          .setInterpolator(DecelerateInterpolator())
          .start()
        end
      end
    end
    --当触摸超时或者上滑时启用下拉选择
    if dropMenuState and (((time-event.getDownTime())>600 or maxY-y>math.dp2int(8))) then
      dropListener.onTouch(view,event)
    end
    if action==MotionEvent.ACTION_UP then
      maxY=0
    end
  end
  view.onLongClick=function(view)
    pathTipState=true
  end
  view.onGenericMotion=function(view,event)
    local buttonState = event.getButtonState()
    if buttonState==MotionEvent.BUTTON_SECONDARY then
      popupMenu.show()
    end
  end
end

local function initFileTabView(tab, fileConfig)
  local view = tab.view
  fileConfig.view = view
  view.setPadding(math.dp2int(8), math.dp2int(4), math.dp2int(8), math.dp2int(4))
  view.setGravity(Gravity.LEFT | Gravity.CENTER)
  view.tag = fileConfig

  TooltipCompat.setTooltipText(view, fileConfig.shortFilePath)
  local imageView = view.getChildAt(0)
  local textView = view.getChildAt(1)
  fileConfig.imageView = imageView
  fileConfig.textView = textView
  imageView.setPadding(math.dp2int(2), math.dp2int(2), math.dp2int(2), 0)
  textView.setAllCaps(false) -- 关闭全部大写
  .setTextSize(12)
  applyTabMenu(view,fileConfig)
end
FilesTabManager.initFileTabView=initFileTabView



function FilesTabManager.openFile(newFile,newFileType,keepHistory)
  if openState and EditorsManager.isEditor() then
    --EditorsManager.save2Tab()
    FilesTabManager.saveFile(nil,false)
  end
  local filePath = newFile.getPath()
  local decoder=FileDecoders[newFileType]
  if decoder then
    openState=true
    file=newFile
    fileType=newFileType
    local lowerFilePath = string.lower(filePath) -- 小写路径
    local fileName=newFile.getName()
    fileConfig = openedFiles[lowerFilePath]
    local tab
    if fileConfig then
      tab=fileConfig.tab
     else
      tab=filesTabLay.newTab()--新建一个Tab
      tab.setText(fileName)--设置显示的文字
      if oldTabIcon then
        tab.setIcon(FilesBrowserManager.fileIcons[fileType])
      end
    end
    if not(fileConfig) or fileConfig.needRefresh==true
      fileConfig = {
        file = file,
        fileType=newFileType,
        path = filePath,
        lowerPath = lowerFilePath,
        decoder = decoder,
        tab=tab,
        shortFilePath=ProjectManager.shortPath(filePath,true),
        deleted=false;
      }
      openedFiles[lowerFilePath] = fileConfig
      tab.tag=fileConfig
      filesTabLay.addTab(tab)--在区域添加Tab
      filesTabLay.setVisibility(View.VISIBLE)--显示Tab区域
      initFileTabView(tab,fileConfig)
    end

    local failed=false
    if File(filePath).isFile() then
      _,failed=pcall(function()

        EditorsManager.switchEditorByDecoder(decoder)
        --编辑器滚动相关在 EditorsManager.openNewContent 内
        if EditorsManager.openNewContent(filePath,newFileType,decoder,keepHistory) then
          setSharedData("openedFilePath_"..ProjectManager.nowPath,filePath)
          --更新文件浏览器显示内容
          local browserAdapter=FilesBrowserManager.adapter
          if FilesBrowserManager.nowFilePosition then
            browserAdapter.notifyItemChanged(FilesBrowserManager.nowFilePosition)
          end
          local newFilePosition=FilesBrowserManager.filesPositions[filePath]
          FilesBrowserManager.nowFilePosition=newFilePosition
          if newFilePosition then
            browserAdapter.notifyItemChanged(newFilePosition)
          end
          local currentFileMenu=FilesBrowserManager.currentFileMenu
          if currentFileMenu then
            currentFileMenu.setEnabled(true)
          end
        end
        if not(tab.isSelected()) then--避免调用tab里面的重复点击事件
          task(1,function()
            tab.select()
          end)--选中Tab
        end
      end)
      refreshMenusState()
     else
      failed=R.string.file_not_find
    end

    if failed then
      fileConfig.deleted=true
      FilesTabManager.closeFile(fileConfig.lowerPath)
      showErrorDialog(nil,failed)
      return false,false
     else
      return true,false
    end

   else
    openFileITPS(filePath)
    return true,true
  end
end

function FilesTabManager.reopenFile()
  if openState then
    FilesTabManager.openFile(file,fileType,true)
  end
end

-- 保存当前打开的文件，由于当前没有编辑器监听能力，保存文件需要直接从编辑器获取
function FilesTabManager.saveFile(lowerFilePath,showToast)
  --print("警告：保存文件",lowerFilePath)
  local config
  if lowerFilePath then
    config=openedFiles[lowerFilePath]
   else
    config=fileConfig
  end
  if config then
    if config.deleted==false then
      local managerActions=EditorsManager.actions
      --保存编辑器滚动
      local editorStateConfig={
        size=managerActions.getTextSize(),
        x=managerActions.getScrollX(),
        y=managerActions.getScrollY(),
        selection=managerActions.getSelectionEnd()
      }
      if table.size(editorStateConfig)==0 then
        setSharedData("scroll_"..config.path,nil)
       else
        setSharedData("scroll_"..config.path,dump(editorStateConfig))
      end
      EditorsManager.save2Tab()--实际上不应该在这里调用

      if config.changed then
        local decoder=config.decoder
        local newContent = config.newContent
        local success,errMsg=decoder.save(config.path,newContent)
        config.oldContent = newContent -- 讲旧内容设置为新的内容
        config.changed=false
        if success then
          if showToast then
            showSnackBar(R.string.save_succeed)
          end
         else
          showErrorDialog("FilesTabManager.saveFile",errMsg)
        end
        return true -- 保存成功
       else
        if showToast then
          showSnackBar(R.string.file_noChange)
        end
      end
    end
  end
end -- return:true，保存成功 nil，未保存 false，保存失败

-- 保存所有文件
--[[
function FilesTabManager.saveAllFiles(showToast)
  for index, content in pairs(openedFiles) do
    FilesTabManager.saveFile(index, showToast)
  end
end]]

--由于当前没有多文件编辑能力，所有的文件都是实时保存的。为了减少性能消耗，保存所有文件就是保存当前文件
function FilesTabManager.saveAllFiles(showToast)
  --print("警告：保存所有文件")
  FilesTabManager.saveFile(nil, showToast)
end

-- 关闭文件，由于文件的打开都由Tab管理，所以不存在已有文件打开但是当前当前打开的文件为空的情况
function FilesTabManager.closeFile(lowerFilePath,removeTab,changeEditor)
  --print("警告：关闭文件")
  local config
  if lowerFilePath then
    config=openedFiles[lowerFilePath]
   else
    config=fileConfig
  end
  if config then
    local lowerPath=config.lowerPath
    FilesTabManager.saveFile(lowerPath)
    openedFiles[config.lowerPath]=nil
    if removeTab~=false then
      filesTabLay.removeTab(config.tab)
    end
    if table.size(openedFiles)==0 then
      openState = false
      file=nil
      fileConfig=nil

      setSharedData("openedFilePath_"..ProjectManager.nowPath,nil)
      --更新文件浏览器显示内容
      local browserAdapter=FilesBrowserManager.adapter
      if FilesBrowserManager.nowFilePosition then
        browserAdapter.notifyItemChanged(FilesBrowserManager.nowFilePosition)
      end
      local currentFileMenu=FilesBrowserManager.currentFileMenu
      if currentFileMenu then
        currentFileMenu.setEnabled(false)
      end
      filesTabLay.setVisibility(View.GONE)--隐藏Tab区域
      if changeEditor~=false then
        EditorsManager.switchEditor("NoneView")
      end
      refreshMenusState()
    end
    --else
    --print("警告：无法关闭文件")
  end
end

-- 关闭所有文件
function FilesTabManager.closeAllFiles(changeEditor)
  filesTabLay.removeAllTabs()
  for index, content in pairs(openedFiles) do
    FilesTabManager.closeFile(index,false,changeEditor)
  end
  openState=false
end

-- 初始化 FilesTabManager
function FilesTabManager.init()
  filesTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
    onTabSelected = function(tab)
      local tag = tab.tag
      local newFile = tag.file
      if (openState and newFile.getPath()~=file.getPath()) then
        FilesTabManager.openFile(newFile,tag.fileType)
      end
    end,
    onTabReselected = function(tab)
    end,
    onTabUnselected = function(tab)
    end
  }))
  --filesTabLay.onTouch = onFileTabLayTouch

  for index,content in pairs(FileDecoders) do
    local superType=content.super
    if superType then
      setmetatable(content,{__index=FileDecoders[superType]})
    end
  end

end

function FilesTabManager.changeContent(content)
  if fileConfig.newContent ~= content then
    fileConfig.newContent = content
    fileConfig.changed = true
  end
end

function FilesTabManager.changePath(lowerPath,newPath)
  local lowerNewPath=string.lower(newPath)
  local file=File(newPath)
  local fileName=file.getName()
  local fileType=getFileTypeByName(fileName)
  local decoder=FileDecoders[fileType]
  local config=openedFiles[lowerPath]
  if config then--有config，说明已经打开
    if decoder then--可以打开
      local tab=config.tab
      local newConfig = {
        file = file,
        fileType=fileType,
        path = newPath,
        lowerPath = lowerNewPath,
        decoder = decoder,
        tab=tab,
        shortFilePath=ProjectManager.shortPath(newPath,true),
        deleted=false;
      }
      openedFiles[lowerPath]=nil
      openedFiles[lowerNewPath] = newConfig
      tab.setText(fileName)--设置显示的文字
      if oldTabIcon then
        tab.setIcon(FilesBrowserManager.fileIcons[fileType])
      end
      tab.tag=newConfig
      initFileTabView(tab,newConfig)

      if lowerPath==fileConfig.lowerPath then--已打开的是此文件
        FilesTabManager.openFile(file,fileType)
      end
     else
      FilesTabManager.closeFile(lowerPath)
    end
  end
end


function FilesTabManager.getFileConfig()
  return fileConfig
end
function FilesTabManager.getOpenState()
  return openState
end
function FilesTabManager.getOpenedFiles()
  return openedFiles
end
function FilesTabManager.getFileType()
  return fileType
end
function FilesTabManager.getFile()
  return file
end

return createVirtualClass(FilesTabManager)
