require "import"
import "Jesse205"
import "android.text.SpannableString"
import "android.text.style.ForegroundColorSpan"
import "net.lingala.zip4j.ZipFile"
import "com.Jesse205.layout.util.SettingsLayUtil"
import "com.Jesse205.layout.innocentlayout.RecyclerViewLayout"
import "settings"
import "SettingsLayUtilPro"
import "PluginsManagerUtil"

--appPluginsDir=AppPath.AppShareDir.."/plugins"
--AppPath.AppPluginsDir=appPluginsDir
PLUGINS_DIR=File(PluginsUtil.PLUGINS_PATH)

local PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)
local versionCode=PackInfo.versionCode

activity.setTitle(R.string.plugins_manager)
activity.setContentView(loadlayout2(RecyclerViewLayout))
actionBar.setDisplayHomeAsUpEnabled(true)

REQUEST_INSTALLPLUGIN=10
settings2={}

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onActivityResult(requestCode,resultCode,data)
  if resultCode==Activity.RESULT_OK then
    if requestCode==REQUEST_INSTALLPLUGIN then
      PluginsManagerUtil.installByUri(data.getData(),function(state)
        if state=="success" then
          MyToast(R.string.install_success)
          refresh()
         elseif state=="failed" then
          MyToast(R.string.install_failed)
        end
      end)
    end
  end
end

function onResume()
  refresh()
end

function onItemClick(view,views,key,data)
  if key=="plugin_item" then
    --local config=data.config
    local newState=data.checked
    if data.enableVer then
      if newState then
        PluginsUtil.setEnabled(data.dirName,versionCode)
       else
        PluginsUtil.setEnabled(data.dirName,false)
      end
     else
      PluginsUtil.setEnabled(data.dirName,newState)
    end
   elseif key=="install_plugin" then
    local intent=Intent(Intent.ACTION_GET_CONTENT)
    intent.setType("*/*")
    intent.addCategory(Intent.CATEGORY_OPENABLE)
    activity.startActivityForResult(intent, REQUEST_INSTALLPLUGIN)
  end
end

function onItemLongClick(view,views,key,data)
  if key=="plugin_item" then
    local config=data.config
    local pop=PopupMenu(activity,view)
    local menu=pop.Menu
    menu.add(R.string.plugins_uninstall).onMenuItemClick=function()
      PluginsManagerUtil.uninstall(data.path,config,function(state)
        if state=="success" then
          MyToast(R.string.uninstall_success)
          refresh()
         elseif state=="failed" then
          MyToast(R.string.uninstall_failed)
        end
      end)
    end
    pop.show()
  end
end

function addSummaryTextLine(summarySpanIndex,color,oldSummary,summary)
  local newSummary=oldSummary.."\n"..summary
  table.insert(summarySpanIndex,{theme.color[color] or color,utf8.len(oldSummary)+1,utf8.len(newSummary)})
  return newSummary
end

function refresh()
  table.clear(settings2)
  for index,content in ipairs(settings) do
    table.insert(settings2,content)
  end
  if PLUGINS_DIR.isDirectory() then--存在插件文件夹
    local fileList=PLUGINS_DIR.listFiles()
    for index=0,#fileList-1 do
      local file=fileList[index]
      if file.isDirectory() then
        local title,config,spannableSummary
        local summary=""
        local summarySpanIndex={}
        local enableVer=false
        local checked=false
        local switchEnabled=true
        local path=file.getPath()
        local dirName=file.getName()
        local initPath=path.."/init.lua"
        local icon=path.."/icon.png"
        if File(initPath).isFile() then
          config=getConfigFromFile(initPath)--init.lua内容
          if config.appname then
            title=config.appname
           else
            title=dirName
          end

          --版本号
          local pluginVersionName=config.appver
          local pluginVersionCode=config.appcode
          if pluginVersionName then
            if versionCode then
              summary=formatResStr(R.string.plugins_info_version,{("%s (%s)"):format(pluginVersionName,pluginVersionCode)})
             else
              summary=formatResStr(R.string.plugins_info_version,{pluginVersionName})
            end
           elseif pluginVersionCode then
            summary=formatResStr(R.string.plugins_info_version,{pluginVersionCode})
           else
            summary=formatResStr(R.string.plugins_info_version,{getString(R.string.android.R.string.unknownName)})
          end

          --包名
          local packageName=config.packagename
          if packageName then
            summary=summary.."\n"..formatResStr(R.string.plugins_info_packageName,{packageName})
            if packageName~=dirName then
              summary=summary.."\n"..formatResStr(R.string.plugins_info_folderName,{dirName})
              summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,getString(R.string.plugins_warning_keepPFSame))
            end
           else
            summary=summary.."\n"..formatResStr(R.string.plugins_info_folderName,{dirName})
            summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,getString(R.string.plugins_warning_addPackageName))
          end

          if config.supported then
            if not(table.find(config.supported,apptype)) then
              summary=addSummaryTextLine(summarySpanIndex,"Red",summary,getString(R.string.plugins_error_unsupported))
            end
           else
            summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,getString(R.string.plugins_warning_supported))
          end

          local minVerCode=config.minemastercode
          local targetVerCode=config.targetmastercode
          if minVerCode==nil or minVerCode<=versionCode then--版本号在允许启用模块的范围之内
            checked=PluginsUtil.getEnabled(dirName)
            if targetVerCode and targetVerCode<versionCode then
              checked=checked==versionCode
              enableVer=true
              summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,getString(R.string.plugins_warning_update))
            end
           else
            switchEnabled=false
            summary=addSummaryTextLine(summarySpanIndex,"Red",summary,getString(R.string.plugins_error_update_app))
          end
         else--不存在init.lua，是非法插件
          config={}
          switchEnabled=false
          title=dirName
          summary=getString(R.string.plugins_error)
          table.insert(summarySpanIndex,{theme.color.Red,0,utf8.len(summary)})
        end

        --处理文字
        if #summarySpanIndex~=0 then
          spannableSummary=SpannableString(summary)
          summary=nil
          for index,content in ipairs(summarySpanIndex) do
            spannableSummary.setSpan(ForegroundColorSpan(content[1]),content[2],content[3],0)
          end
        end
        if not(File(icon).isFile()) then
          icon=R.drawable.ic_puzzle_icon
          --icon=android.R.drawable.sym_def_app_icon
        end
        table.insert(settings2,{
          SettingsLayUtil.ITEM_AVATAR_SWITCH;
          icon=icon,
          title=title,
          summary=summary or spannableSummary,
          key="plugin_item",
          checked=toboolean(checked),
          config=config,
          switchEnabled=switchEnabled,
          enableVer=enableVer,
          dirName=dirName,
          path=path,
        })
      end
    end
  end
  table.insert(settings2,{
    SettingsLayUtil.ITEM_ONLYSUMMARY;
    summary=R.string.plugins_reboot,
    clickable=false
  })
  adapter.notifyDataSetChanged()
end

adapter=SettingsLayUtil.newAdapter(settings2,onItemClick,onItemLongClick)
recyclerView.setAdapter(adapter)
layoutManager=LinearLayoutManager()
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
mainLay.onTouch=function(view,...)
  recyclerView.onTouchEvent(...)
end




mainLay.ViewTreeObserver
.addOnGlobalLayoutListener(ScreenFixUtil.LayoutListenersBuilder.listViews(mainLay,{recyclerView}))