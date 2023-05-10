require "import"
import "jesse205"

activity.setTitle(R.string.jesse205_welcome)
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

onConfigurationChanged(activity.getResources().getConfiguration())

