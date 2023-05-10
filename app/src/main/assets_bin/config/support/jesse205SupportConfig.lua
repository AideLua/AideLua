local FLAG_JESSE205_SUPPORT_STATE = 1
local initEditorFlag = FLAG_JESSE205_SUPPORT_STATE

return {
    editor = {
        LuaEditor = {
            initEditorFlag = initEditorFlag,
            keywordsList = {
                jesse205Keywords = {
                    "newActivity", "getSupportActionBar", "getSharedData", "setSharedData",
                    "getString", "getPackageName", "getColorStateList", "getNetErrorStr",

                    --一些标识
                    "initApp", "notLoadTheme", "useCustomAppToolbar",
                    "resources", "application", "inputMethodService", "actionBar",
                    "notLoadTheme", "darkStatusBar", "darkNavigationBar",
                    "window", "safeModeEnable", "notSafeModeEnable", "decorView",

                    --一些函数
                    "theme", "formatResStr", "autoSetToolTip",
                    "showLoadingDia", "closeLoadingDia", "getNowLoadingDia",
                    "showErrorDialog", "toboolean", "rel2AbsPath", "copyText",
                    "newSubActivity", "isDarkColor", "openInBrowser", "openUrl",
                    "loadlayout2", "showSimpleDialog", "getLocalLangObj",
                    "newLayoutTransition",

                    --一些模块/类
                    "AppPath", "ThemeUtil", "EditDialogBuilder", "ImageDialogBuilder",
                    "MyToast", "AutoToolbarLayout", "PermissionUtil", "MyStyleUtil",
                    "AutoCollapsingToolbarLayout", "SettingsLayUtil", "jesse205",
                    "StyleWidget", "ScreenUtil", "FileUriUtil", "ClearContentHelper",
                    "MyAnimationUtil", "FileUtil", "AnimationHelper",

                    --自定义View
                    "MyTextInputLayout", "MyCardTitleEditLayout", "MyTitleEditLayout",
                    "MyEditDialogLayout", "MyTipLayout", "MySearchBar",
                    "MyRecyclerView",

                    --适配器
                    "MyLuaMultiAdapter", "MyLuaAdapter", "LuaCustRecyclerAdapter",
                    "LuaCustRecyclerHolder", "AdapterCreator",

                    table.unpack(StyleWidget.types),
                },
            },
        }
    },
    fileTemplates = {
        {
            name = "Lua 活动 (Activity)（Jesse205）",
            enName = "Lua Activity (Jesse205)",
            id = "luaactivity_jesse205",
            fileExtension = "lua",
            enabledVar = "oldJesse205Support",
            content = [[require "import"
import "jesse205"

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


screenConfigDecoder=ScreenUtil.ScreenConfigDecoder({

})

onConfigurationChanged(resources.getConfiguration())

]],
        },

    }

}
