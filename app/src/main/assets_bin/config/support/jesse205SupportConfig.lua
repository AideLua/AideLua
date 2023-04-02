local FLAG_JESSE205_SUPPORT_STATE=1
local initEditorFlag=FLAG_JESSE205_SUPPORT_STATE

return {
  editor={
    LuaEditor={
      initEditorFlag=initEditorFlag,
      keywordsList={
        jesse205Keywords={
          "newActivity","getSupportActionBar","getSharedData","setSharedData",
          "getString","getPackageName","getColorStateList","getNetErrorStr",

          --一些标识
          "initApp","notLoadTheme","useCustomAppToolbar",
          "resources","application","inputMethodService","actionBar",
          "notLoadTheme","darkStatusBar","darkNavigationBar",
          "window","safeModeEnable","notSafeModeEnable","decorView",

          --一些函数
          "theme","formatResStr","autoSetToolTip",
          "showLoadingDia","closeLoadingDia","getNowLoadingDia",
          "showErrorDialog","toboolean","rel2AbsPath","copyText",
          "newSubActivity","isDarkColor","openInBrowser","openUrl",
          "loadlayout2","showSimpleDialog","getLocalLangObj",
          "newLayoutTransition",

          --一些模块/类
          "AppPath","ThemeUtil","EditDialogBuilder","ImageDialogBuilder",
          "MyToast","AutoToolbarLayout","PermissionUtil","MyStyleUtil",
          "AutoCollapsingToolbarLayout","SettingsLayUtil","jesse205",
          "StyleWidget","ScreenFixUtil","FileUriUtil","ClearContentHelper",
          "MyAnimationUtil","FileUtil","AnimationHelper",

          --自定义View
          "MyTextInputLayout","MyCardTitleEditLayout","MyTitleEditLayout",
          "MyEditDialogLayout","MyTipLayout","MySearchBar",
          "MyRecyclerView",

          --适配器
          "MyLuaMultiAdapter","MyLuaAdapter","LuaCustRecyclerAdapter",
          "LuaCustRecyclerHolder","AdapterCreator",

          table.unpack(StyleWidget.types),
        },
      },
    }
  },
  fileTemplates={
    {
      name="Lua 活动 (Activity)（AndroidX）",
      enName="Lua Activity (AndroidX)",
      id="luaactivity_android",
      fileExtension="lua",
      enabledVar="oldAndroidXSupport",
      content=[[require "import"
--import "androidx"
import "androidx.appcompat.app.*"
import "androidx.appcompat.view.*"
import "androidx.appcompat.widget.*"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "androidx.coordinatorlayout.widget.CoordinatorLayout"

--activity.setTitle("{{ModuleName}}")
--activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

]],
    },
  }

}