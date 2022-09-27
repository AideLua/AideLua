require "import"
import "jesse205"
import "androidx.viewpager.widget.ViewPager"
import "androidx.viewpager.widget.PagerAdapter"
import "androidx.appcompat.app.ActionBar$TabListener"
import "com.google.android.material.chip.ChipGroup"
import "com.google.android.material.chip.Chip"
import "com.google.android.material.tabs.TabLayout"

import "NewProjectUtil2"
import "NewProjectUtil"
import "projectTemplateConfig"

PluginsUtil.setActivityName("newproject")
--[[
for index=1,#projectTemplateConfig do
  projectTemplateConfig[index].index=index
end]]
defaultPrjConfig=NewProjectUtil2.readConfig("default.lua")

local pagePosition=getSharedData("newProject_pagePosition") or 0
local nowConfig=projectTemplateConfig[pagePosition+1]

activity.setTitle(R.string.project_create)
activity.setContentView(loadlayout2("layouts.layout"))
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

createButton.onClick=function(view)--新建按钮
  if not(nowConfig) then
    return
  end
  if nowConfig.checkAppConfig then
    local ids=nowConfig.ids

    local appName=ids.appNameEdit.text
    local packageName=ids.packageNameEdit.text

    local appNameLay=ids.appNameLay
    local packageNameLay=ids.packageNameLay

    if NewProjectUtil.checkAppConfigError(appName,packageName,appNameLay,packageNameLay,nowConfig,view) then
      return
    end
  end
  --NewProjectUtil2.readConfig(path)
  local keys=NewProjectUtil.buildkeys(defaultPrjConfig,nowConfig)

  if nowConfig.onCreativePrj then
    nowConfig.onCreativePrj(nowConfig.ids,nowConfig,keys)
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
      config.templateDirPath=rel2AbsPath(config.templateDirPath,NewProjectUtil2.TEMPLATES_DIR_PATH)
    end
    if config.onInit then
      local success,message=pcall(config.onInit,ids,config)
      if not(success) then
        showErrorDialog("Initialization error",message)
      end
    end
    if config.checkAppConfig then
      local appNameEdit=ids.appNameEdit
      local packageNameEdit=ids.packageNameEdit
      appNameEdit.text=defaultPrjConfig.appName
      packageNameEdit.text=defaultPrjConfig.appPackageName
      appNameEdit.addTextChangedListener({
        onTextChanged=function(text,start,before,count)
          NewProjectUtil.checkAppName(tostring(text),ids.appNameLay,config)
          if position==pagePosition then
            NewProjectUtil.refreshCreateEnabled(config,createButton)
          end
        end
      })
      packageNameEdit.addTextChangedListener({
        onTextChanged=function(text,start,before,count)
          NewProjectUtil.checkPackageName(tostring(text),ids.packageNameLay,config)
          if position==pagePosition then
            NewProjectUtil.refreshCreateEnabled(config,createButton)
          end
        end
      })
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
    return float(1)
  end,
  getPageTitle=function(position)
    local config=projectTemplateConfig[position+1]
    if config then
      return config.name
    end
  end
})

NewProjectUtil.refreshCreateEnabled(nowConfig,createButton)

viewPager.setAdapter(adapter)
tabLayout.setupWithViewPager(viewPager)
viewPager.setCurrentItem(pagePosition)
viewPager.setOnPageChangeListener({
  onPageScrolled=function(position,positionOffset,positionOffsetPixels)
    local newPagePosition
    if positionOffset<0.5 then
      bottomCardChild.setTranslationX(-(positionOffset*2)*math.dp2int(24))
      --bottomCardChild.setTranslationX(-positionOffsetPixels)
      newPagePosition=position
     else
      bottomCardChild.setTranslationX(-(positionOffset*2-2)*math.dp2int(24))
      --bottomCardChild.setTranslationX(activity.getWidth()-positionOffsetPixels)
      newPagePosition=position+1
    end
    if pagePosition~=newPagePosition then
      pagePosition=newPagePosition
      setSharedData("newProject_pagePosition",newPagePosition)
      nowConfig=projectTemplateConfig[newPagePosition+1]

      NewProjectUtil.refreshCreateEnabled(nowConfig,createButton)
      if nowConfig.onSelected then
        nowConfig.onSelected(nowConfig.ids,nowConfig)
      end
    end

  end,
  onPageSelected=function(position)
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