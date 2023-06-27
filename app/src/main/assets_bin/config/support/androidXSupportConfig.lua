return {
    editor = {
        LuaEditor = {
            keywordsList = {}
        }
    },
    fileTemplates = {
        {
            name = "Lua 活动 (Activity)（AndroidX）",
            enName = "Lua Activity (AndroidX)",
            id = "luaactivity_android",
            extensionName = "lua",
            enabledKey = "oldAndroidXSupport",
            content = [[require "import"
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

]]
        },
        {
            name = "Lua 布局 (Layout)（AndroidX）",
            enName = "Lua Layout (AndroidX)",
            id = "lua_layout_androidx",
            extensionName = "aly",
            enabledKey = "oldAndroidXSupport",
            content = [[{
      CoordinatorLayout;
      layout_height="fill";
      layout_width="fill";
      id="mainLay";
      {
        TextView;
        gravity="center";
        text="Hello World";
        layout_height="fill";
        layout_width="fill";
      };
    }]],
        },

    }
}
