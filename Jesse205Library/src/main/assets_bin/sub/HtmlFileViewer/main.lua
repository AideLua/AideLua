require "import"
import "jesse205"
import "android.text.Html"
import "com.onegravity.rteditor.RTEditorMovementMethod"

activity.setTitle(R.string.jesse205_htmlFileViewer)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)
local data=...

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  MyAnimationUtil.ScrollView.onScrollChange(scrollView,scrollView.getScrollX(),scrollView.getScrollY(),0,0)
end

if data.title then
  activity.setTitle(data.title)
end

local path=data.path
if path then
  local content=io.open(path,"r"):read("*a")
  if tostring(data.text)=="true" then
    textView.setText(content)
   else
    textView.setText(Html.fromHtml(content))
  end
end

scrollView.onScrollChange=function(view,l,t,oldl,oldt)
  MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt)
end