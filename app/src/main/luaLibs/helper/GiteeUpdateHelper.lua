import "cjson"

---Gitee更新助手
local GiteeUpdateHelper = {}
local packageInfo = activity.getPackageManager().getPackageInfo(getPackageName(), 0)
local baseUrl = "https://gitee.com/api/v5/repos/%s/%s/releases/latest"

---显示更新弹窗
function GiteeUpdateHelper.showUpdateDialog(content)
    if not activity.isFinishing() then
        local dialog = AlertDialog.Builder(this)
            .setTitle(content.name)
            .setMessage(content.body)
            .setPositiveButton(R.string.download, nil)
            .setNegativeButton(android.R.string.no, nil)
            .show()
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).onClick = function(view)
            local assets = content.assets
            local pop = PopupMenu(activity, view)
            local menu = pop.getMenu()
            for index = 1, #assets do
                local content = assets[index]
                local name = content.name
                if name then
                    name = name:gsub("_[0-9]*_", "_")
                else
                    name = content.browser_download_url:match("/([^/]*)$")
                end
                menu.add(0, index, 0, name)
            end
            pop.show()
            pop.onMenuItemClick = function(item)
                local id = item.getItemId()
                openInBrowser(assets[id].browser_download_url)
            end
        end
    end
end

---检查更新
---@param owner string 所有者
---@param repo string 仓库
---@param nowTag string? 当前版本号
function GiteeUpdateHelper.checkUpdate(owner, repo, nowTag)
    local snackBar = MyToast(R.string.checkingUpdates)
    Http.get(baseUrl:format(owner, repo), nil, "UTF-8", nil, function(code, content, cookie, header)
        snackBar.dismiss()
        if code == 200 then
            pcall(GiteeUpdateHelper.showUpdateDialog, cjson.decode(content))
        else
            MyToast.showNetErrorToast(code)
        end
    end)
end

return GiteeUpdateHelper
