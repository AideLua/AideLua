require "import"
import "Jesse205"
import "android.text.Html"
import "android.text.method.LinkMovementMethod"

local actionBar,data
activity.setTitle(R.string.Jesse205_htmlFileViewer)
activity.setContentView(loadlayout("layout",_ENV))
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)
data=...

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
  textView.setText(Html.fromHtml(io.open(path,"r"):read("*a")))
end

scrollView.onScrollChange=function(view,l,t,oldl,oldt)
  MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt)
end