require "import"
import "jesse205"
import "androidx.viewpager.widget.ViewPager"
import "androidx.viewpager.widget.PagerAdapter"
import "androidx.appcompat.app.ActionBar$TabListener"
import "com.google.android.material.chip.ChipGroup"
import "com.google.android.material.chip.Chip"
import "com.google.android.material.tabs.TabLayout"
import "projectTemplateConfig"

PluginsUtil.setActivityName("newproject")
TEMPLATES_DIR_PATH=activity.getLuaDir("../../templates")--模板路径
local nowConfig
activity.setTitle(R.string.project_create)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

noButton.onClick=function()--取消按钮
  activity.finish()
end

creativeButton.onClick=function()--新建按钮
  if nowConfig and nowConfig.onCreativePrj then
    nowConfig.onCreativePrj(nowConfig.ids,nowConfig)
  end
end
--templateType=getSharedData("templateType")

PluginsUtil.callElevents("onLoadTemplateConfig", projectTemplateConfig)

adapter=PagerAdapter({
  getCount=function()
    return int(table.size(projectTemplateConfig))
  end,
  instantiateItem=function(container,position)
    local config=projectTemplateConfig[position+1]
    local view
    local ids={}
    if config.useLoadlayout2 then
      view=loadlayout2(config.layout,ids)
     else
      view=loadlayout(config.layout,ids)
    end
    config.ids=ids
    if config.templateDirPath then
      config.templateDirPath=rel2AbsPath(config.templateDirPath,TEMPLATES_DIR_PATH)
    end
    if config.onInit then
      local success,message=pcall(config.onInit,ids,config)
      if not(success) then
        showErrorDialog("Initialization error",message)
      end
    end
    container.addView(view)
    return view
  end,
  destroyItem=function(container,position,object)
    container.removeView(object)
  end,
  isViewFromObject=function(view,object)
    return view==object
  end,
  getPageWidth=function(position)
    return Float(1)
  end,
  getPageTitle=function(position)
    local config=projectTemplateConfig[position+1]
    if config then
      return config.name
    end
  end
})
viewPager.setAdapter(adapter)
tabLayout.setupWithViewPager(viewPager)

viewPager.setOnPageChangeListener({
  onPageScrolled=function(position,positionOffset,positionOffsetPixels)
    if positionOffset>0.5 then
      bottomCardChild.setTranslationX(-(positionOffset*2-2)*math.dp2int(24))
     else
      bottomCardChild.setTranslationX(-(positionOffset*2)*math.dp2int(24))
    end
  end,
  onPageSelected=function(position)
    nowConfig=projectTemplateConfig[position+1]
  end,
  onPageScrollStateChanged=function(state)

  end
})
--print(projectTemplateConfig)



--[[
function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  
})

onConfigurationChanged(activity.getResources().getConfiguration())

]]