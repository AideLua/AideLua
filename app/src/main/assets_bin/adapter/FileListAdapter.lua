import "getImportCode"
--local directoryFilesList=FilesBrowserManager.directoryFilesList
local filesPositions=FilesBrowserManager.filesPositions
local adapterData=FilesBrowserManager.adapterData
local fileColors=FilesBrowserManager.fileColors
local fileIcons=FilesBrowserManager.fileIcons
local folderIcons=FilesBrowserManager.folderIcons
local relLibPathsMatch=FilesBrowserManager.relLibPathsMatch

local unknowString=getString(R.string.unknown)

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

local function fileMoreMenuClick(view)
  local tag=view.tag
  local popupMenu=tag.popupMenu
  popupMenu.show()
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
      local ids={_type="filebrowser"}
      local view=loadlayout2(item[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
      view.onClick=onClick

      if viewType==3 then
        local moreView=ids.more
        local iconView=ids.icon
        local moreTag={}
        moreView.tag=moreTag
        moreView.onClick=fileMoreMenuClick
        iconView.setImageResource(R.drawable.ic_folder_outline)
        iconView.setColorFilter(fileColors.folder)
        ids.title.setText("..")
        view.contentDescription=activity.getString(R.string.file_up)
        local popupMenu=PopupMenu(activity,moreView)
        moreTag.popupMenu=popupMenu
        moreTag.needInitMenu=true
        moreView.setOnTouchListener(popupMenu.getDragToOpenListener())
        popupMenu.inflate(R.menu.menu_main_file_upfile)
        local menu=popupMenu.getMenu()
        ids.currentFileMenu=menu.findItem(R.id.menu_openDir_currentFile)
        popupMenu.onMenuItemClick=function(item)
          local id=item.getItemId()
          local Rid=R.id
          local openDirPath--点击后要打开的路径，空为不打开
          local directoryFile=FilesBrowserManager.directoryFile
          if id==Rid.menu_createFile then
            createFile(directoryFile)
           elseif id==Rid.menu_createDir then
            createDirsDialog(directoryFile)
           else
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
          tag.currentFileMenu.setEnabled(FilesTabManager.openState)
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
          --local popupMenu=PopupMenu(activity,view)
          --data.popupMenu=popupMenu
          --data.needInitMenu=true
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
              view.setSelected(true)
              FilesBrowserManager.nowFilePosition=position
             else
              titleView.setTextColor(theme.color.textColorPrimary)
              iconView.setColorFilter(colorFilter)
              highLightCard.setCardBackgroundColor(0)
              view.setSelected(false)
            end
            data.fileType=fileType
            data.action="openFile"
           else
            titleView.setTextColor(theme.color.textColorPrimary)
            iconView.setImageResource(folderIcons[fileName])
            iconView.setColorFilter(fileColors.folder)
            highLightCard.setCardBackgroundColor(0)
            view.setSelected(false)
            data.action="openFolder"
          end

         else
          local loadedConfig,config,iconUrl,title,summary
          if initData then
            loadedConfig,config=pcall(RePackTool.getConfigByProjectPath,filePath)
            local loadedRePackTool,rePackTool
            if loadedConfig then
              loadedRePackTool,rePackTool=pcall(RePackTool.getRePackToolByConfig,config)
              local mainProjectPath
              if loadedRePackTool then
                mainProjectPath=RePackTool.getMainProjectDirByConfigAndRePackTool(filePath,config,rePackTool)
                title=(config.appName or unknowString)
               else
                rePackTool=nil
                mainProjectPath=filePath.."/app/src/main"
                title=(config.appName or unknowString).." (Unable to get RePackTool)"
              end
              summary=config.packageName or unknowString
              iconUrl=FilesBrowserManager.getProjectIconForGlide(filePath,config,mainProjectPath)
             else
              title="(Unable to load config.lua)"
              summary=config
              config={}
              iconUrl=android.R.drawable.sym_def_app_icon
            end
            data.title=title
            data.action="openProject"
            data.iconUrl=iconUrl
            data.config=config
            data.rePackTool=rePackTool
            data.summary=summary
           else
            iconUrl=data.iconUrl
            config=data.config
            title=data.title
            summary=data.summary
          end
          titleView.setText(title)
          tag.message.setText(summary)

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