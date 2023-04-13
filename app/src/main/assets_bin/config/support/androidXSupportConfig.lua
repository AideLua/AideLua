return {
    editor = {
        LuaEditor = {
            keywordsList = {

            },
        }
    },
    fileTemplates = {
        {
            name = "Lua 活动 (Activity)（AndroidX）",
            enName = "Lua Activity (AndroidX)",
            id = "luaactivity_android",
            fileExtension = "lua",
            enabledVar = "oldAndroidXSupport",
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

]],
        },
    }
}
