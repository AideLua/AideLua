require "import"
--import "androidx"
import "androidx.appcompat.app.*"
import "androidx.appcompat.view.*"
import "androidx.appcompat.widget.*"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "androidx.coordinatorlayout.widget.CoordinatorLayout"

--activity.setTitle("Aide Lua")
--activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)
prjPath,filePath=...

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

print("进入插件页面")
print("工程路径",prjPath)
print("文件路径",filePath)
