require "import"
import "Jesse205"
import "loadlayout2"
import "viewList"
layoutContent=require "defaultlayout"

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)
projectPath,filePath=...--传入的文件路径

activity.setLuaDir(projectPath)

if filePath and filePath:find("%.aly$") then
  xpcall(function()
    layoutContent=loadfile(filePath)()
  end,
  function()
    filePath=nil
  end)
 else
  filePath=nil
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

function refreshLayout()
  loadlayout2(layoutContent)
end






screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({

})

onConfigurationChanged(activity.getResources().getConfiguration())

