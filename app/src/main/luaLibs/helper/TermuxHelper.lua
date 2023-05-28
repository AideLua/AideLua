--v5.1.1+
import "com.termux.shared.termux.TermuxConstants"
local RUN_COMMAND_SERVICE = TermuxConstants.TERMUX_APP.RUN_COMMAND_SERVICE

local TermuxHelper = {}
function TermuxHelper.runInTermux(cmd, args, config)
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
            if config.title then
                resultIntent.putExtra("title", config.title)
            end
            local pendingIntent = PendingIntent.getActivity(activity, 1, resultIntent, PendingIntent.FLAG_ONE_SHOT)
            intent.putExtra(RUN_COMMAND_SERVICE.EXTRA_PENDING_INTENT, pendingIntent)
            if Build.VERSION.SDK_INT >= 26 then --安卓8.0后要以前景服务方式运行
                activity.startForegroundService(intent)
            else
                activity.startService(intent)
            end
        end
        local manager = activity.getPackageManager()
        local intent = manager.getLaunchIntentForPackage(TermuxConstants.TERMUX_PACKAGE_NAME)
        activity.startActivity(intent)
    end
end

return TermuxHelper
