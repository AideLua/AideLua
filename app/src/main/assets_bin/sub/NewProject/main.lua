require "import"
import "jesse205"
local normalkeys=jesse205.normalkeys
normalkeys.templateMap=true
normalkeys.pageConfigsList=true
normalkeys.nowPageConfig=true

import "androidx.viewpager.widget.ViewPager"
import "androidx.viewpager.widget.PagerAdapter"
import "androidx.appcompat.app.ActionBar$TabListener"
import "com.google.android.material.chip.ChipGroup"
import "com.google.android.material.chip.Chip"
import "com.google.android.material.tabs.TabLayout"

import "NewProjectUtil2"
import "NewProjectManager"

PluginsUtil.setActivityName("newproject")


templateMap={}--存放大模板的列表
pageConfigsList={}


activity.setTitle(R.string.project_create)
activity.setContentView(loadlayout2("layouts.layout"))
actionBar.setDisplayHomeAsUpEnabled(true)
--actionBar.setSubtitle(templateType.." "..templateList[templateType].baseVer)

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
  if not(nowPageConfig) then
    return
  end
  if nowPageConfig.checkAppConfig then
    local ids=nowPageConfig.ids
    local appName=ids.appNameEdit.text
    local packageName=ids.packageNameEdit.text
    local appNameLay=ids.appNameLay
    local packageNameLay=ids.packageNameLay
    if NewProjectManager.checkAppConfigError(appName,packageName,appNameLay,packageNameLay,nowPageConfig) then
      return
    end
  end

  local keys,formatList,unzipList=NewProjectManager.buildConfig(nowPageConfig)

  if nowPageConfig.onCreativePrj then
    nowPageConfig.onCreativePrj(nowPageConfig.ids,nowPageConfig,keys,formatList,unzipList)
  end

end
--templateType=getSharedData("templateType")

NewProjectManager.loadTemplate(NewProjectUtil2.TEMPLATES_DIR_PATH)
PluginsUtil.callElevents("onLoadTemplateConfig", templateMap,pageConfigsList)



local pagePosition=getSharedData("newProject_pagePosition") or 0
nowPageConfig=pageConfigsList[pagePosition+1]
if not(nowPageConfig) then
  pagePosition=0
  setSharedData("newProject_pagePosition",pagePosition)
  nowPageConfig=pageConfigsList[pagePosition+1]
end

adapter=PagerAdapter({
  getCount=function()
    return int(table.size(pageConfigsList))
  end,
  instantiateItem=function(container,position)
    local config=pageConfigsList[position+1]
    local templateConfig=config.templateConfig
    --[[
    local templateConfig=templateMap[config.templateType or "default"]
    config.templateConfig=templateConfig]]
    if config then
      local view=config.mainLayout
      if not(view) then
        local ids={}
        if config.useLoadlayout2 then
          view=loadlayout2(config.layout,ids)
         else
          view=loadlayout(config.layout,ids)
        end
        config.ids=ids
        --[[
      if config.templateDirPath then
        config.templateDirPath=rel2AbsPath(config.templateDirPath,NewProjectUtil2.TEMPLATES_DIR_PATH)
      end]]
        if config.onInit then
          local success,message=pcall(config.onInit,ids,config)
          if not(success) then
            showErrorDialog("Initialization error",message)
          end
        end
        if config.checkAppConfig then
          local keys=templateConfig.keys
          local appNameEdit=ids.appNameEdit
          local packageNameEdit=ids.packageNameEdit
          appNameEdit.text=keys.appName
          packageNameEdit.text=keys.appPackageName
          appNameEdit.addTextChangedListener({
            onTextChanged=function(text,start,before,count)
              NewProjectManager.checkAppName(tostring(text),ids.appNameLay,config)
              if position==pagePosition then
                NewProjectManager.refreshCreateEnabled(config,createButton)
              end
            end
          })
          packageNameEdit.addTextChangedListener({
            onTextChanged=function(text,start,before,count)
              NewProjectManager.checkPackageName(tostring(text),ids.packageNameLay,config)
              if position==pagePosition then
                NewProjectManager.refreshCreateEnabled(config,createButton)
              end
            end
          })
        end
        config.mainLayout=view
      end
      container.addView(view)
      return view
     else
      return View(activity)
    end
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
    local config=pageConfigsList[position+1]
    if config then
      return config.name
    end
  end
})

NewProjectManager.refreshCreateEnabled(nowPageConfig,createButton)

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
      nowPageConfig=pageConfigsList[newPagePosition+1]
      if not(nowPageConfig) then
        nowPageConfig=pageConfigsList[1]
      end
      NewProjectManager.refreshCreateEnabled(nowPageConfig,createButton)
      if nowPageConfig.onSelected then
        nowPageConfig.onSelected(nowPageConfig.ids,nowPageConfig)
      end
    end

  end,
  onPageSelected=function(position)
  end,
  onPageScrollStateChanged=function(state)

  end
})


--[[
function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  
})

onConfigurationChanged(activity.getResources().getConfiguration())

]]