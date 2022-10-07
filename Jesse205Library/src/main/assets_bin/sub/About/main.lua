require "import"
import "jesse205"
local normalkeys=jesse205.normalkeys
normalkeys.appInfo=true
normalkeys.openSourceLicenses=true
normalkeys.developers=true
normalkeys.moreItem=true
normalkeys.copyright=true
import "com.jesse205.layout.util.SettingsLayUtil"
import "com.jesse205.app.dialog.ImageDialogBuilder"
import "appAboutInfo"
import "agreements"

activity.setTitle(R.string.jesse205_about)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

loadlayout2("iconLayout")
loadlayout2("portraitCardParentView")
portraitCardParent.addView(iconLayout)

adapterEvents=SettingsLayUtil.adapterEvents
packageInfo=activity.getPackageManager().getPackageInfo(getPackageName(),0)
landscape=false
LastCard2Elevation=0

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

--获取QQ头像链接
function getUserAvatarUrl(qq,size)
  if qq then
    return ("http://q.qlogo.cn/headimg_dl?spec=%s&img_type=jpg&dst_uin=%s"):format(size or 640,qq)
  end
end

--加入QQ交流群
function joinQQGroup(groupNumber)
  local uri=Uri.parse(("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%s&card_type=group&source=qrcode"):format(groupNumber))
  if not(pcall(activity.startActivity,Intent(Intent.ACTION_VIEW,uri))) then
    MyToast(R.string.jesse205_noQQ)
  end
end

function onItemClick(view,views,key,data)
  if key=="developer" then
    if data.qq then
      pcall(activity.startActivity,Intent(Intent.ACTION_VIEW,Uri.parse("mqqwpa://im/chat?chat_type=wpa&uin="..data.qq)))
    end
   elseif key=="more" then
    if data.url then--单个QQ群
      openUrl(data.url)
     elseif data.browserUrl then--单个QQ群
      openUrl(data.browserUrl)
     elseif data.qqGroup then--多个QQ群
      joinQQGroup(data.qqGroup)
     elseif data.func then
      data.func()
     elseif data.contextMenuEnabled then
      --recyclerView.tag._data=data
      recyclerView.showContextMenuForChild(view)
      --recyclerView.showContextMenu()
    end
   elseif key=="html" then
    newSubActivity("HtmlFileViewer",{{title=data.title,path=data.path}})
   elseif key=="openSourceLicenses" then
    newSubActivity("OpenSourceLicenses")
   elseif key=="support" then
    local supportUrl=data.supportUrl
    if data.supportList then
      recyclerView.showContextMenu()
     elseif supportUrl then
      openUrl(supportUrl)
    end
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
  local newLandscape=config.orientation==Configuration.ORIENTATION_LANDSCAPE
  if landscape~=newLandscape then
    landscape=newLandscape
    local screenWidthDp=config.screenWidthDp
    if newLandscape then--横屏时
      LastActionBarElevation=0
      actionBar.setElevation(0)
      appBarElevationCard.setVisibility(View.VISIBLE)
      local linearParams=iconLayout.getLayoutParams()
      if screenWidthDp>theme.number.width_dp_pad then
        linearParams.width=math.dp2int(200+16*2)
       else
        linearParams.width=math.dp2int(152+16*2)
      end
      iconLayout.setLayoutParams(linearParams)
      portraitCardParent.removeView(iconLayout)
      mainLayChild.addView(iconLayout,0)
     else
      appBarElevationCard.setVisibility(View.GONE)
      local linearParams=iconLayout.getLayoutParams()
      linearParams.width=-1
      iconLayout.setLayoutParams(linearParams)
      mainLayChild.removeView(iconLayout)
      portraitCardParent.addView(iconLayout)
    end
  end
end

topCardItems={}
--插入大软件图标
if appInfo then
  for index,content in ipairs(appInfo) do
    local ids={}
    appIconGroup.addView(loadlayout2("iconItem",ids,LinearLayoutCompat))
    table.insert(topCardItems,ids.mainIconLay)
    local icon,iconView,nameView=content.icon,ids.icon,ids.name
    iconView.setBackgroundResource(icon)
    nameView.setText(content.name)
    ids.message.setText(content.message)
    if content.click then
      ids.mainIconLay.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary))
      ids.mainIconLay.onClick=content.click
    end
    local pain=ids.name.getPaint()
    if content.typeface then
      pain.setTypeface(content.typeface)
     else
      pain.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD))
    end
    if content.nameColor then
      nameView.setTextColor(content.nameColor)
    end
    ids=nil
  end
end

data={
  {--软件图标
    -1;
  };

  {--关于软件
    SettingsLayUtil.TITLE;
    title=R.string.jesse205_about_full;
  };
  {--软件版本
    SettingsLayUtil.ITEM;
    title=R.string.jesse205_nowVersion_app;
    summary=("%s (%s)"):format(packageInfo.versionName,packageInfo.versionCode);
    icon=R.drawable.ic_information_outline;
    key="update";
  };
  {--Jesse205Library版本
    SettingsLayUtil.ITEM;
    title=R.string.jesse205_nowVersion_jesse205Library;
    summary=("%s (%s)"):format(jesse205._VERSION,jesse205._VERSIONCODE);
    icon=R.drawable.ic_information_outline;
  };
}

--插入协议
if agreements then
  local fileBasePath=activity.getLuaPath("../../agreements/%s.html")
  for index,content in ipairs(agreements) do
    content[1]=SettingsLayUtil.ITEM_NOSUMMARY
    content.path=fileBasePath:format(content.name)
    content.key="html"
    content.newPage=true
    table.insert(data,content)
  end
end


--开发信息
if developers or openSourceLicenses then
  table.insert(data,{
    SettingsLayUtil.TITLE;
    title=R.string.jesse205_developerInfo;
  })
end

--插入开发者
if developers then
  for index,content in ipairs(developers) do
    table.insert(data,{
      SettingsLayUtil.ITEM_AVATAR;
      title="@"..content.name;
      summary=content.message;
      icon=content.avatar or getUserAvatarUrl(content.qq,content.imageSize);
      qq=content.qq;
      key="developer";
      newPage="newApp";
    })
  end
end

--插入开源许可
if openSourceLicenses then
  table.insert(data,{
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.jesse205_openSourceLicense;
    icon=R.drawable.ic_github;
    key="openSourceLicenses";
    newPage=true;
  })
end

if moreItem or copyright then
  --更多内容
  table.insert(data,{
    SettingsLayUtil.TITLE;
    title=R.string.jesse205_moreContent;
  })
  if moreItem then
    for index=1,#moreItem do
      local content=moreItem[index]
      content.key="more"
      table.insert(data,content)
    end
  end
  if copyright then--版权信息
    table.insert(data,{
      SettingsLayUtil.ITEM;
      title=R.string.jesse205_copyright;
      summary=copyright;
      icon=R.drawable.ic_copyright;
      key="copyright";
    })
  end
end


adapter=LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return adapterEvents.getItemCount(data)
  end,
  getItemViewType=function(position)
    return adapterEvents.getItemViewType(data,position)
  end,
  onCreateViewHolder=function(parent,viewType)
    if viewType==-1 then
      local holder=LuaCustRecyclerHolder(portraitCardParent)
      return holder
     else
      return adapterEvents.onCreateViewHolder(onItemClick,nil,parent,viewType)
    end
  end,
  onBindViewHolder=function(holder,position)
    if position~=0 then
      adapterEvents.onBindViewHolder(data,holder,position)
    end
  end,
}))

recyclerView.setAdapter(adapter)
layoutManager=LinearLayoutManager()
recyclerView.setLayoutManager(layoutManager)
activity.registerForContextMenu(recyclerView)
recyclerView.onCreateContextMenu=function(menu,view,menuInfo)
  local data=data[menuInfo.position+1]
  if data and data.contextMenuEnabled then
    local key=data.key
    if key=="more" and data.contextMenuEnabled then--多个QQ群
      menu.setHeaderTitle(data.title)
      local menusList=data.menus
      for index,content in ipairs(menusList) do
        menu.add(0,index,0,content.title)
      end
      menu.setCallback({
        onMenuItemSelected=function(menu,item)
          local id=item.getItemId()
          local menuData=menusList[id]
          if menuData.url then--单个QQ群
            openUrl(menuData.url)
           elseif menuData.browserUrl then--单个QQ群
            openUrl(menuData.browserUrl)
           elseif menuData.qqGroup then--多个QQ群
            joinQQGroup(menuData.qqGroup)
           elseif menuData.func then
            menuData.func()
          end
        end
      })
    end
  end
end

recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    if landscape then
      MyAnimationUtil.RecyclerView.onScroll(view,dx,dy,appBarElevationCard,"LastCard2Elevation")
     else
      MyAnimationUtil.RecyclerView.onScroll(view,dx,dy)
    end
  end
})


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  orientation={
    different={appIconGroup},
  },
  fillParentViews={topCard},
  onDeviceChanged = function(device, oldDevice)
    if device=="pc" then
      local linearParams=iconCard.getLayoutParams()
      linearParams.height=-2
      linearParams.width=-2
      iconCard.setLayoutParams(linearParams)
     elseif oldDevice=="pc" then
      local linearParams=iconCard.getLayoutParams()
      linearParams.height=-1
      linearParams.width=-1
      iconCard.setLayoutParams(linearParams)
    end
  end
})

onConfigurationChanged(activity.getResources().getConfiguration())