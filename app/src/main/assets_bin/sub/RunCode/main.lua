--require "import"
--import "jesse205"
activity.getDecorView().setSystemUiVisibility(0)
local R=luajava.bindClass(activity.getPackageName()..".R")
activity.setTheme(R.style.Theme_AppCompat_DayNight)
activity.setTitle(R.string.runCode)
activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

local code,codeType=...
if code then
  if codeType=="lua" or not(codeType) then
    activity.doString(code,_G)
  end
end
