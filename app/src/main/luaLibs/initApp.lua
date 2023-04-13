import "android.os.Build"
import "android.os.Environment"

local SDK_INT = Build.VERSION.SDK_INT
if getSharedData("richAnim") == nil then
    if SDK_INT >= 28 then
        setSharedData("richAnim", true)
    else
        setSharedData("richAnim", false)
    end
end

if getSharedData("moreCompleteRun") == nil then
    setSharedData("moreCompleteRun", true)
end

if getSharedData("compileLua") == nil then
    setSharedData("compileLua", true)
end

if getSharedData("alignZip") == nil then
    setSharedData("alignZip", true)
end

if getSharedData("alignZipTool") == nil then
    setSharedData("alignZipTool", 0)
end

if getSharedData("jesse205Lib_support") == nil then
    setSharedData("jesse205Lib_support", false)
end

if getSharedData("androidX_support") == nil then
    setSharedData("androidX_support", true)
end

if getSharedData("editor_wordwrap") == nil then
    setSharedData("editor_wordwrap", false)
end

if getSharedData("editor_showBlankChars") == nil then
    setSharedData("editor_showBlankChars", false)
end

if getSharedData("editor_magnify") == nil then
    if SDK_INT >= 28 then
        setSharedData("editor_magnify", true)
    else
        setSharedData("editor_magnify", false)
    end
end

if getSharedData("editor_previewButton") == nil then
    if SDK_INT >= 28 then
        setSharedData("editor_previewButton", true)
    else
        setSharedData("editor_previewButton", false)
    end
end

if getSharedData("editor_font") == nil then
    setSharedData("editor_font", 1)
end

if getSharedData("editor_symbolBar") == nil then
    setSharedData("editor_symbolBar", true)
end

if getSharedData("tab_icon") == nil then
    setSharedData("tab_icon", true)
end

if getSharedData("editor_autoBackupOriginalFiles") == nil then
    setSharedData("editor_autoBackupOriginalFiles", true)
end

local sdcardPath = Environment.getExternalStorageDirectory().getPath()
if getSharedData("projectsDir") == nil then
    setSharedData("projectsDir", sdcardPath .. "/AppProjects")
end
--多工程目录
if getSharedData("projectsDirs") == nil then
    setSharedData("projectsDirs",
        sdcardPath .. "/AppProjects;"
        .. sdcardPath .. "/AndroidIDEProjects;")
end

if getSharedData("autoCheckUpdate") == nil then
    setSharedData("autoCheckUpdate", false)
end
