--默认设置

import "android.os.Build"
import "android.os.Environment"

local SDK_INT = Build.VERSION.SDK_INT
local isSdk28AndUp = SDK_INT >= 28
local sdcardPath = Environment.getExternalStorageDirectory().getPath()

return {
    richAnim = isSdk28AndUp,
    moreCompleteRun = true,
    compileLua = true,
    alignZip = true,
    alignZipTool = 0,
    jesse205Lib_support = false,
    androidX_support = true,
    editor_wordwrap = false,
    editor_showBlankChars = false,
    editor_magnify = isSdk28AndUp,
    editor_previewButton = isSdk28AndUp,
    editor_font = 1,
    editor_symbolBar = true,
    tab_icon = true,
    editor_autoBackupOriginalFiles = true,
    projectsDir = sdcardPath .. "/AppProjects",
    projectsDirs = sdcardPath .. "/AppProjects;"
        .. sdcardPath .. "/AndroidIDEProjects;",
    autoCheckUpdate = false
}
