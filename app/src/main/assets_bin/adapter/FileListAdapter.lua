import "getImportCode"
--local directoryFilesList=FilesBrowserManager.directoryFilesList
local filesPositions=FilesBrowserManager.filesPositions
local fileColors=FilesBrowserManager.fileColors
local unknowString=activity.getString(R.string.unknown)
local directoryFilesList,isResDir,nowFilePosition

local function onClick(view)
  local data=view.tag._data
  local file=data.file
  local path=data.filePath
  local action=data.action
  switch action do
   case "createProject" then
    newSubActivity("NewProject")
    --CreateProject()
   case "openProject" then
    --openProject(file)
    ProjectManager.openProject(path)
   case "openFolder" then
    --refresh(file,data.upFile)
   case "openFile" then
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
    pop.inflate(R.menu.menu_main_file)
    --local reNameMenu=menu.findItem(R.id.menu_rename)
    --local deleteMenu=menu.findItem(R.id.menu_delete)
    local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
    local referencesMenu=menu.findItem(Rid.menu_references)--引用资源
    local renameMenu=menu.findItem(Rid.menu_rename)--重命名

    --reNameMenu.setVisible(not(isUpFile))
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
       elseif id==R.id.menu_copy_import or id==R.id.menu_copy_classPath2 or id==R.id.menu_copy_classPath or id==R.id.menu_copy_className then
        MyToast.copyText(item.title)
      end
    end
    return true
  end
end

local function fileMoreMenuClick(view)
  local nowLibName,fileRelativePath,nowPrjDirPath
  if openProject then
    nowPrjDirPath=NowProjectDirectory.getPath()
    fileRelativePath=ProjectUtil.shortPath(NowDirectory.getPath(),true,nowPrjDirPath)
    if fileRelativePath:find("/.-/") then
      nowLibName=fileRelativePath:match("/(.-)/")
     elseif #fileRelativePath~=0 then
      nowLibName=fileRelativePath:match("/(.+)")
     else
      nowLibName="app"
    end
  end
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_main_file_upfile)
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    local Rid=R.id
    local openDirPath--点击后要打开的路径，空为不打开
    if id==Rid.menu_createFile then
      CreateFile(NowDirectory)
     elseif id==Rid.menu_createDir then
      createDirsDialog(NowDirectory)
     else
      if openProject then
        if id==Rid.menu_openDir_assets then
          openDirPath=("%s/%s/src/main/assets_bin"):format(nowPrjDirPath,nowLibName)
         elseif id==Rid.menu_openDir_java then
          openDirPath=("%s/%s/src/main/java"):format(nowPrjDirPath,nowLibName)
         elseif id==Rid.menu_openDir_lua then
          openDirPath=("%s/%s/src/main/luaLibs"):format(nowPrjDirPath,nowLibName)
         elseif id==Rid.menu_openDir_res then
          openDirPath=("%s/%s/src/main/res"):format(nowPrjDirPath,nowLibName)
         elseif id==Rid.menu_openDir_projectRoot then
          refresh(NowProjectDirectory)
        end
      end
    end
    --todo:打开路径
  end
end


return function(data,item)
  local isResDir
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      directoryFilesList=FilesBrowserManager.directoryFilesList
      if directoryFilesList then
        --[[
        if OpenedProject then
          local nowDirPath=NowDirectory.getPath()
          local cache_isResDir=KeysCache.isResDir[nowDirPath]
          if cache_isResDir then--有缓存
            isResDir=cache_isResDir
           else--无缓存
            local nowDirName=NowDirectory.getName()
            isResDir=nowDirName~="values" and not(nowDirName:find("values%-")) and ProjectUtil.shortPath(nowDirPath,true,NowProjectDirectory.getPath()):find(".-/src/.-/res/") or false
            KeysCache.isResDir[nowDirPath]=isResDir
          end
          --print(isResDir)
         else
          isResDir=false
        end]]

        return #directoryFilesList+1
       else
        return 1
      end
    end,
    getItemViewType=function(position)
      if ProjectManager.openState then
        if position==0 then
          return 3
         else
          return 4
        end
       else
        if position==0 then
          return 1
         else
          return 2
        end
      end
    end,
    onCreateViewHolder=function(parent,viewType)
      local ids={}
      local view=loadlayout2(item[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
      view.onClick=onClick
      view.onLongClick=onLongClick
      if viewType==3 then
        ids.more.onClick=fileMoreMenuClick
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data={position=position}
      local view=holder.view
      local tag=view.getTag()
      tag._data=data
      local titleView=tag.title
      local iconView=tag.icon

      local projectOpenState=ProjectManager.openState
      if position==0 then--是第一项，就是新建项目或者返回上一目录
        if projectOpenState then--项目已打开，就是返回上一级
          local file=FilesBrowserManager.directoryFile.getParentFile()
          iconView.setImageResource(R.drawable.ic_folder_outline)
          iconView.setColorFilter(fileColors.folder)
          titleView.setText("..")
          data.file=file
          data.filePath=file.getPath()
          data.fileName=".."
          data.upFile=true
          data.action="openFolder"
          view.contentDescription=activity.getString(R.string.file_up)
         else--项目没打开，就是创建项目
          iconView.setImageResource(R.drawable.ic_plus)
          tag.title.text=activity.getString(R.string.project_create)
          data.action="createProject"
        end
       else--不是第一项
        local file=directoryFilesList[position-1]
        local filePath=file.getPath()
        data.file=file
        data.filePath=filePath
        if ProjectManager.openState then
          local colorFilter
          local fileName=file.getName()
          titleView.setText(fileName)
          --tag.icon.setAlpha(getIconAlphaByFileName(fileName))
          if file.isFile() then
            filesPositions[filePath]=position
            --local fileType=getFileTypeByName(fileName)
            --iconView.setImageResource(getFileIconResIdByType(fileType))
            if fileType then
              colorFilter=fileColors[string.upper(fileType)] or fileColors.normal
             else
              colorFilter=fileColors.normal
            end
            --[[
            if OpenedFile and NowFile.getPath()==filePath then
              titleView.setTextColor(theme.color.colorAccent)
              tag.icon.setColorFilter(theme.color.colorAccent)
              tag.highLightCard.setCardBackgroundColor(theme.color.rippleColorAccent)
              nowFilePosition=position
             else
              titleView.setTextColor(theme.color.textColorPrimary)
              tag.icon.setColorFilter(colorFilter)
              tag.highLightCard.setCardBackgroundColor(0)
            end]]
            data.isResFile=isResDir
            data.fileType=fileType
            data.action="openFile"
           else
            data.isResFile=false
            titleView.setTextColor(theme.color.textColorPrimary)
            --iconView.setImageResource(getFolderIconResIdByName(fileName))
            iconView.setColorFilter(fileColors.folder)
            tag.highLightCard.setCardBackgroundColor(0)
            data.action="openFolder"
          end

          data.title=fileName
          data.fileName=fileName
         else
          local config=RePackTool.getConfigByProjectPath(filePath)
          local rePackTool=RePackTool.getRePackToolByConfig(config)
          local mainProjectPath=RePackTool.getMainProjectDirByConfigAndRePackTool(filePath,config,rePackTool)
          data.config=config
          data.rePackTool=rePackTool
          --todo: 加载项目图标

          local iconUrl=FilesBrowserManager.getProjectIconForGlide(filePath,config,mainProjectPath)
          if type(iconUrl)=="number" then
            iconView.setImageResource(iconUrl)
           else
            local options=RequestOptions()
            options.skipMemoryCache(true)--跳过内存缓存
            options.diskCacheStrategy(DiskCacheStrategy.NONE)--不缓冲disk硬盘中
            Glide.with(activity).load(iconUrl).apply(options).into(iconView)
          end

          titleView.setText(config.appName or unknowString)
          tag.message.setText(config.packageName or unknowString)
          data.title=config.appName or unknowString
          data.action="openProject"
        end
      end


    end,
  }))

end