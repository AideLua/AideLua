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

local function onLongClick(view)
  --准备拖放
  recyclerView.tag.longClickedView=view
  local data=view.tag._data
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
      local ids={}
      local view=loadlayout2(item[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
      view.onClick=onClick
      view.onLongClick=onLongClick

      if viewType==3 then
        local moreView=ids.more
        moreView.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
        moreView.onClick=fileMoreMenuClick
        local popupMenu=FilesBrowserManager.loadMoreMenu(moreView)
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local view=holder.view
      local tag=view.getTag()
      local data=adapterData[position]
      local initData=false
      if not(data) then--没有data 说明需要初始化
        data={position=position}
        adapterData[position]=data
        initData=true
      end
      tag._data=data
      local titleView=tag.title
      local iconView=tag.icon
      local messageView=tag.message

      local file,filePath

      local projectOpenState=ProjectManager.openState
      if position==0 then--是第一项，就是新建项目或者返回上一目录
        if projectOpenState then--项目已打开，就是返回上一级
          if initData then
            file=FilesBrowserManager.directoryFile.getParentFile()
            if not(file) then--根目录的上一级是工程文件夹
              file=ProjectManager.projectsFile
            end
            data.file=file
            data.upFile=true
            data.action="openFolder"
          end
         else--项目没打开，就是创建项目选项
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
          local fileName

          titleView.setText(fileName)
          if initData then
            fileName=file.getName()
            data.title=fileName
            data.fileName=fileName
           else
            fileName=data.fileName
          end
          titleView.setText(fileName)
          iconView.setAlpha(getIconAlphaByName(fileName))

          if file.isFile() then--当前是文件
            local colorFilter
            local fileType
            local icon
            if initData then
              filesPositions[filePath]=position
              fileType=getFileTypeByName(fileName)
              icon=fileIcons[fileType]
              data.fileType=fileType
              data.icon=icon
             else
              fileType=data.fileType
              icon=data.icon
            end
            iconView.setImageResource(icon)

            colorFilter=fileColors[fileType and string.upper(fileType) or "normal"]

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
           else--当前是文件夹
            titleView.setTextColor(theme.color.textColorPrimary)
            iconView.setImageResource(folderIcons[fileName])
            iconView.setColorFilter(fileColors.folder)
            highLightCard.setCardBackgroundColor(0)
            view.setSelected(false)
            data.action="openFolder"
          end

         else--未打开工程

          local loadedConfig,config,iconUrl,title,summary
          if initData then
            loadedConfig,config=pcall(RePackTool.getConfigByProjectPath,filePath)
            local loadedRePackTool,rePackTool
            if loadedConfig then--文件没有损坏
              loadedRePackTool,rePackTool=pcall(RePackTool.getRePackToolByConfig,config)
              local mainProjectPath
              if loadedRePackTool then--可以加载二次打包工具
                mainProjectPath=RePackTool.getMainProjectDirByConfigAndRePackTool(filePath,config,rePackTool)
                title=(config.appName or unknowString)
               else--无法加载二次打包工具
                rePackTool=nil
                mainProjectPath=filePath.."/app/src/main"
                title=(config.appName or unknowString).." (Unable to get RePackTool)"
              end
              summary=config.packageName or unknowString
              --iconUrl=FilesBrowserManager.getProjectIconForGlide(filePath,config,mainProjectPath)
              iconUrl=ProjectManager.getProjectIconPath(config,filePath,mainProjectPath) or android.R.drawable.sym_def_app_icon
             else--文件已损坏
              title="(Unable to load config.lua)"
              summary=config
              config={}
              iconUrl=android.R.drawable.sym_def_app_icon
            end
            data.fileName=file.getName()
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
          messageView.setText(summary)

          --设置应用图标
          if type(iconUrl)=="number" then
            iconView.setImageResource(iconUrl)
           else
            local options=RequestOptions()
            options.skipMemoryCache(true)--跳过内存缓存
            options.diskCacheStrategy(DiskCacheStrategy.NONE)--不缓冲disk硬盘中
            options.error(android.R.drawable.sym_def_app_icon)
            Glide.with(activity)
            .load(iconUrl)
            .apply(options)
            .into(iconView)
          end

        end
      end


    end,
  }))

end