local gLLO = getLocalLangObj
permissionInformation = {
    {
        icon = R.drawable.ic_file_outline,
        title = R.string.jesse205_permission_storage,
        summary = gLLO("存储项目、编辑文件、调试项目等",
            "Store projects, edit files, debug projects, etc."),
        permissions = { "android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.READ_EXTERNAL_STORAGE" },
    },
    {
        icon = R.drawable.ic_phone_outline,
        title = R.string.jesse205_permission_phone,
        summary = gLLO("统计软件使用情况", "Statistics of software usage."),
        permissions = { "android.permission.READ_PHONE_STATE" },
    },
    {
        icon = R.drawable.ic_tooltip_text_outline,
        title = gLLO("后台弹窗", "Background pop-up"),
        summary = gLLO("在后台提示任务进度 (需进入“设置”给予)",
            "Prompt task progress in the background. (Need to enter \"Settings\")"),
        permissions = { "com.huawei.permission.POPUP_BACKGROUND_WINDOW" },
    },
    {
        icon = R.drawable.ic_android,
        title = gLLO("安装应用", "Install application"),
        summary = gLLO("在文件浏览器、二次打包内快捷安装应用 (需进入“设置”给予)",
            "Quickly install applications in the file browser and secondary packaging. (Need to enter \"Settings\")"),
        permissions = { "android.permission.REQUEST_INSTALL_PACKAGES" },
    },
    {
        icon = R.drawable.ic_console,
        title = gLLO("在 Termux 环境中运行命令", "Run commands in Termux environment"),
        summary = gLLO("支持 Gradle 运行", "Support gradle running"),
        permissions = { "com.termux.permission.RUN_COMMAND" },
    },
}
