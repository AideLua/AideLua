require "import"
import "Jesse205"

import "com.Jesse205.layout.util.SettingsLayUtil"
import "com.Jesse205.layout.innocentlayout.RecyclerViewLayout"
import "com.Jesse205.app.dialog.EditDialogBuilder"

PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)

import "settings"

activity.setTitle(R.string.settings)
activity.setContentView(loadlayout(RecyclerViewLayout))

actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)

oldTheme=ThemeUtil.getAppTheme()
scroll=...

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onResume()
  if oldTheme~=ThemeUtil.getAppTheme() then
    activity.recreate()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


function reloadActivity(closeView)
  local aRanim=android.R.anim
  local pos,scroll
  if recyclerView then
    closeView.setEnabled(false)
    pos=layoutManager.findFirstVisibleItemPositions({0})[0]
    scroll=recyclerView.getChildAt(0).getTop()
  end
  newActivity("main",aRanim.fade_in,aRanim.fade_out,{{pos,scroll}})
  activity.finish()
end

function onItemClick(view,views,key,data)
  if key=="theme_picker" then
    newSubActivity("ThemePicker")
   elseif key=="about" then
    newSubActivity("About")
   elseif key=="theme_darkactionbar" then
    reloadActivity(view)
   else
    if data.action=="editString" then
      EditDialogBuilder.settingDialog(adp,views,key,data)
    end
  end
end

adp=SettingsLayUtil.newAdapter(settings,onItemClick)
recyclerView.setAdapter(adp)
layoutManager=StaggeredGridLayoutManager(1,StaggeredGridLayoutManager.VERTICAL)
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy)
  end
})
recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
  onGlobalLayout=function()
    if activity.isFinishing() then
      return
    end
    MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0)
  end
})


if scroll then
  scroll=luajava.astable(scroll)
  local pos=scroll[1] or 0
  recyclerView.scrollToPosition(pos)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  listViews={recyclerView},
})

onConfigurationChanged(activity.getResources().getConfiguration())

