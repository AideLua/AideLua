RedirectHelper=require "RedirectHelper"
if RedirectHelper.toAndroidActivity(activity.getPackageName()..".PluginsManagerActivity") then
  return
end
require "import"
import "jesse205"
import "android.text.Spannable"
import "android.text.SpannableString"
import "android.text.style.ForegroundColorSpan"
import "androidx.appcompat.widget.Toolbar"
import "com.google.android.material.appbar.AppBarLayout"
import "net.lingala.zip4j.ZipFile"
import "com.jesse205.layout.util.SettingsLayUtil"
import "com.jesse205.layout.innocentlayout.RecyclerViewLayout"
import "settings"
import "SettingsLayUtilPro"
import "PluginsManagerUtil"
import "dialog.MarkdownReaderDialog"

--v5.1.2+
PluginsUtil.setActivityName("pluginsmanager")

PLUGINS_DIR=File(PluginsUtil.PLUGINS_PATH)

local PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)
local versionCode=PackInfo.versionCode

activity.setTitle(R.string.plugins_manager)
activity.setContentView(loadlayout2(RecyclerViewLayout))
actionBar.setDisplayHomeAsUpEnabled(true)

REQUEST_INSTALLPLUGIN=10
settings2={}

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
    openUrl(DOCS_URL.."plugin/")
  end
end

function onActivityResult(requestCode,resultCode,data)
  if resultCode==Activity.RESULT_OK then
    if requestCode==REQUEST_INSTALLPLUGIN then
      installPlugin(data.getData())
    end
  end
end

function onNewIntent(newIntent)
  local fileUri=newIntent.getData()
  if fileUri then
    installPlugin(fileUri)
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
    PluginsUtil.clearOpenedPluginPaths()
   elseif key=="install_plugin" then
    local intent=Intent(Intent.ACTION_GET_CONTENT)
    intent.setType("*/*")
    intent.addCategory(Intent.CATEGORY_OPENABLE)
    activity.startActivityForResult(intent, REQUEST_INSTALLPLUGIN)
   elseif key=="download_plugin" then
    openUrl(PAGE_URL.."plugins.html")
  end
end

function onItemInfoBtnClick(view)
  local data=view.tag
  local readmePath=data.path.."/README.md"
  if not File(readmePath).isFile() then
    return
  end
  MarkdownReaderDialog.init()
  MarkdownReaderDialog.load(readmePath)
  MarkdownReaderDialog.setTitle(data.title)
  MarkdownReaderDialog.show()
end

onItemInfoBtnClickListener=View.OnClickListener({onClick=onItemInfoBtnClick})

function onItemLongClick(view,views,key,data)
  recyclerView.tag._data=data
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
      if file.isDirectory() then--存在文件夹
        local title,loadedConfig,config,spannableSummary
        local summary=""
        local summarySpanIndex={}
        local enableVer=false
        local checked=false
        local switchEnabled=true
        local path=file.getPath()
        local dirName=file.getName()
        local initPath=path.."/init.lua"
        local icon=path.."/icon.png"
        local icon_night=path.."/icon-night.png"
        loadedConfig,config=pcall(getConfigFromFile,initPath)--init.lua内容
        if loadedConfig then--存在init.lua，是合法插件
          if config.appname then
            title=config.appname
           else
            title=dirName
          end
          local description=config.description
          if description and type(description)=="string" and description~="" then
            summary=config.description.."\n"
          end

          --版本号
          local pluginVersionName=config.appver
          local pluginVersionCode=config.appcode
          if pluginVersionName then
            if versionCode then
              summary=summary..formatResStr(R.string.plugins_info_version,{("%s (%s)"):format(pluginVersionName,pluginVersionCode)})
             else
              summary=summary..formatResStr(R.string.plugins_info_version,{pluginVersionName})
            end
           elseif pluginVersionCode then
            summary=summary..formatResStr(R.string.plugins_info_version,{pluginVersionCode})
           else
            summary=summary..formatResStr(R.string.plugins_info_version,{getString(R.string.android.R.string.unknownName)})
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

          checked=PluginsUtil.getEnabled(dirName)

          local supports=config.supported2
          if supports then--声明了受支持的APP
            local versionConfig=supports[apptype]
            if versionConfig then--此APP受支持
              local minVerCode = versionConfig.mincode
              local targetVerCode = versionConfig.targetcode
              if not(minVerCode) or minVerCode<=versionCode then--版本号在允许启用模块的范围之内
                if targetVerCode and targetVerCode<versionCode then--当前APP版本较高
                  checked=checked==versionCode
                  enableVer=true--启用版本判断
                  summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,getString(R.string.plugins_warning_update))
                end
               else--APP版本号太低
                switchEnabled=false
                summary=addSummaryTextLine(summarySpanIndex,"Red",summary,getString(R.string.plugins_error_update_app))
              end
             else--此APP不受支持
              summary=addSummaryTextLine(summarySpanIndex,"Red",summary,getString(R.string.plugins_error_unsupported))
            end
           elseif supports==nil then--没有声明受支持的APP
            summary=addSummaryTextLine(summarySpanIndex,"Orange",summary,getString(R.string.plugins_warning_supported))
          end

         else--不存在init.lua，是非法插件
          switchEnabled=false
          title=dirName
          summary=getString(R.string.plugins_error)
          table.insert(summarySpanIndex,{theme.color.Red,0,utf8.len(summary)})
          summary=summary.."\n"..config
          config={}
        end

        --处理文字
        if #summarySpanIndex~=0 then
          spannableSummary=SpannableString(summary)
          summary=nil
          for index,content in ipairs(summarySpanIndex) do
            --Spannable.SPAN_INCLUSIVE_INCLUSIVE
            spannableSummary.setSpan(ForegroundColorSpan(content[1]),content[2],content[3],Spannable.SPAN_INCLUSIVE_INCLUSIVE)
          end
        end
        if ThemeUtil.isNightMode() and File(icon_night).isFile() then
          icon=icon_night
        end
        if not(File(icon).isFile()) then
          icon=R.drawable.ic_puzzle_icon
        end
        table.insert(settings2,{
          (function()
            if config.smallicon then
              return SettingsLayUtil.ITEM_AVATAR_ICON_SWITCH
             else
              return SettingsLayUtil.ITEM_AVATAR_SWITCH
            end
          end)();
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
          contextMenuEbaled=true,
          hasReadme=File(path.."/README.md").isFile()
        })
      end
    end
  end

  --添加底部提示
  table.insert(settings2,{
    SettingsLayUtil.ITEM_ONLYSUMMARY;
    summary=R.string.plugins_reboot,
    clickable=false
  })
  adapter.notifyDataSetChanged()
end

function installPlugin(uri)
  PluginsManagerUtil.installByUri(uri,function(state)
    if state=="success" then
      MyToast(R.string.install_success)
      refresh()
     elseif state=="failed" then
      MyToast(R.string.install_failed)
    end
  end)
end

adapter=LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return SettingsLayUtil.adapterEvents.getItemCount(settings2)
  end,
  getItemViewType=function(position)
    return SettingsLayUtil.adapterEvents.getItemViewType(settings2,position)
  end,
  onCreateViewHolder=function(parent,viewType)
    local holder=SettingsLayUtil.adapterEvents.onCreateViewHolder(onItemClick,onItemLongClick,parent,viewType)
    local ids=holder.view.tag
    local infoBtnView=ids.infoBtnView
    if infoBtnView then
      local drawable=ThemeUtil.getRippleDrawable(res.color.attr.rippleColorPrimary,true)
      if Build.VERSION.SDK_INT>=23 then
        drawable.mutate().setRadius(math.dp2int(20))
      end
      infoBtnView.setBackground(drawable)
      infoBtnView.setOnClickListener(onItemInfoBtnClickListener)
    end
    return holder
  end,
  onBindViewHolder=function(holder,position)
    local data=settings2[position+1]
    local layoutView=holder.view
    local ids=layoutView.getTag()
    local infoBtnView=ids.infoBtnView
    if infoBtnView then
      if data.hasReadme then
        infoBtnView.setVisibility(View.VISIBLE)
       else
        infoBtnView.setVisibility(View.GONE)
      end
      infoBtnView.tag=data
    end
    SettingsLayUtil.adapterEvents.onBindViewHolder(settings2,holder,position)
  end,
}))

recyclerView.setAdapter(adapter)
layoutManager=LinearLayoutManager()
recyclerView.setLayoutManager(layoutManager)
recyclerView.setTag({_type="itemview"})
activity.registerForContextMenu(recyclerView)
recyclerView.onCreateContextMenu=function(menu,view,menuInfo)
  local data=settings2[menuInfo.position+1]
  if data.contextMenuEbaled then
    local key=data.key
    if key=="plugin_item" then
      local config=data.config
      menu.setHeaderTitle(data.title)
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
    end
  end
end

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

onNewIntent(activity.getIntent())