--[[
ProjectManager: metatable(class): 项目管理器
ProjectManager.projectsPath; ProjectManager.getProjectsPath(): 所有项目的保存路径
ProjectManager.projectsFile; ProjectManager.getProjectsFile(): 所有项目保存的文件夹
ProjectManager.nowPath; ProjectManager.getNowPath(): 当前项目的路径
ProjectManager.nowFile; ProjectManager.getNowFile(): 当前项目文件夹
ProjectManager.openState; ProjectManager.getOpenState(): 项目打开状态
ProjectManager.nowConfig; ProjectManager.getNowConfig(): 已打开项目的配置
ProjectManager.refreshProjectsPath(): 刷新项目路径
ProjectManager.runProject(path): 运行项目
  path: 运行的文件路径，留空为默认
ProjectManager.updateNowConfig(config)--更新当前项目配置
  config: 配置
ProjectManager.openProject(path): 打开项目
  path:项目路径
ProjectManager.closeProject(refreshFilesBrowser): 关闭项目
  doNotRefreshFB: 刷新文件浏览器，默认为true
ProjectManager.shortPath(path,max,basePath): 截取完整路径的后半，取相对路径
  path: 绝对路径路径
  max: 最大字符数，如果max为true，代表无限大
  basePath: 当前路径

]]
local ProjectManager={}
ProjectManager._ENV=_ENV
local sdPath=AppPath.Sdcard
local openState,nowConfig=false,nil
local projectsFile,projectsPath,nowFile,nowPath

--刷新项目存放路径
local function refreshProjectsPath()
  xpcall(function()--防呆设计
    projectsPath=getSharedData("projectsDir")--所有项目路径
    projectsFile=File(projectsPath)
    projectsPath=projectsFile.getPath()--修复一下路径
  end,
  function()--手贱乱输造成报错
    projectsPath=sdPath.."/AppProjects"
    projectsFile=File(projectsPath)
    setSharedData("projectsDir",projectsPath)
    MyToast("项目路径出错，已恢复默认设置")
  end)
end
refreshProjectsPath()
ProjectManager.refreshProjectsPath=refreshProjectsPath

---运行项目
---@param path string 文件路径
function ProjectManager.runProject(path)
  local code,projectMainFile
  if openState then
    FilesTabManager.saveAllFiles()
    if nowConfig.badPrj then--损坏的项目
     elseif nowConfig.packageName then
      local success,err=pcall(function()
        local intent=Intent(Intent.ACTION_VIEW,Uri.parse(path or nowConfig.projectMainPath.."/main.lua"))
        local componentName=ComponentName(nowConfig.packageName,nowConfig.debugActivity or "com.androlua.LuaActivity")
        intent.setComponent(componentName)
        intent.putExtra("key",nowConfig.key)
        activity.startActivity(intent)
      end)
      if not(success) then--无法通过调用其他app打开时
        showSnackBar(R.string.runCode_noApp).
        setAction(R.string.viewError, function(view)
          showErrorDialog("Run Error",err)
        end)
        --print(err)
      end
     else
      showSnackBar(R.string.runCode_noPackageName)
    end
   else
    local code=EditorsManager.actions.getText()
    runLuaFile(nil,code)
  end
end

---更新当前项目配置
---@param config table 项目config.lua配置
local function updateNowConfig(config)
  nowConfig=config
  --做一系列刷新
  refreshSubTitle()
end
ProjectManager.updateNowConfig=updateNowConfig


---打开项目
---@param path string 工程路径
---@param filePath string 准备打开文件的路径，false为不打开
---@param openDirPath string 打开文件夹路径，默认为默认打开文件的目录，没有打开文件就是工程目录，false为不刷新适配器
function ProjectManager.openProject(path,filePath,openDirPath)
  xpcall(function()
    FilesBrowserManager.recordScrollPosition()
    if openedDirPath~=false then
      FilesBrowserManager.clearAdapterData(true)
    end
    local loadedConfig,config=pcall(RePackTool.getConfigByProjectPath,path)
    local projectMainPath,badPrj
    local mainModuleName="app"
    if loadedConfig then
      local loadedTool,rePackTool=pcall(RePackTool.getRePackToolByConfig,config)
      if loadedTool then
        mainModuleName=rePackTool.getMainModuleName(config)
        local mainProjectPath=RePackTool.getMainProjectDirByConfigAndRePackTool(path,config,rePackTool)
        if config.projectMainPath then
          projectMainPath=rel2AbsPath(config.projectMainPath,path)
         else
          projectMainPath=mainProjectPath.."/assets_bin"
        end
       else
        projectMainPath=path.."/app/src/main/assets_bin"
        badPrj=true
      end
     else
      config={
        appName="Bad project",
      }
      projectMainPath=path.."/app/src/main/assets_bin"
      badPrj=true
    end
    config.projectMainPath=projectMainPath
    config.badPrj=badPrj
    config.mainModuleName=mainModuleName

    openState=true
    if nowFile then
      luajava.clear(nowFile)
    end
    nowFile=File(path)
    nowPath=path

    updateNowConfig(config)
    setSharedData("openedProject",path)

    local nowBrowserDir=nowFile
    local nowOpenedFile
    if filePath~=false then
      filePath=filePath or getSharedData("openedFilePath_"..path)
      local defaultFile=File(config.projectMainPath.."/main.lua")
      if filePath then
        nowOpenedFile=File(filePath)
       elseif defaultFile.isFile() then
        nowOpenedFile=defaultFile
      end
    end
    if nowOpenedFile then
      FilesTabManager.openFile(nowOpenedFile,getFileTypeByName(nowOpenedFile.getName()), false)
      nowBrowserDir=nowOpenedFile.getParentFile()
     else
      EditorsManager.switchEditor("NoneView")
    end

    if openDirPath then
      nowBrowserDir=File(openDirPath)
    end
    if openDirPath~=false then
      FilesBrowserManager.refresh(nowBrowserDir,nil,false,true)
    end
  end,
  function(err)
    ProjectManager.closeProject(true)
    showErrorDialog("Open project",err)
  end)
  PluginsUtil.callElevents("onOpenProject", path,config)
  refreshMenusState()
  collectgarbage("collect")
end

---重新打开工程
function ProjectManager.reopenProject()
  if openState then
    FilesTabManager.saveFile()
    ProjectManager.openProject(nowPath,false,false)
  end
end


---关闭项目
---@param refreshFilesBrowser boolean 刷新文件浏览器，默认为true
function ProjectManager.closeProject(refreshFilesBrowser)
  local openedFilePath
  if FilesTabManager.openState then
    openedFilePath=FilesTabManager.file.getPath()
  end
  FilesBrowserManager.clearAdapterData(true)
  FilesTabManager.closeAllFiles(false)
  if openState then
    setSharedData("openedFilePath_"..nowPath,openedFilePath)
    luajava.clear(nowFile)
  end
  openState=false
  nowFile=nil
  nowPath=nil
  updateNowConfig(nil)
  setSharedData("openedProject",nil)
  EditorsManager.switchEditor("LuaEditor")
  local editor=EditorsManager.editor
  local defaultText=EditorsManager.editorConfig.defaultText
  editor.setTextSize(math.dp2int(14))
  editor.scrollTo(0,0)
  editor.setText(defaultText)
  editor.setSelection(#defaultText)
  if refreshFilesBrowser~=false then
    FilesBrowserManager.refresh(nil,nil,false,true)
  end
  PluginsUtil.callElevents("onCloseProject")
  refreshMenusState()
end

--截取完整路径的后半，取相对路径
--[[
path: 绝对路径路径
max: 最大字符数，如果max为true，代表无限大
basePath: 当前路径
]]
function ProjectManager.shortPath(path,max,basePath)
  local newPath
  if not(basePath) then
    if openState then
      basePath=nowFile.getParent()
     else
      basePath=projectsPath
    end
  end
  local pathJ=String(path)
  if pathJ.startsWith(basePath) then
    newPath=string.sub(path,string.len(basePath)+2)
   else
    newPath=path
  end
  luajava.clear(pathJ)
  --开始检测字符串是否过长
  if max==true then
    return newPath
  end
  local len=utf8.len(newPath)
  if len>(max or 15) then
    return "..."..utf8.sub(newPath,len-(max or 15)+1,len)
   else
    return newPath
  end
end

--通过content.icon获取工程图标文件
--在 v5.1.0(51099) 添加
function ProjectManager.getExistingIconFileByContent(content,projectPath)
  local type_=type(content)
  local file,path
  if type_=="string" then
    path=rel2AbsPath(content,projectPath)
    file=File(path)
    return (file.isFile() and file),path
   elseif type_=="table" then--此时content为table
    local isNightMode=ThemeUtil.isNightMode()--获取夜间模式状态
    --如果开启了夜间模式，并且存在night值，就使用night值，否则使用day值，如果day值没有的话，就真的没了
    --无night值时使用day值，但无day值时不会使用night值
    --补充知识点：and的作用是挨个取值，如果都不为nil或false，则返回第二个值。or挨个取值，哪个最先不为nil或false，就取哪个
    --为哈非常多人连这个语法都不知道呢，只是简单认为and两边都为true返回true，or两边有一个为true就返回true
    local autoIcon=(isNightMode and content.night) or content.day
    if autoIcon then--如果有自动图标，那就用自动图标
      file,path=ProjectManager.getExistingIconFileByContent(autoIcon,projectPath)
      if file then
        return file,path
      end
     else
    end
    for index=1,#content do
      local subContent=content[index]
      if subContent then
        file,path=ProjectManager.getExistingIconFileByContent(subContent,projectPath)
        if file then
          return file,path
        end
      end
    end
  end
end

--获取图标路径
--在 v5.1.0(51099) 添加
function ProjectManager.getProjectIconPath(config,projectPath,mainProjectPath)
  local iconPaths={
    config.icon,
    projectPath.."/ic_launcher-playstore.png",
    projectPath.."/ic_launcher-aidelua.png",
    mainProjectPath.."/ic_launcher-playstore.png",
    mainProjectPath.."/ic_launcher-aidelua.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher_round.png",
    mainProjectPath.."/res/mipmap-xxxhdpi/ic_launcher.png",
    mainProjectPath.."/res/drawable/ic_launcher.png",
    mainProjectPath.."/res/drawable/icon.png",
  }
  local file,path=ProjectManager.getExistingIconFileByContent(iconPaths,projectPath)
  return path
end


function ProjectManager.getNowConfig()
  return nowConfig
end
function ProjectManager.getOpenState()
  return openState
end
function ProjectManager.getProjectsFile()
  return projectsFile
end
function ProjectManager.getProjectsPath()
  return projectsPath
end
function ProjectManager.getNowFile()
  return nowFile
end
function ProjectManager.getNowPath()
  return nowPath
end


return createVirtualClass(ProjectManager)
