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

function onCreateOptionsMenu(menu)
  helpMenu=menu.add(R.string.jesse205_getHelp)
  helpMenu.setIcon(R.drawable.ic_help_circle_outline)
  helpMenu.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
end

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
   elseif item==helpMenu then
    openUrl(DOCS_URL.."function/newproject.html")
  end
end

--v5.1.1+
---滚动监听，用于打开和关闭标题栏阴影
function onScrollListenerForActionBarElevation(pageConfig,state)
  AnimationHelper.onScrollListenerForActionBarElevation(topCard,state)
  pageConfig.showElevation=state
end

function onDestroy()
  NewProjectManager.onDestroy()
  PluginsUtil.callElevents("onDestroy")
end


noButton.onClick=function()--取消按钮
  activity.finish()
end

createButton.onClick=function(view)--新建按钮
  if not(nowPageConfig) then
    return
  end
  local pageConfig=nowPageConfig
  local prjsPaths=NewProjectUtil2.PRJS_PATHS
  local savedPrjsPath=getSharedData("projectsDir")
  prjsPaths[-1]=savedPrjsPath
  local choice=(table.find(prjsPaths,savedPrjsPath) or 0)-1--因为choice是java索引，所以要减去1

  MaterialAlertDialogBuilder(activity)
  .setTitle(R.string.projects_path_select)
  .setSingleChoiceItems(prjsPaths,choice,function(dialogInterface,index)
    choice=index
    setSharedData("projectsDir",prjsPaths[index+1])
  end)
  .setPositiveButton(android.R.string.ok,function()
    local path=prjsPaths[choice+1]
    if path then
      local appName,packageName
      if pageConfig.checkAppConfig then
        local ids=pageConfig.ids
        appName=ids.appNameEdit.text
        packageName=ids.packageNameEdit.text
        local appNameLay=ids.appNameLay
        local packageNameLay=ids.packageNameLay
        if NewProjectManager.checkAppConfigError(appName,packageName,appNameLay,packageNameLay,pageConfig,path) then
          return
        end
      end
      --v5.1.1添加path
      local keys,formatList,unzipList=NewProjectManager.buildConfig(pageConfig,appName,packageName,path)
      if pageConfig.onCreatePrj then
        pageConfig.onCreatePrj(pageConfig.ids,pageConfig,keys,formatList,unzipList,path)
      end
    end
  end)
  .setNegativeButton(android.R.string.cancel,nil)
  .show()
end

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
    local positionOffsetX2=positionOffset*2
    local newPagePosition
    if positionOffset<0.5 then
      bottomCardChild.setTranslationX(-positionOffsetX2*math.dp2int(24))
      bottomCardChild.setAlpha(1-positionOffsetX2)
      newPagePosition=position
     else
      bottomCardChild.setTranslationX((2-positionOffsetX2)*math.dp2int(24))
      bottomCardChild.setAlpha(positionOffsetX2-1)
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
    local actionBarElevation=res(res.id.attr.actionBarTheme).dimension.attr.elevation
    if positionOffset>0 then
      if toboolean(pageConfigsList[position+1].showElevation)~=toboolean(pageConfigsList[position+2].showElevation) then
        if pageConfigsList[position+1].showElevation then
          topCard.setElevation(actionBarElevation*(1-positionOffset))
         else
          topCard.setElevation(actionBarElevation*positionOffset)
        end
      end
     else
      if pageConfigsList[position+1].showElevation then
        topCard.setElevation(actionBarElevation)
       else
        topCard.setElevation(0)
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


screenConfigDecoder=ScreenUtil.ScreenConfigDecoder({
  
})

onConfigurationChanged(activity.getResources().getConfiguration())

]]