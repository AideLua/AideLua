require "import"
import "Jesse205"

activity.setTitle(R.string.javaApiViewer)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true) 

searchWord=...
if searchWord then
  searchWord=tostring(searchWord)
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end




