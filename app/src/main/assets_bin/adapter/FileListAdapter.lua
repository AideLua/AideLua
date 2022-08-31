import "getImportCode"
--local directoryFilesList=FilesBrowserManager.directoryFilesList
local filesPositions=FilesBrowserManager.filesPositions
local adapterData=FilesBrowserManager.adapterData
local fileColors=FilesBrowserManager.fileColors
local fileIcons=FilesBrowserManager.fileIcons
local folderIcons=FilesBrowserManager.folderIcons
local unknowString=activity.getString(R.string.unknown)

local refresh=FilesBrowserManager.refresh
local getIconAlphaByName=FilesBrowserManager.getIconAlphaByName

local directoryFilesList,isResDir

local function onClick(view)
  local data=view.tag._data
  local file=data.file
  local path=data.filePath
  local action=data.action
  switch action do
   case "createProject" then
    newSubActivity("NewProject")
   case "openProject" then
    ProjectManager.openProject(path)
   case "openFolder" then
    refresh(file,data.upFile)
   case "openFile" then
    --openFileITPS(path)
    local success,inThirdPartySoftware=FilesTabManager.openFile(file,data.fileType,false)
    if success and not(inThirdPartySoftware) then
      if screenConfigDecoder.deviceByWidth ~= "pc" then
        FilesBrowserManager.close()
      end
    end
    --local succeed,_,inThirdPartySoftware=openFile(file)
    --todo: 手机端打开成功自动关闭侧滑
  end
end

local function onLongClick(view)
  local data=view.tag._data

  if data.position~=0 then
    local file=data.file
    local filePath=data.filePath
    local title=data.title--显示的名称
    local fileName=data.fileName
    local Rid=R.id

    local parentFile,parentName
    local action=data.action
    local isFile,fileType,fileRelativePath

    if ProjectManager.openState then
      isFile=file.isFile()
      fileType=data.fileType
      fileRelativePath=ProjectManager.shortPath(filePath,true)
    end

    local pop=PopupMenu(activity,view)
    local menu=pop.Menu
    --[[
    if OpenedProject and fileType and LibsRelativePathType[fileType] then--已经打开了项目并且文件类型受支持

      local inLibDir,inLibDirIndex=data.inLibDir,data.inLibDirIndex
      if not(inLibDir) then
        for index,content in ipairs(LibsRelativePathMatch) do
          inLibDir=fileRelativePath:match(content)
          inLibDirIndex=index
          if inLibDir then
            data.inLibDir,data.inLibDirIndex=inLibDir,inLibDirIndex
            break
          end
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
        copyImportMenu.title=getImportCode(callFilePath)
        copyNameMenu.setVisible(fileType~="so")
        copyClassPathMenu.setVisible(callFilePath~=noTypeFileName)
        copyClassPath2Menu.setVisible(fileType=="java")--smali仅在java目录下支持
        if fileType~="so" then
          copyNameMenu.title=noTypeFileName
        end
        if callFilePath~=noTypeFileName then--有重复的时候
          copyClassPathMenu.title=callFilePath
        end
        if fileType=="java" then
          copyClassPath2Menu.title="L"..inLibDir..";"
        end
      end
    end
  ]]
    pop.inflate(R.menu.menu_main_file)
    --local reNameMenu=menu.findItem(R.id.menu_rename)
    local copyMenu=menu.findItem(R.id.subMenu_copy)
    local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
    local referencesMenu=menu.findItem(Rid.menu_references)--引用资源
    local renameMenu=menu.findItem(Rid.menu_rename)--重命名
    local copyMenuMenuBuilder = copyMenu.getSubMenu()

    --reNameMenu.setVisible(not(isUpFile))
    copyMenu.setVisible(ProjectManager.openState)
    openInNewWindowMenu.setVisible(isFile or data.action=="openProject")
    referencesMenu.setVisible(toboolean(data.isResFile))
    renameMenu.setVisible(ProjectManager.openState)

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
        --[[
        if OpenedProject then--已打开项目
          activity.newActivity("main",{NowProjectDirectory,file.getPath()},true)
         else--未打开项目
          activity.newActivity("main",{file.getPath()},true)
        end]]
       elseif id==Rid.menu_references then--引用资源
        NowEditor.paste(("R.%s.%s"):format(parentName:match("(.-)%-")or parentName,fileName:match("(.+)%.")or fileName))
        drawer.closeDrawer(Gravity.LEFT)
        --[[
       elseif id==R.id.menu_copy_import or id==R.id.menu_copy_classPath2 or id==R.id.menu_copy_classPath or id==R.id.menu_copy_className then
        MyToast.copyText(item.title)]]
      end
    end
    return true
  end
end

local function fileMoreMenuClick(view)
  local directoryFile=FilesBrowserManager.directoryFile
  local nowProjectPath=ProjectManager.nowPath
  local nowLibName,fileRelativePath
  if ProjectManager.openState then
    fileRelativePath=ProjectManager.shortPath(directoryFile.getPath(),true,nowProjectPath)
    if fileRelativePath:find("/") then
      nowLibName=fileRelativePath:match("^(.-)/")
     elseif #fileRelativePath~=0 then
      nowLibName=fileRelativePath
     else
      nowLibName="app"
    end
  end
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_main_file_upfile)
  local currentFileMenu=menu.findItem(R.id.menu_openDir_currentFile)
  currentFileMenu.setEnabled(FilesTabManager.openState)
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    local Rid=R.id
    local openDirPath--点击后要打开的路径，空为不打开
    if id==Rid.menu_createFile then
      createFile(directoryFile)
     elseif id==Rid.menu_createDir then
      createDirsDialog(directoryFile)
     else
      if id==Rid.menu_openDir_currentFile then
        FilesBrowserManager.refresh(FilesTabManager.file.getParentFile())
       elseif id==Rid.menu_openDir_assets then
        openDirPath=("%s/%s/src/main/assets_bin"):format(nowProjectPath,nowLibName)
       elseif id==Rid.menu_openDir_java then
        openDirPath=("%s/%s/src/main/java"):format(nowProjectPath,nowLibName)
       elseif id==Rid.menu_openDir_lua then
        openDirPath=("%s/%s/src/main/luaLibs"):format(nowProjectPath,nowLibName)
       elseif id==Rid.menu_openDir_res then
        openDirPath=("%s/%s/src/main/res"):format(nowProjectPath,nowLibName)
       elseif id==Rid.menu_openDir_projectRoot then
        openDirPath=nowProjectPath
      end
    end
    if openDirPath then
      FilesBrowserManager.refresh(File(openDirPath))
    end
  end
end

local openState2ViewType={
  ["true"]={
    [0]=3,
    _else=4
  },
  ["false"]={
    [0]=1,
    _else=2
  }
}
return function(item)
  --local isResDir
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      directoryFilesList=FilesBrowserManager.directoryFilesList
      if directoryFilesList then
        return #directoryFilesList+1
       else
        return 0
      end
    end,
    getItemViewType=function(position)
      local son1=openState2ViewType[tostring(ProjectManager.openState)]
      return son1[position] or son1._else
    end,
    onCreateViewHolder=function(parent,viewType)
      local ids={}
      local view=loadlayout2(item[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
      view.onClick=onClick
      view.onLongClick=onLongClick
      view.onContextClick=onLongClick
      if viewType==3 then
        ids.more.onClick=fileMoreMenuClick
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local view=holder.view
      local tag=view.getTag()
      local data=adapterData[position]
      local initData=false
      if not(data) then
        data={position=position}
        adapterData[position]=data
        initData=true
      end
      tag._data=data
      local titleView=tag.title
      local iconView=tag.icon

      local file,filePath

      local projectOpenState=ProjectManager.openState
      if position==0 then--是第一项，就是新建项目或者返回上一目录
        if projectOpenState then--项目已打开，就是返回上一级
          if initData then
            file=FilesBrowserManager.directoryFile.getParentFile()
            if not(file) then--根目录的上一级是工程文件夹
              file=ProjectManager.projectsFile
            end
            filePath=file.getPath()

            data.file=file
            data.filePath=file.getPath()
            data.fileName=".."
            data.upFile=true
            data.action="openFolder"
          end
          iconView.setImageResource(R.drawable.ic_folder_outline)
          iconView.setColorFilter(fileColors.folder)
          titleView.setText("..")
          view.contentDescription=activity.getString(R.string.file_up)
         else--项目没打开，就是创建项目
          iconView.setImageResource(R.drawable.ic_plus)
          tag.title.text=activity.getString(R.string.project_create)
          data.action="createProject"
        end
       else--不是第一项
        if initData then
          file=directoryFilesList[position-1]
          filePath=file.getPath()
          data.file=file
          data.filePath=filePath
         else
          file=data.file
          filePath=data.filePath
        end
        if projectOpenState then
          local colorFilter
          local fileName=file.getName()
          titleView.setText(fileName)
          if initData then
            data.title=fileName
            data.fileName=fileName
          end
          tag.icon.setAlpha(getIconAlphaByName(fileName))

          if file.isFile() then
            filesPositions[filePath]=position
            local fileType=getFileTypeByName(fileName)
            iconView.setImageResource(fileIcons[fileType])
            if fileType then
              colorFilter=fileColors[string.upper(fileType)]
             else
              colorFilter=fileColors.normal
            end

            if FilesTabManager.openState and FilesTabManager.file.getPath()==filePath then
              titleView.setTextColor(theme.color.colorAccent)
              tag.icon.setColorFilter(theme.color.colorAccent)
              tag.highLightCard.setCardBackgroundColor(theme.color.rippleColorAccent)
              FilesBrowserManager.nowFilePosition=position
             else
              titleView.setTextColor(theme.color.textColorPrimary)
              tag.icon.setColorFilter(colorFilter)
              tag.highLightCard.setCardBackgroundColor(0)
            end
            data.isResFile=isResDir
            data.fileType=fileType
            data.action="openFile"
           else
            data.isResFile=false
            titleView.setTextColor(theme.color.textColorPrimary)
            iconView.setImageResource(folderIcons[fileName])
            iconView.setColorFilter(fileColors.folder)
            tag.highLightCard.setCardBackgroundColor(0)
            data.action="openFolder"
          end
         else
          local config,iconUrl
          if initData then
            config=RePackTool.getConfigByProjectPath(filePath)
            local rePackTool=RePackTool.getRePackToolByConfig(config)
            local mainProjectPath=RePackTool.getMainProjectDirByConfigAndRePackTool(filePath,config,rePackTool)
            iconUrl=FilesBrowserManager.getProjectIconForGlide(filePath,config,mainProjectPath)
            data.title=config.appName or unknowString
            data.action="openProject"
            data.iconUrl=iconUrl
            data.config=config
            data.rePackTool=rePackTool
           else
            iconUrl=data.iconUrl
            config=data.config
          end

          titleView.setText(config.appName or unknowString)
          tag.message.setText(config.packageName or unknowString)


          if type(iconUrl)=="number" then
            iconView.setImageResource(iconUrl)
           else
            local options=RequestOptions()
            options.skipMemoryCache(true)--跳过内存缓存
            options.diskCacheStrategy(DiskCacheStrategy.NONE)--不缓冲disk硬盘中
            Glide.with(activity).load(iconUrl).apply(options).into(iconView)
          end

        end
      end


    end,
  }))

end