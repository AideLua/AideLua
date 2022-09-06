--[[
FilesTabManager:文件标签管理器，顺便管理文件的读写与保存
FilesTabManager.openState; FilesTabManager.getOpenState(): 文件打开状态
FilesTabManager.fileConfig; FilesTabManager.getFileConfig(): 现在打开的文件的配置
FilesTabManager.fileType; FilesTabManager.getFileType(): 现在打开的文件类型
FilesTabManager.openedFiles; FilesTabManager.getOpenedFiles(): 已打开的文件列表，以lowerPath作为键
  ┗ 数据格式:{
   ["/path1.lua"]={
     file=File(),
     path="/path1.lua",
     oldContent="content1",
     newContent="content2",
     lowerPath="/path1.lua",
     edited=true,
     }
   }
FilesTabManager.openFile(file,keepHistory): 打开文件
  ┣ file: 要打开的文件
  ┗ keepHistory:不删除新编辑器的历史记录
FilesTabManager.saveFile(): 保存当前编辑的文件
FilesTabManager.saveAllFiles(): 保存所有文件
]]
local FilesTabManager = {}
local openState, file, fileConfig,fileType = false, nil, nil, nil
local openedFiles = {}
FilesTabManager.backupPath=AppPath.AppShareDir..os.date("/backup/%Y%m%d")
FilesTabManager.backupDir=File(FilesTabManager.backupPath)

local nowTabTouchTag
local function onFileTabLongClick(view)
  local tag = view.tag
  nowTabTouchTag = tag
  tag.onLongTouch = true
end

local moveCloseHeight
local function refreshMoveCloseHeight(height)
  height = height - 56
  if height <= 320 then
    moveCloseHeight = math.dp2int(height / 2)
   else
    moveCloseHeight = math.dp2int(160)
  end
end
FilesTabManager.refreshMoveCloseHeight = refreshMoveCloseHeight


local function onFileTabTouch(view, event)
  local tag = view.tag
  local action = event.getAction()
  if action == MotionEvent.ACTION_DOWN then
    tag.downY = event.getRawY()
   else
    if not (tag.onLongTouch) then
      return
    end
    local downY = tag.downY
    local moveY = event.getRawY() - downY
    if action == MotionEvent.ACTION_MOVE then
      -- print("test",tointeger(moveY),tointeger(event.getY()))
      if moveY > 0 and moveY < moveCloseHeight then
        view.setRotationX(moveY / moveCloseHeight * -90)
       elseif moveY >= moveCloseHeight then
        view.setRotationX(-90)
      end
     elseif action == MotionEvent.ACTION_UP then
      nowTabTouchTag = nil
      tag.onLongTouch = false
      if moveY > moveCloseHeight then
        --closeFileAndTab(tag.tab)
        print("提示：tab未关闭，文件未保存")
        print(tag.lowerFilePath)
        FilesTabManager.closeFile(tag.lowerPath, true)
        view.setRotationX(0)
        Handler().postDelayed(Runnable({
          run = function()
            if openState then
              fileConfig.tab.select()
            end
        end}),1)

        --[[
        if OpenedFile then
          local tabConfig = FilesTabList[string.lower(NowFile.getPath())]
          if tabConfig then
            local tab = tabConfig.tab
            task(1, function()
              tab.select()
            end)
          end
        end]]
       else
        ObjectAnimator.ofFloat(view, "rotationX", {0}).setDuration(200)
        .setInterpolator(DecelerateInterpolator()).start()
      end
    end
  end
end

local function onFileTabLayTouch(view, event)
  local tag = nowTabTouchTag
  if tag == nil or not (tag.onLongTouch) then
    return
  end
  onFileTabTouch(tag.view, event)
  return true
end

local function initFileTabView(tab, fileConfig)
  local view = tab.view
  fileConfig.view = view
  view.setPadding(math.dp2int(8), math.dp2int(4), math.dp2int(8), math.dp2int(4))
  view.setGravity(Gravity.LEFT | Gravity.CENTER)
  view.tag = fileConfig
  view.onLongClick=onFileTabLongClick
  view.onTouch = onFileTabTouch
  TooltipCompat.setTooltipText(view, fileConfig.shortFilePath)
  local imageView = view.getChildAt(0)
  local textView = view.getChildAt(1)
  fileConfig.imageView = imageView
  fileConfig.textView = textView
  imageView.setPadding(math.dp2int(2), math.dp2int(2), math.dp2int(2), 0)
  textView.setAllCaps(false) -- 关闭全部大写
  .setTextSize(12)
end
--FilesTabManager.initFileTabView=initFileTabView



function FilesTabManager.openFile(newFile,newFileType, keepHistory)
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
      tab.setIcon(FilesBrowserManager.fileIcons[fileType])
      fileConfig = {
        file = file,
        fileType=newFileType,
        path = filePath,
        lowerPath = lowerFilePath,
        decoder = decoder,
        tab=tab,
        shortFilePath=ProjectManager.shortPath(filePath,true)
      }
      openedFiles[lowerFilePath] = fileConfig
      tab.tag=fileConfig
      filesTabLay.addTab(tab)--在区域添加Tab
      filesTabLay.setVisibility(View.VISIBLE)--显示Tab区域
      initFileTabView(tab,fileConfig)

    end
    if not(tab.isSelected()) then--避免调用tab里面的重复点击事件
      task(1,function()
        tab.select()
      end)--选中Tab
    end

    EditorsManager.switchEditorByDecoder(decoder)
    EditorsManager.openNewContent(filePath,newFileType,decoder)

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

    refreshMenusState()
    return true,false
   else
    openFileITPS(filePath)
    return true,true
  end
end

-- 保存当前打开的文件，由于当前没有编辑器监听能力，保存文件需要直接从编辑器获取
function FilesTabManager.saveFile(lowerFilePath,showToast)
  print("警告：保存文件")
  if openState and ProjectManager.openState then
    local config
    if lowerFilePath then
      config=openedFiles[lowerFilePath]
     else
      config=fileConfig
    end
    local managerActions=EditorsManager.actions
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
    EditorsManager.save2Tab()

    if config.changed then
      local decoder=config.decoder
      local newContent = config.newContent

      decoder.save(config.path,newContent)
      --io.open(config.path, "w"):write(newContent):close()
      config.oldContent = newContent -- 讲旧内容设置为新的内容
      config.changed=false
      if showToast then
        showSnackBar(R.string.save_succeed)
      end
      return true -- 保存成功
     else
      if showToast then
        showSnackBar("Content not changed")
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
  print("警告：保存所有文件")
  FilesTabManager.saveFile(nil, showToast)
end

-- 关闭文件，由于文件的打开都由Tab管理，所以不存在已有文件打开但是当前当前打开的文件为空的情况
function FilesTabManager.closeFile(lowerFilePath, saveFile)
  print("警告：关闭文件")
  local config
  if lowerFilePath then
    config=openedFiles[lowerFilePath]
   else
    config=fileConfig
  end
  if config then
    local lowerFilePath=config.lowerFilePath
    if saveFile~=false then
      FilesTabManager.saveFile(lowerFilePath)
    end

    openedFiles[config.lowerPath]=nil
    filesTabLay.removeTab(config.tab)
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
      filesTabLay.setVisibility(View.GONE)--隐藏Tab区域
      EditorsManager.switchEditor("NoneView")
      refreshMenusState()
    end
   else
    print("警告：无法关闭文件")
  end
end

-- 保存所有文件
function FilesTabManager.closeAllFiles(saveFiles)
  for index, content in pairs(openedFiles) do
    FilesTabManager.closeFile(index, saveFiles)
  end
end


-- 初始化 FilesTabManager
function FilesTabManager.init()
  filesTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
    onTabSelected = function(tab)
      local tag = tab.tag
      local newFile = tag.file
      if (not(openState) or newFile.getPath()~=file.getPath()) then
        FilesTabManager.openFile(newFile,tag.fileType)
      end
    end,
    onTabReselected = function(tab)
    end,
    onTabUnselected = function(tab)
    end
  }))
  filesTabLay.onTouch = onFileTabLayTouch

  for index,content in pairs(FileDecoders) do
    local superType=content.super
    if superType then
      setmetatable(content,{__index=FileDecoders[superType]})
    end
  end

end

function FilesTabManager.changeContent(content)
  fileConfig.newContent = content
  fileConfig.changed=true
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
