--此文件内为此页面的部分函数

---适配了软件的全屏滑动容器
MyFullDraggableContainer = {
    _baseClass = FullDraggableContainer,
    __call = function(self, context)
        local view, initialMotionX
        view = luajava.override(FullDraggableContainer, {
            onInterceptTouchEvent = function(super, event)
                super(event)
                return false
                --super(event)
                --view.onTouchEvent(event)
            end
        }, context)
        return view
    end,
}
setmetatable(MyFullDraggableContainer, MyFullDraggableContainer)



---检查是不是路径相同的文件<br>
---请直接使用 filePath1==filePath2 判断路径是否相同
---@deprecated
---@return boolean 文件路径是否相同
function isSamePathFileByPath(filePath1, filePath2) --通过文件路径
    return filePath1 == filePath2
end

---检查是不是路径相同的文件<br>
--- 请直接使用 file1==file2 判断路径是否相同
---@deprecated
---@return boolean 文件路径是否相同
function isSamePathFile(file1, file2) --通过文件本身
    return file1 == file2
end

---在 v5.1.1(51199) 返回结果改为 normalTable
---创建支持 getter 的虚拟类，实现 getter
---@generic T : table
---@param normalTable T
---@return T 虚拟类实现的功能
function createVirtualClass(normalTable)
    local metatable = {
        __index = function(self, key)
            local rawValue = rawget(self, key)
            if rawValue then
                return rawValue
            else
                local getterName = "get" .. key:gsub("^%l", string.upper)
                ---@type fun()
                local getterFunc = rawget(self, getterName)
                if getterFunc then
                    return getterFunc()
                end
            end
        end
    }
    setmetatable(normalTable, metatable)
    return normalTable
end

---运行lua文件或lua代码
---@param file File 文件名
---@param code string 或lua代码
function runLuaFile(file, code)
    if file and file.isFile() then
        newActivity(file.getPath())
    else
        newSubActivity("RunCode", { code })
    end
end

---自动识别显示toast的方式进行显示
---@param text string|number
---@return SnackBar|Toast
function showSnackBar(text)
    if FilesBrowserManager.openState and nowDevice ~= "pc" then
        return MyToast(text, mainLay)
    else
        return MyToast(text, editorGroup)
    end
end

---判断是不是二进制文件
---@param filePath string 文件路径
---@return boolean 是否是二进制文件
function isBinaryFile(filePath)
    local ioFile = io.open(filePath, "r")
    if ioFile then
        local code = ioFile:read("*all")
        ioFile:close()
        if code ~= "" then
            local c = string.byte(code)
            if c <= 0x1c and c >= 0x1a and c ~= " " and c ~= "\t" then
                return true
            end
        end
        return code
    else
        return nil
    end
end

---复制表，但跳过已存在的数据
---@param oldTable table 源表
---@param newTable table 目标表
function safeCloneTable(oldTable, newTable)
    for index, content in pairs(oldTable) do
        if newTable[index] == nil then
            newTable[index] = oldTable[index]
        end
    end
end

---刷新Menu状态
function refreshMenusState()
    if LoadedMenu then
        local fileOpenState, projectOpenState = FilesTabManager.openState, ProjectManager.openState
        local isEditor = EditorsManager.checkEditorSupport("getText")
        local menus = {
            { StateByFileMenus,          fileOpenState },
            { StateByProjectMenus,       projectOpenState },
            { StateByFileAndEditorMenus, fileOpenState and isEditor },
            { StateByEditorMenus,        isEditor },
            { StateByNotBadPrjMenus,     not (projectOpenState and ProjectManager.nowConfig.badPrj) }
        }
        for index, content in pairs(menus) do
            for index, menu in ipairs(content[1]) do
                menu.setEnabled(toboolean(content[2]))
            end
        end
        PluginsUtil.callElevents("refreshMenusState")
    end
end

---在 v5.1.0(51099) 已废除
---刷新放大镜状态
function refreshMagnifier()
    print("警告", "refreshMagnifier", "在 v5.1.0(51099) 已废除")
end

---@enum string
local MyMimeMap = {
    lua = "text/plain",
}
setmetatable(MyMimeMap, {
    __index = function(self, key)
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(key) or "*/"
    end
})

---在 v5.1.0(51099) 添加
---获取 MimeType
---@param extensionName string
---@return string MimeType
function getMimeType(extensionName)
    return MyMimeMap[extensionName]
end

---用外部应用打开文件
---@param path string
function openFileITPS(path)
    import "android.webkit.MimeTypeMap"
    local file = File(path)
    local name = file.getName()
    local extensionName = getFileTypeByName(name)
    local mime = getMimeType(extensionName)
    if mime then
        local intent = Intent()
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.setAction(Intent.ACTION_VIEW)
        intent.setType(mime)
        intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        --intent.putExtra(Intent.EXTRA_STREAM, activity.getUriForFile(file))
        --intent.addFlags(Intent.FLAG_ACTIVITY_NEW_DOCUMENT)
        intent.setData(activity.getUriForFile(file))
        if mime == "*/" then
            activity.startActivity(Intent.createChooser(intent, name))
        else
            activity.startActivity(intent)
        end
    end
end

---@enum WindmillTools
WindmillTools = {
    ["手册"] = 2,
    ["Java API"] = 3,
    ["Http 调试"] = 4,
}

function startWindmillActivity(toolName)
    local success = pcall(function()
        local uri = Uri.parse("wm://tool:" .. WindmillTools[toolName])
        local intent = Intent(Intent.ACTION_VIEW, uri)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_DOCUMENT)
        activity.startActivity(intent)
    end)
    if not (success) then
        openUrl("https://www.coolapk.com/apk/com.agyer.windmill")
        MyToast.showToast(R.string.windmill)
    end
end

---公共ActivityFormatter
local sharedActivityPathTemplate = AppPath.Sdcard .. "/Android/media/%s/cache/temp/aidelua/activities/%s"

---更新共享Activity到目录
---@param name string 页面名称
---@param sdActivityDir File 内部存储目录
function updateSharedActivity(name, sdActivityDir)
    LuaUtil.rmDir(sdActivityDir)
    LuaUtil.copyDir(File(activity.getLuaDir("sub/" .. name)), sdActivityDir)
end

---检查共享活动的更新
---@param name string 页面名称
---@return string mainLuaPath 主文件路径
function checkSharedActivity(name)
    ---@type string
    local packageName
    ---@type string
    packageName = ProjectManager.openState and ProjectManager.nowConfig.packageName or activity.getPackageName()
    local sdActivityPath = sharedActivityPathTemplate:format(packageName, name)
    local sdActivityDir = File(sdActivityPath)

    local sdActivityInitPath = sdActivityPath .. "/init.lua"
    local sdActivityInitFile = File(sdActivityInitPath)
    local initExists = sdActivityInitFile.isFile() --主页面是否存在
    if initExists then
        local latestConfig = getConfigFromFile(activity.getLuaDir("sub/" .. name .. "/init.lua"))
        local success, nowConfig = pcall(getConfigFromFile, sdActivityInitPath)
        if not (success and nowConfig.appcode and latestConfig.appcode) or tonumber(latestConfig.appcode) ~= tonumber(nowConfig.appcode) then
            updateSharedActivity(name, sdActivityDir)
        end
    else
        updateSharedActivity(name, sdActivityDir)
    end
    return sdActivityPath .. "/main.lua"
end

---刷新子标题
---@param newScreenWidthDp number
function refreshSubTitle(newScreenWidthDp)
    if ProjectManager.openState then
        local appName = ProjectManager.nowConfig.appName
        if screenWidthDp then
            if screenWidthDp < 360 then
                actionBar.setSubtitle(appName)
            elseif screenWidthDp < 380 then
                actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_360dp, { appName }))
            elseif screenWidthDp < 390 then
                actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_380dp, { appName }))
            else
                actionBar.setSubtitle(formatResStr(R.string.project_appSubtitle_390dp, { appName }))
            end
        else
            actionBar.setSubtitle(appName)
        end
        activity.setTaskDescription(ActivityManager.TaskDescription(appName .. "-" .. getString(R.string.app_name), nil,
            theme.color.colorPrimary))
    else
        actionBar.setSubtitle(R.string.project_no_open)
        activity.setTaskDescription(ActivityManager.TaskDescription(getString(R.string.app_name), nil,
            theme.color.colorPrimary))
    end
end

---通过文件名获取扩展名
---扩展名写成类型了，就这样凑合用吧
---@param name string 文件名
---@return string|nil extensionName 扩展名
function getFileTypeByName(name)
    local extensionName = name:match(".+%.(.+)")
    if extensionName then
        return string.lower(extensionName)
    end
    return nil
end

--v5.1.2
getExtensionNameByName = getFileTypeByName

---修复因LayoutTransition导致的布局延迟<br>
---逻辑：先去除LayoutTransition，再设置回来<br>
---使用方法：<br>
---local applyLT=fixLT({view1,view2})<br>
---applyLT()
---@param list table<ViewGroup>
---@return function applyLT 恢复 LayoutTransition
function fixLT(list)
    local lTList = {}
    for index = 1, #list do
        local view = list[index]
        lTList[index] = view.getLayoutTransition()
        view.setLayoutTransition(nil)
    end
    return function()
        for index = 1, #list do
            list[index].setLayoutTransition(lTList[index])
        end
        list = nil
        lTList = nil
    end
end

---将字符串添加到列表内
---@param text string 字符串
---@param list string[]
---@param checkList table<string,boolean>
function addStrToTable(text, list, checkList)
    if not checkList[text] then
        table.insert(list, text)
        checkList[text] = true
    end
end

---@param inLibDirPath string 在lib文件夹的路径
---@param filePath string 文件绝对路径
---@param fileRelativePath string 文件相对于工程的路径
---@param fileName string 文件名
---@param isFile boolean 是文件？
---@param isResDir boolean 是在res文件夹？
---@param fileExtensionName string 文件扩展名
function getFilePathCopyMenus(inLibDirPath, filePath, fileRelativePath, fileName, isFile, isResDir, fileExtensionName)
    local textList = {}
    local textCheckList = {}
    if inLibDirPath then
        local callLibPath = inLibDirPath:gsub("/", ".")
        addStrToTable(fileName:match("(.+)%.") or fileName, textList, textCheckList)
        addStrToTable(callLibPath, textList, textCheckList)
        if fileExtensionName == "aly" or fileExtensionName == "lua" or fileExtensionName == "java" or fileExtensionName == "kt" or File(filePath .. "/init.lua").isFile() then
            addStrToTable(CodeHelper.getImportCode(callLibPath), textList, textCheckList)
        end
    else
        addStrToTable(fileName, textList, textCheckList)
    end
    addStrToTable(fileRelativePath, textList, textCheckList)
    --table.clear(textCheckList)
    textCheckList = nil
    return textList
end

---这是去除./和../的
function fixPath(path)
    path = (path .. "/")
        :gsub("//+", "/")
        :gsub("/%./", "/")
    repeat
        local oldPath = path
        path = oldPath:gsub("/[^/]+/%.%./", "/", 1)
    until (oldPath == path)
    return path:match("(.+)/") or "/"
end

---获取table的index列表
function getTableIndexList(mTable)
    local list = {}
    for index, content in pairs(mTable) do
        table.insert(list, index)
    end
    return list
end

---@enum
local name2ColorMap = {
    white = 0xffffffff,
    black = 0xff000000,
    red = 0xffff0000,
    green = 0xff00ff00,
    blue = 0xff0000ff,
}
name2ColorMap["白色"] = name2ColorMap.white
name2ColorMap["黑色"] = name2ColorMap.black
name2ColorMap["红色"] = name2ColorMap.red
name2ColorMap["绿色"] = name2ColorMap.green
name2ColorMap["蓝色"] = name2ColorMap.blue
name2ColorMap["白"] = name2ColorMap.white
name2ColorMap["黑"] = name2ColorMap.black
name2ColorMap["红"] = name2ColorMap.white
name2ColorMap["绿"] = name2ColorMap.green
name2ColorMap["蓝"] = name2ColorMap.blue

function formatColor2Hex(color)
    if color >= 0 and color <= 0xFFFFFFFF then
        local success, result = pcall(String.format, "%08X", { color })
        if success then
            return "#" .. result
        end
    end
end

---获取文字内颜色的数值和16进制
function getColorAndHex(text)
    if text and text ~= "" then
        local success, color
        color = name2ColorMap[string.lower(text)] or tonumber(text)
        if color then
            return color, formatColor2Hex(color)
        end
        success, color = pcall(Color.parseColor, "#" .. text)
        if success then
            return color, "#" .. string.upper(text)
        end
    end
end

---在 v5.1.1(51199) 添加
---适配SEND应用权限，适配华为文件管理
---@param uri Uri:
function authorizeHWApplicationPermissions(uri)
    local flag = Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION
    local intent = Intent()
    intent.setAction("android.intent.action.SEND")
    intent.setFlags(268435456)
    intent.setType(activity.getContentResolver().getType(uri))
    local infoList = activity.getPackageManager().queryIntentActivities(intent, 65536)
    for index = 0, #infoList - 1 do
        activity.grantUriPermission(infoList[index].activityInfo.packageName, uri, flag)
    end
    activity.grantUriPermission("com.huawei.desktop.explorer", uri, flag)
    activity.grantUriPermission("com.huawei.desktop.systemui", uri, flag)
    activity.grantUriPermission("com.huawei.distributedpasteboard", uri, flag)
end

---v5.1.1+
---安全加载 lua 布局，避免污染全局变量
---@param path string 布局路径
---@param parent ViewGroup 父布局类
---@return View 生成的视图
function safeLoadLayout(path, parent)
    local env = {}
    setmetatable(env, {
        __index = function(self, key)
            local globalVar = _G[key]
            if globalVar then
                rawset(self, key, globalVar)
                return globalVar
            end
            for index = 1, #androidx do
                local classStr = androidx[index]:gsub("%*", key)
                local success, content = pcall(luajava.bindClass, classStr)
                if success then
                    rawset(self, key, content)
                    return content
                end
            end
        end
    })
    local file = io.open(path)
    local fileContent = file:read("*a")
    file:close()
    local layout = assert(loadstring("return " .. fileContent, nil, "bt", env))()
    --去除一些属性，不使用递归
    local nowNodes = { layout }
    repeat
        local nowNode = nowNodes[1]
        nowNode.onClick = nil
        nowNode.onLongClick = nil
        for index, content in pairs(nowNode) do
            if type(index) == "number" and type(content) == "table" then
                table.insert(nowNodes, content)
            end
        end
        table.remove(nowNodes, 1)
    until (#nowNodes <= 0)
    return loadlayout(layout, {}, parent)
end

---v5.1.1+
---复制文件，从 DocumentFile 内。目前文件夹只能复制 DocumentUi 的 uri
---@param documentFile DocumentFile 原文件
---@param targetPath string 目标文件夹
function copyFilesFromDocumentFile(documentFile, targetPath)
    import "com.jesse205.util.FileUriUtil"
    local uri = documentFile.getUri()
    local name = documentFile.getName()
    local newPath = targetPath .. "/" .. name
    if documentFile.isDirectory() then
        local isGetPathSucceeded, reallyPath = pcall(FileUriUtil.getPath, activity, uri)
        if isGetPathSucceeded then
            local isCpSucceeded, content = pcall(FileUtil.copyDir, File(reallyPath), File(newPath))
            if not isCpSucceeded then
                showErrorDialog(name, content)
            end
        end
        --[[
    local list=documentFile.listFiles()
    for index=0,#list-1 do
      local name=documentFile.getName()
      copyFilesFromDocumentFile(documentFile,targetPath.."/"..name)
    end]]
    else
        if File(newPath).exists() then
            showSnackBar(name .. ": " .. getString(R.string.file_exists))
        else
            local isOpenSuccessful, inputStream = pcall(activity.getContentResolver().openInputStream, uri)
            if not isOpenSuccessful then
                showErrorDialog("Unable to open uri", "uri: " .. tostring(uri) .. "\n\n" .. inputStream)
                return
            end
            local outStream = FileOutputStream(newPath)
            local success, content = pcall(FileUtil.copyFileStream, inputStream, outStream)
            if not success then
                showErrorDialog("Copy error", "uri: " .. tostring(uri) .. "\nname: " .. name .. "\n\n" .. content)
            end
            inputStream.close()
            outStream.close()
        end
    end
end

---v5.1.1+
---在 Termux 内运行代码
---@param cmd string 运行的程序
---@param args table(string[]) 参数
---@param config table(map) 配置
function runInTermux(cmd, args, config)
    if PermissionUtil.checkPermission("com.termux.permission.RUN_COMMAND") then
        if cmd:sub(1, 1) ~= "/" then
            cmd = "/data/data/com.termux/files/usr/bin/" .. cmd
        end
        config = config or {}
        local intent = Intent()
        intent.setClassName(TermuxConstants.TERMUX_PACKAGE_NAME, TermuxConstants.TERMUX_APP.RUN_COMMAND_SERVICE_NAME)
        intent.setAction(RUN_COMMAND_SERVICE.ACTION_RUN_COMMAND)
        intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_COMMAND_PATH, cmd)
        intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_ARGUMENTS, String(args))
        intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_BACKGROUND, false)
        intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_WORKDIR,
            config.workDir or ProjectManager.nowPath .. "/" .. ProjectManager.nowConfig.mainModuleName)
        --显示结果
        if config.showResult then
            local resultIntent = activity.buildNewActivityIntent(0, "sub/TermuxResult/main.lua", nil, true, 0)
            resultIntent.putExtra("title", config.title)
            local pendingIntent = PendingIntent.getActivity(activity, 1, resultIntent, PendingIntent.FLAG_ONE_SHOT)
            intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_PENDING_INTENT, pendingIntent)
        end
        if Build.VERSION.SDK_INT >= 26 then
            activity.startForegroundService(intent)
        else
            activity.startService(intent)
        end
        local manager = activity.getPackageManager()
        local intent = manager.getLaunchIntentForPackage(TermuxConstants.TERMUX_PACKAGE_NAME)
        activity.startActivity(intent)
    end
end

---v5.1.1+
---将路径转换为 DocumentUi的 uri
---@param path string 路径
function path2DocumentUri(path)
    if String(path).startsWith(AppPath.Sdcard) then
        local relativePath = string.sub(path, string.len(AppPath.Sdcard) + 2):gsub("/", "%%2f")
        return Uri.parse("content://com.android.externalstorage.documents/document/primary:" .. relativePath)
    end
end

--[[
function createFolderIconWitchBadge(badgeId,badgeWidth,badgeColor)
  local iconDrawable=activity.getDrawable(R.drawable.ic_folder_outline)
  local badgeDrawable=activity.getDrawable(badgeId)
  if badgeColor then
    badgeDrawable.setTintList(ColorStateList.valueOf(badgeColor))
  end
  local background = LayerDrawable({iconDrawable,badgeDrawable})
  background.setLayerGravity(0, Gravity.CENTER)
  background.setLayerGravity(1, Gravity.CENTER)
  local iconWidth=math.dp2int(24)
  local badgeWidth=badgeWidth or math.dp2int(14)

  background.setLayerSize(0, iconWidth, iconWidth)
  background.setLayerSize(1, badgeWidth, badgeWidth)
  background.setLayerInset(1,math.dp2int(2),math.dp2int(4),math.dp2int(2),math.dp2int(2))
  return background
end
]]
