---关于对话框
local AlertDialogBuilder

--依次尝试获取不同的对话框构建器
local adbClsNames = {
    "com.google.android.material.dialog.MaterialAlertDialogBuilder",
    "androidx.appcompat.app.AlertDialog$Builder",
    "android.app.AlertDialog$Builder",
}
for index = 1, #adbClsNames do
    local success, Builder = pcall(import, adbClsNames[index]) --require the class and call the build function if it is there.
    if success then
        AlertDialogBuilder = Builder
        break
    end
end

local contentFormat = [[
版本：%s (%s)
开发者：%s

%s]]

local unknown = "未知"

local selfContent
local selfInitCfg = {}
local AboutDialog = {}

function AboutDialog.showSelfDlg()
    if selfContent == nil then
        assert(loadfile(activity.getLuaDir() .. "/init.lua", "bt", selfInitCfg))()
        selfContent = string.format(contentFormat,
            selfInitCfg.appver or selfInitCfg.app_ver or unknown,
            selfInitCfg.appcode or selfInitCfg.app_code or unknown,
            selfInitCfg.developer or unknown,
            selfInitCfg.description or unknown)
    end
    local builder = AlertDialogBuilder(activity)
    builder.setTitle(selfInitCfg.appname or selfInitCfg.app_name)
    builder.setMessage(selfContent)
    builder.setPositiveButton(android.R.string.ok, nil)
    builder.show()
end

return AboutDialog
