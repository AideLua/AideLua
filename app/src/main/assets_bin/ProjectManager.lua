--[[
ProjectManager: 项目管理器
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

--运行项目
function ProjectManager.runProject(path)
  local code,projectMainFile
  if openState then
    FilesTabManager.saveAllFiles()
    if nowConfig.packageName then
      local success,err=pcall(function()
        local intent=Intent(Intent.ACTION_VIEW,Uri.parse(path or nowConfig.projectMainPath.."/main.lua"))
        local componentName=ComponentName(nowConfig.packageName,nowConfig.debugActivity or "com.androlua.LuaActivity")
        intent.setComponent(componentName)
        activity.startActivity(intent)
      end)
      if not(success) then--无法通过调用其他app打开时
        showSnackBar(R.string.runCode_noApp)
        print(err)
      end
     else
      showSnackBar(R.string.runCode_noPackageName)
    end
   else
    local code=EditorsManager.actions.getText()
    runLuaFile(nil,code)
  end
end

--更新当前项目配置
local function updateNowConfig(config)
  nowConfig=config
  --做一系列刷新
  refreshSubTitle()
end
ProjectManager.updateNowConfig=updateNowConfig

--打开项目
function ProjectManager.openProject(path,filePath,openedDirPath)
  FilesBrowserManager.clearAdapterData()
  openState=true
  nowFile=File(path)
  nowPath=path
  local config=RePackTool.getConfigByProjectPath(path)
  local rePackTool=RePackTool.getRePackToolByConfig(config)
  local mainProjectPath=RePackTool.getMainProjectDirByConfigAndRePackTool(path,config,rePackTool)
  if config.projectMainPath then
    config.projectMainPath=path.."/"..config.projectMainPath
   else
    config.projectMainPath=mainProjectPath.."/assets_bin"
  end
  updateNowConfig(config)
  setSharedData("openedProject",path)
  EditorsManager.switchEditor("NoneView")
  local nowBrowserDir,nowOpenedFile
  filePath=filePath or getSharedData("openedFilePath_"..path)
  local defaultFile=File(config.projectMainPath.."/main.lua")

  if filePath then
    nowOpenedFile=File(filePath)
   elseif defaultFile.isFile() then
    nowOpenedFile=defaultFile
   else
    nowBrowserDir=nowFile
  end
  if nowOpenedFile then
    FilesTabManager.openFile(nowOpenedFile,getFileTypeByName(nowOpenedFile.getName()), false)
    nowBrowserDir=nowOpenedFile.getParentFile()
  end
  if openedDirPath then
    nowBrowserDir=File(openedDirPath)
  end
  FilesBrowserManager.refresh(nowBrowserDir,false,false,true)
  refreshMenusState()
end


--关闭项目
function ProjectManager.closeProject(refreshFilesBrowser)
  local openedFilePath
  if FilesTabManager.openState then
    openedFilePath=FilesTabManager.file.getPath()
  end
  FilesBrowserManager.clearAdapterData()
  FilesTabManager.closeAllFiles(true)
  if openState then
    setSharedData("openedFilePath_"..nowPath,openedFilePath)
  end
  openState=false
  nowFile=nil
  nowPath=nil
  updateNowConfig(nil)
  setSharedData("openedProject",nil)
  --FilesBrowserManager.directoryFilesList=nil
  --FilesBrowserManager.setDirectoryFilesList({})

  EditorsManager.switchEditor("LuaEditor")
  local editor=EditorsManager.editor
  local defaultText=EditorsManager.editorConfig.defaultText
  editor.setTextSize(math.dp2int(14))
  editor.scrollTo(0,0)
  editor.setText(defaultText)
  editor.setSelection(#defaultText)
  if refreshFilesBrowser~=false then
    FilesBrowserManager.refresh(nil,false,false,true)
  end
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
  if String(path).startsWith(basePath) then
    newPath=string.sub(path,string.len(basePath)+2)
   else
    newPath=path
  end
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
