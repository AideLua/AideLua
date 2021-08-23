require "import"
import "Jesse205"

import "com.Jesse205.layout.util.SettingsLayUtil"
import "com.Jesse205.app.dialog.ImageDialogBuilder"
import "appAboutInfo"
import "agreements"

local screenConfigDecoder,actionBar,Landscape,data,PackInfo,adp,layoutManager,Glide,topCardItems
activity.setTitle(R.string.Jesse205_about)
activity.setContentView(loadlayout("layout",_ENV))
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true)

PackInfo=activity.PackageManager.getPackageInfo(activity.getPackageName(),64)
Landscape=false

Glide=_G.Glide
function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

--获取QQ头像链接
function getUserAvatarUrl(qq,size)
  return ("http://q.qlogo.cn/headimg_dl?spec=%s&img_type=jpg&dst_uin=%s"):format(size or 640,qq)
end

--加入QQ交流群
function joinQQGroup(groupNumber)
  local uri=Uri.parse(("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%s&card_type=group&source=qrcode"):format(groupNumber))
  if not(pcall(activity.startActivity,Intent(Intent.ACTION_VIEW,uri))) then
    MyToast(R.string.Jesse205_noQQ)
  end
end

function onItemClick(view,views,key,data)
  if key=="qq" then
    pcall(activity.startActivity,Intent(Intent.ACTION_VIEW,Uri.parse("mqqwpa://im/chat?chat_type=wpa&uin="..data.qq)))
   elseif key=="qq_group" then
    joinQQGroup(data.groupId)
   elseif key=="qq_groups" then
    local pop=PopupMenu(activity,view)
    local menu=pop.Menu
    for index,content in ipairs(data.groups) do
      menu.add(content.name).onMenuItemClick=function()
        joinQQGroup(content.id)
      end
    end
    pop.show()
   elseif key=="html" then
    newSubActivity("HtmlFileViewer",{{title=data.title,path=data.path}})
   elseif key=="openSourceLicenses" then
    newSubActivity("OpenSourceLicenses")
   elseif key=="donate" then
    local donateImage=data.donateImage
    local donateUrl=data.donateUrl
    if donateImage then
      ImageDialogBuilder(activity)
      :setImage(donateImage)
      :show()
     elseif donateUrl then
      openUrl(data.donateUrl)
    end
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
  if config.orientation==Configuration.ORIENTATION_LANDSCAPE then--横屏时
    LastActionBarElevation=0
    topCard.setElevation(0)
    Landscape=true
    local linearParams=appIconGroup.getLayoutParams()
    linearParams.width=math.dp2int(192)
    appIconGroup.setLayoutParams(linearParams)
   else
    Landscape=false
    local linearParams=appIconGroup.getLayoutParams()
    linearParams.width=-1
    appIconGroup.setLayoutParams(linearParams)
  end
  if screenConfigDecoder.device=="pc" then
    local linearParams=topCard.getLayoutParams()
    linearParams.height=-2
    linearParams.width=-2
    topCard.setLayoutParams(linearParams)
    LastActionBarElevation=0
    topCard.setElevation(0)
  end
end

topCardItems={}
--插入大软件图标
for index,content in ipairs(appInfo) do
  local ids={}
  appIconGroup.addView(loadlayout("iconItem",ids,LinearLayoutCompat))
  table.insert(topCardItems,ids.mainIconLay)
  local icon,iconView=content.icon,ids.icon
  if type(icon)=="number" then
    iconView.setImageResource(icon)
   else
    Glide.with(activity)
    .load(icon)
    .into(iconView)
  end
  ids.name.setText(content.name)
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
  ids=nil
end

data={
  {--关于软件
    SettingsLayUtil.TITLE;
    title=R.string.Jesse205_about_full;
  };
  {--软件版本
    SettingsLayUtil.ITEM;
    title=R.string.Jesse205_nowVersion_app;
    summary=("%s(%s)"):format(PackInfo.versionName,PackInfo.versionCode);
    icon=R.drawable.ic_information_outline;
    key="update";
  };
  {--Jesse205Library版本
    SettingsLayUtil.ITEM;
    title=R.string.Jesse205_nowVersion_jesse205Library;
    summary=("%s(%s)"):format(Jesse205._VERSION,Jesse205._VERSIONCODE);
    icon=R.drawable.ic_information_outline;
  };
}

--插入协议
if agreements then
  for index,content in ipairs(agreements) do
    content[1]=SettingsLayUtil.ITEM_NOSUMMARY
    content.path=activity.getLuaPath(("../../agreements/%s.html"):format(content.name))
    content.key="html"
    content.newPage=true
    table.insert(data,content)
  end
end

--开发信息
table.insert(data,{
  SettingsLayUtil.TITLE;
  title=R.string.Jesse205_developerInfo;
})

--插入开发者
for index,content in ipairs(developers) do
  table.insert(data,{
    SettingsLayUtil.ITEM_AVATAR;
    title="@"..content.name;
    summary=content.message;
    icon=getUserAvatarUrl(content.qq,content.imageSize);
    qq=content.qq;
    key="qq";
    newPage="newApp";
  })
end

--插入开源许可
if openSourceLicenses then
  table.insert(data,{
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.Jesse205_openSourceLicense;
    icon=R.drawable.ic_github;
    key="openSourceLicenses";
    newPage=true;
  })
end

--更多内容
table.insert(data,{
  SettingsLayUtil.TITLE;
  title=R.string.Jesse205_moreContent;
})

--插入交流群
if qqGroup then--单个交流群
  table.insert(data,{
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.Jesse205_qqGroup;
    icon=R.drawable.ic_account_group_outline;
    groupId=qqGroup;
    key="qq_group";
    newPage="newApp";
  })
end

if qqGroups then--多个交流群
  table.insert(data,{
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.Jesse205_qqGroups;
    icon=R.drawable.ic_account_group_outline;
    groups=qqGroups;
    key="qq_groups";
  })
end

if donateUrl or donateImage then--支持项目
  table.insert(data,{
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.Jesse205_donate;
    icon=R.drawable.ic_wallet_giftcard;
    donateUrl=donateUrl;
    donateImage=donateImage;
    key="donate";
    newPage=donateNewPage;
  })
end

if copyright then--版权信息
  table.insert(data,{
    SettingsLayUtil.ITEM;
    title=R.string.Jesse205_copyright;
    summary=copyright;
    icon=R.drawable.ic_copyright;
    key="copyright";
  })
end

adp=SettingsLayUtil.newAdapter(data,onItemClick)
recyclerView.setAdapter(adp)
layoutManager=StaggeredGridLayoutManager(1,StaggeredGridLayoutManager.VERTICAL)
recyclerView.setLayoutManager(layoutManager)

recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    if not(Landscape) and (not(screenConfigDecoder) or screenConfigDecoder.device=="phone") then
      MyAnimationUtil.RecyclerView.onScroll(view,dx,dy,topCard)
    end
  end
})

recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
  onGlobalLayout=function()
    if activity.isFinishing() then
      return
    end
    if not(Landscape) and (not(screenConfigDecoder) or screenConfigDecoder.device=="phone") then
      MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0,topCard)
    end
  end
})

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  orientation={
    identical={mainLayChild},
    different={appIconGroup},
  },
  fillParentViews={topCard},
})

onConfigurationChanged(activity.getResources().getConfiguration())