return {
    {
        --用户权益
        SettingsLayUtil.TITLE,
        title = "用户权益 User benefits",
        key = "user_benefits",
        {
            --Aide Lua Pro Plus
            SettingsLayUtil.ITEM_NOSUMMARY,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "Aide Lua Pro Plus",
            key = "user_vip",
            newPage = true,
        },
    },
    {
        --界面
        SettingsLayUtil.TITLE,
        title = R.string.jesse205_ui,
        key = "ui",
        {
            --主题选择
            SettingsLayUtil.ITEM_NOSUMMARY,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = R.string.jesse205_themeColor,
            key = "theme_picker",
            newPage = true,
        },
        {
            --Material 3
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "Material 3",
            key = ThemeManager.THEME_MATERIAL3,
            sharedPreferences = PreferenceManager.getDefaultSharedPreferences(activity),
        },
        {
            --暗色工具栏
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_theme_light_dark,
            title = R.string.jesse205_darkActionBar,
            key = ThemeManager.THEME_DARK_ACTION_BAR,
            sharedPreferences = PreferenceManager.getDefaultSharedPreferences(activity),
        },
        {
            --更多动画
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_animation_play_outline,
            title = R.string.settings_ui_richAnim,
            key = "richAnim",
        },
    },
    {
        --构建&打包
        SettingsLayUtil.TITLE,
        title = R.string.buildAndPack,
        key = "build_and_pack",
        {
            --比较完整的运行
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_play_outline,
            title = R.string.settings_moreCompleteRun,
            key = "moreCompleteRun",
            summary = R.string.settings_moreCompleteRun_summary,
        },
        {
            --编译Lua
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_file_code_outline,
            title = R.string.compileLua,
            key = "compileLua",
            summary = R.string.compileLua_summary,
        },
        {
            --ZipAlign对齐
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_zip_box_outline,
            title = R.string.zipalign,
            summary = R.string.zipalign_summary,
            key = "alignZip",
        },
        {
            --ZipAlign工具
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_zip_box_outline,
            title = R.string.zipalign_tool,
            --summary=R.string.zipalign_summary;
            key = ZipAlignToolHelper.key,
            items = ZipAlignToolHelper.items,
            action = "singleChoose",
        },
        {
            --构建工具
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_zip_box_outline,
            title = "构建工具 Building tool",
            --summary=R.string.zipalign_summary;
            key = "buildingTools",
            items = { "Terminal-Gradle (Recommend)", "AIDE", "AndroidIDE" },
            action = "singleChoose",
            enabled = false,
        },
        {
            --Gradle 程序路径
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_folder_cog_outline,
            title = "Gradle程序路径 Gradle binary path",
            key = "gradle_path",
            summary = getSharedData("gradle_path"),
            action = "editString",
            --hint="";
            helperText = R.string.projects_paths_summary,
            allowNull = false,
            enabled = false,
        },

    },
    {
        --项目
        SettingsLayUtil.TITLE,
        title = R.string.project,
        key = "project",
        {
            --Jesse205库支持
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_tooltip_minus_outline,
            title = R.string.settings_support_Jesse205Library,
            key = "jesse205Lib_support",
            summary = R.string.settings_support_Jesse205Library_summary,
        },
        {
            --AndroidX支持
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_tooltip_minus_outline,
            title = R.string.settings_support_androidx,
            key = "androidX_support",
            summary = R.string.settings_support_androidx_summary,
        },
        {
            --工程路径，多路径
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_folder_cog_outline,
            title = R.string.projects_paths,
            key = "projectsDirs",
            summary = getSharedData("projectsDirs"),
            action = "editString",
            hint = R.string.projects_paths,
            helperText = R.string.projects_paths_summary,
            allowNull = false,
        },
        {
            --SDK 管理
            SettingsLayUtil.ITEM_NOSUMMARY,
            icon = R.drawable.ic_puzzle_outline,
            title = "SDK 管理 SDK manager",
            key = "sdk_manager",
            newPage = true,
        },
    },

    {
        --插件
        SettingsLayUtil.TITLE,
        title = R.string.plugins,
        key = "plugins",

    },

    {
        --编辑器
        SettingsLayUtil.TITLE,
        title = R.string.editor,
        key = "editor",
        {
            --显示空白字符
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_keyboard_space,
            title = R.string.settings_editor_showBlankChars,
            key = "editor_showBlankChars",
            summary = R.string.settings_editor_showBlankChars_summary,
        },
        {
            --自动换行
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_wrap,
            title = R.string.settings_editor_wordwrap,
            key = "editor_wordwrap",
        },

        {
            --放大镜
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_magnify,
            title = R.string.settings_editor_magnify,
            key = "editor_magnify",
            summary = R.string.settings_editor_magnify_summary,
        },
        {
            --符号栏
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_symbol,
            title = R.string.settings_editor_symbolNar,
            key = "editor_symbolBar",
        },
        {
            --字体
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_format_font,
            title = R.string.font,
            key = "editor_font",
            items = { "Default", "JetBrains Mono", "Cascadia Code", "System UI", "Serif" },
            action = "singleChoose",
        },
        {
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_file_eye_outline,
            title = R.string.settings_editor_previewButton,
            key = "editor_previewButton",
        },
    },


    {
        --标签栏
        SettingsLayUtil.TITLE,
        title = R.string.tab,
        key = "tab",
        {
            --标签栏图标，
            SettingsLayUtil.ITEM_SWITCH_NOSUMMARY,
            icon = R.drawable.ic_file_eye_outline,
            title = R.string.settings_tab_icon,
            key = "tab_icon",
        },
    },
    {
        --终端
        SettingsLayUtil.TITLE,
        title = "终端 Terminal ",
        key = "terminal",

        {
            --终端管理
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_folder_cog_outline,
            title = "终端管理 Terminal manager",
            key = "terminal_manager",
            summary = getSharedData("terminal_manager"),
            enabled = false,
        },

    },

    {
        --版本控制
        SettingsLayUtil.TITLE,
        title = "版本控制 Version control",
        key = "versionControl",
        {
            --Git 程序路径
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_folder_cog_outline,
            title = "Git 程序路径 Git binary path",
            key = "git_path",
            summary = getSharedData("git_path"),
            action = "editString",
            --hint="";
            helperText = R.string.projects_paths_summary,
            allowNull = false,
            enabled = false,
        },
        {
            --自动备份
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_file_clock_outline,
            title = R.string.settings_editor_automaticallyBackupOriginalFiles,
            summary = R.string.settings_editor_automaticallyBackupOriginalFiles_summary,
            key = "editor_autoBackupOriginalFiles",
            enabled = false,
        },

    },
    {
        --高级
        SettingsLayUtil.TITLE,
        title = "高级 Advanced",
        key = "advanced",
        {
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_database_outline,
            title = "Use SAF(Storage Access Framework)",
            summary =
            "使用SAF会导致文件读取变慢、文件夹加载迟缓、调试工程需要逐个授权的情况\nUsing SAF will cause slow file reading, slow folder loading, and the need to be authorized one by one.",
            key = "useSAF",
            checked = false,
            enabled = false,
        },
        {
            --快捷键设置
            SettingsLayUtil.ITEM_NOSUMMARY,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "快捷键设置 Shortcut key setting",
            key = "shortcut_key_setting",
            newPage = true,
            enabled = false,
        },
    },
    {
        --远程
        SettingsLayUtil.TITLE,
        title = "远程 Remote",
        key = "remote",
        {
            --激活 Edde 互联
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "激活 Edde 互联",
            summary =
            "激活 Edde 互联，使您在您的设备之间无缝编辑或调试项目\nActivate Edde Interconnect to enable you to seamlessly edit or debug projects between your devices.",
            key = "remote_eddeInterconnection",
            newPage = true,
            enabled = false,
        },
        {
            --VS Code 插件支持
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "VS Code 插件支持",
            summary =
            "用于开启 Aide Lua for VS Code 插件完整特性\nUsed to enable the complete features of Aide Lua for VS Code plug-in.",
            key = "remote_aideluaPluginSupport",
            newPage = true,
            enabled = false,
        },
        {
            --远程项目管理
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "远程项目管理 Remote projects manager",
            summary = "连接网络上的文件夹作为工程目录\nConnect a folder on the network as a project directory.",
            key = "remote_projectsManager",
            newPage = true,
            enabled = false,
        },
        {
            --远程设备
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_tshirt_crew_outline,
            title = "设备管理 Devices manager",
            summary = "连接 USB 或者网络上的 Android 设备\nConnect USB or Android device on the network.",
            key = "remote_devicesManager",
            newPage = true,
            enabled = false,
        },
    },

    {
        --软件
        SettingsLayUtil.TITLE,
        title = R.string.jesse205_app,
        key = "app",
        --[[
  {
    SettingsLayUtil.ITEM_SWITCH;
    icon=R.drawable.ic_database_outline;
    title="Use SAF(Storage Access Framework)";
    summary="使用SAF会导致文件读取变慢、文件夹加载迟缓、调试工程需要逐个授权的情况\nUsing SAF will cause slow file reading, slow folder loading, and the need to be authorized one by one.";
    key="useSAF";
    checked=false;
    enabled=false;
    switchEnabled=false;
  };]]
        {
            SettingsLayUtil.ITEM_SWITCH,
            icon = R.drawable.ic_database_outline,
            title = "防沉迷模式",
            summary = "限制仅在周末 12:00 到 13:00 使用本APP，超时将强制停止，且不会保存当前数据。如果您想关闭，你可以修改时间到允许使用的时候，然后关闭此开关。",
            key = "antiAddictionMode",
        },
        --[[
  {--工程路径
    SettingsLayUtil.ITEM;
    icon=R.drawable.ic_folder_cog_outline;
    title=R.string.projects_path;
    key="projectsDir";
    summary=getSharedData("projectsDir");
    action="editString";
    hint=R.string.projects_path;
    --helperText=R.string.settings_needRestart;
    allowNull=false;
  };
]]
        {
            SettingsLayUtil.ITEM,
            icon = R.drawable.ic_information_outline,
            title = R.string.jesse205_about,
            summary = formatResStr(R.string.jesse205_nowVersion_full, { BuildConfig.VERSION_NAME,
                BuildConfig.VERSION_CODE }),
            key = "about",
            newPage = true,
        },
    },
}
