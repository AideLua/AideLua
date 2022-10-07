require "import"
import "jesse205"
import "android.widget.ListView"

local classStr=...
success,class=pcall(luajava.bindClass,classStr)
if not(success) then
  activity.result({R.string.javaApiViewer_notFindClass})
  return
end


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


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({

})

onConfigurationChanged(activity.getResources().getConfiguration())

