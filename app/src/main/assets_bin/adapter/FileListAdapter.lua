import "getImportCode"
--local directoryFilesList=FilesBrowserManager.directoryFilesList
local filesPositions=FilesBrowserManager.filesPositions
local adapterData=FilesBrowserManager.adapterData
local fileColors=FilesBrowserManager.fileColors
local fileIcons=FilesBrowserManager.fileIcons
local folderIcons=FilesBrowserManager.folderIcons
local relLibPathsMatch=FilesBrowserManager.relLibPathsMatch

local unknowString=activity.getString(R.string.unknown)

local refresh=FilesBrowserManager.refresh
local getIconAlphaByName=FilesBrowserManager.getIconAlphaByName

local directoryFilesList

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
    local success,inThirdPartySoftware=FilesTabManager.openFile(file,data.fileType,false)
    if success and not(inThirdPartySoftware) then
      if screenConfigDecoder.deviceByWidth ~= "pc" then
        FilesBrowserManager.close()
      end
    end
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

    local parentFile=file.getParentFile()
    local parentName=parentFile.getName()
    local action=data.action
    local isFile,fileType,fileRelativePath,isResDir

    local inLibDirPath=data.inLibDirPath

    local openState=ProjectManager.openState--工程打开状态=

    if openState then
      isFile=file.isFile()
      fileType=data.fileType
      fileRelativePath=ProjectManager.shortPath(filePath,true)
      isResDir=parentName~="values" and not(parentName:find("values%-")) and ProjectManager.shortPath(filePath,true):find(".-/src/.-/res/.-/") or false
     else
      isResDir=false
    end

    local pop=PopupMenu(activity,view)
    local menu=pop.Menu

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
      --[[
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
      end]]
    end

    pop.inflate(R.menu.menu_main_file)
    local copyMenu=menu.findItem(R.id.subMenu_copy)
    local openInNewWindowMenu=menu.findItem(Rid.menu_openInNewWindow)--新窗口打开
    local referencesMenu=menu.findItem(Rid.menu_references)--引用资源
    local renameMenu=menu.findItem(Rid.menu_rename)--重命名
    local copyMenuBuilder = copyMenu.getSubMenu()

    copyMenu.setVisible(ProjectManager.openState)
    openInNewWindowMenu.setVisible(isFile or data.action=="openProject")
    referencesMenu.setVisible(toboolean(isResDir))
    renameMenu.setVisible(ProjectManager.openState)
    if openState then
      CopyMenuUtil.addSubMenus(copyMenuBuilder,getFilePathCopyMenus(inLibDirPath,filePath,fileName,isFile,fileType))
    end
    pop.show()
    pop.onMenuItemClick=function(item)
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
       elseif id==Rid.menu_references then--引用资源
        local javaR=("R.%s.%s"):format(parentName:match("(.-)%-")or parentName,fileName:match("(.+)%.")or fileName)
        EditorsManager.actions.paste(javaR)
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
        openDirPath=FilesTabManager.file.getParent()
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
      --print(directoryFilesList)
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
          local highLightCard=tag.highLightCard
          local fileName=file.getName()
          titleView.setText(fileName)
          if initData then
            data.title=fileName
            data.fileName=fileName
          end
          iconView.setAlpha(getIconAlphaByName(fileName))

          if file.isFile() then
            local colorFilter
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
              iconView.setColorFilter(theme.color.colorAccent)
              highLightCard.setCardBackgroundColor(theme.color.rippleColorAccent)
              FilesBrowserManager.nowFilePosition=position
             else
              titleView.setTextColor(theme.color.textColorPrimary)
              iconView.setColorFilter(colorFilter)
              highLightCard.setCardBackgroundColor(0)
            end
            data.fileType=fileType
            data.action="openFile"
           else
            titleView.setTextColor(theme.color.textColorPrimary)
            iconView.setImageResource(folderIcons[fileName])
            iconView.setColorFilter(fileColors.folder)
            highLightCard.setCardBackgroundColor(0)
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
          --print(dump(data))
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