import "com.google.android.material.switchmaterial.SwitchMaterial"
import "com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions"


local SettingsLayUtil={}

SettingsLayUtil._VERSION="3.0"
SettingsLayUtil._VERSION_CODE=3099

local contextMenuEnabled

SettingsLayUtil.DIVIDER=1
SettingsLayUtil.TITLE=2
SettingsLayUtil.ITEM=3
SettingsLayUtil.ITEM_NOSUMMARY=4
SettingsLayUtil.ITEM_SWITCH=5
SettingsLayUtil.ITEM_SWITCH_NOSUMMARY=6
SettingsLayUtil.ITEM_AVATAR=7
SettingsLayUtil.ITEM_ONLYSUMMARY=8

local colorPrimary=res.color.attr.colorPrimary
local colorOnSurface=res.color.attr.colorOnSurface
local colorStateListOnSurface=res.colorStateList.jesse205_color_on_surface
local textColorPrimary=android.res.color.attr.textColorPrimary
local textColorSecondary=android.res.color.attr.textColorSecondary

local iconAlpha=Color.alpha(android.res.color.attr.colorControlNormal)/255

--v3.0+
local dividerLay={
  View;
  layout_width="fill";
  layout_height="1.5dp";--不知道为什么这里1.5dp等于res里面的1dp
  id="divider";
  --layout_marginTop="8dp";
  --layout_marginBottom="8dp";
  backgroundColor=res.color.attr.strokeColor;
};

local leftIconLay={
  AppCompatImageView,
  id="icon",
  layout_margin="16dp",
  layout_width="24dp",
  layout_height="24dp",
  --colorFilter=res.colorStateList.attr.colorControlNormal.getColors()[1],
  colorFilter=colorOnSurface;
  alpha=iconAlpha;
}

local leftCoverLay={
  MaterialCardView;
  layout_height="40dp";
  layout_width="40dp";
  layout_margin="16dp";
  layout_marginRight=0;
  radius="20dp";
  {
    AppCompatImageView;
    layout_height="fill";
    layout_width="fill";
    id="icon";
  };
}

local leftCoverIconLay={
  MaterialCardView;
  layout_height="40dp";
  layout_width="40dp";
  layout_margin="16dp";
  layout_marginRight=0;
  radius="20dp";
  {
    AppCompatImageView;
    layout_height="24dp";
    layout_width="24dp";
    layout_gravity="center";
    id="icon";
  };
}

local oneLineLay={
  AppCompatTextView;
  id="title";
  --textSize="16sp";
  --textColor=colorOnSurface;
  layout_weight=1;
  layout_margin="16dp";
  textAppearance=android.res.id.attr.textAppearanceListItem
}

local twoLineLay={
  LinearLayoutCompat;
  orientation="vertical";
  gravity="center";
  layout_weight=1;
  layout_margin="16dp";
  {
    AppCompatTextView;
    id="title";
    --textSize="16sp";
    --textColor=textColorPrimary;
    layout_width="fill";
    textAppearance=android.res.id.attr.textAppearanceListItem;
  };
  {
    AppCompatTextView;
    textSize="14sp";
    id="summary";
    layout_width="fill";
    --textAppearance=android.res.id.attr.textAppearanceListItemSecondary;
  };
}

local rightSwitchLay={
  SwitchMaterial;
  id="switchView";
  layout_marginLeft=0;
  layout_marginRight="16dp";
}

local rightNewPageIconLay={
  AppCompatImageView;
  id="rightIcon";
  layout_margin="16dp";
  layout_marginLeft=0;
  layout_width="24dp";
  layout_height="24dp";
  colorFilter=textColorSecondary;
}

SettingsLayUtil.leftIconLay=leftIconLay
SettingsLayUtil.leftCoverLay=leftCoverLay
SettingsLayUtil.leftCoverIconLay=leftCoverIconLay
SettingsLayUtil.oneLineLay=oneLineLay
SettingsLayUtil.twoLineLay=twoLineLay
SettingsLayUtil.rightSwitchLay=rightSwitchLay
SettingsLayUtil.rightNewPageIconLay=rightNewPageIconLay


local itemsLay={
  {--分割线
    LinearLayoutCompat;
    layout_width="fill";
    orientation="vertical";
    focusable=false;
    dividerLay;
    clickable=false;
  };

  {--标题
    LinearLayoutCompat;
    layout_width="fill";
    orientation="vertical";
    focusable=true;
    clickable=false;
    dividerLay;
    {
      AppCompatTextView;
      id="title";
      textSize="14sp";
      textColor=colorPrimary;
      padding="16dp";
      paddingLeft="72dp";
      paddingBottom="8dp";
      allCaps=true;
      --paddingTop="8dp";
      --typeface=Typeface.defaultFromStyle(Typeface.BOLD);
    }
  };

  {--设置项(图片,标题,简介)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    leftIconLay;
    twoLineLay;
    rightNewPageIconLay;
  };

  {--设置项(图片,标题)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    leftIconLay;
    oneLineLay;
    rightNewPageIconLay;
  };

  {--设置项(图片,标题,简介,开关)
    LinearLayoutCompat;
    gravity="center";
    layout_width="fill";
    focusable=true;
    leftIconLay;
    twoLineLay;
    rightSwitchLay;
  };


  {--设置项(图片,标题,开关)
    LinearLayoutCompat;
    gravity="center";
    layout_width="fill";
    focusable=true;
    leftIconLay;
    oneLineLay;
    rightSwitchLay;
  };

  {--设置项(头像,标题,简介)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    leftCoverLay;
    twoLineLay;
    rightNewPageIconLay;
  };

  {--设置项(简介)
    LinearLayoutCompat;
    gravity="center";
    layout_width="fill";
    focusable=false;
    {
      AppCompatTextView;
      layout_weight=1;
      layout_marginLeft="72dp",
      layout_margin="16dp";
      layout_width="fill";
      textSize="14sp";
      id="summary";
    };
  };

}
SettingsLayUtil.itemsLay=itemsLay
SettingsLayUtil.itemsNumber=#itemsLay

local function setAlpha(views,alpha)
  for index,content in pairs(views) do
    if content then
      content.setAlpha(alpha)
    end
  end
end
SettingsLayUtil.setAlpha=setAlpha

local function onItemViewClick(view)
  local ids=view.tag
  local viewConfig=ids._config
  local data=ids._data
  local key=data.key
  local onItemClick=viewConfig.onItemClick
  viewConfig.allowedChange=false

  local switchView=ids.switchView
  if switchView and viewConfig.switchEnabled then
    local checked=not(switchView.checked)
    switchView.setChecked(checked)
    if data.checked~=nil then
      data.checked=checked
     elseif data.key then
      local key=data.key
      --自动保存新值
      if data.sharedPreferences then
        local editor = data.sharedPreferences.edit()
        editor.putBoolean(key, checked)
        editor.commit()
       else
        setSharedData(key,checked)
      end
    end
  end

  if onItemClick then
    onItemClick(view,ids,key,data)
  end
  viewConfig.allowedChange=true
  return true
end
local onItemViewClickListener=View.OnClickListener({onClick=onItemViewClick})

local function onItemViewLongClick(view)
  local ids=view.tag
  local viewConfig=ids._config
  local data=ids._data
  local key=data.key
  local result
  local onItemLongClick=viewConfig.onItemLongClick
  viewConfig.allowedChange=false
  if onItemLongClick then
    result=onItemLongClick(view,ids,key,data)
  end
  viewConfig.allowedChange=true
  return result
end
local onItemViewLongClickListener=View.OnLongClickListener({onLongClick=onItemViewLongClick})


local function onSwitchCheckedChanged(view,checked)
  local viewConfig=view.tag
  local allowedChange=viewConfig.allowedChange
  if allowedChange then
    local key=viewConfig.key
    local data=viewConfig.data
    local onItemClick=viewConfig.onItemClick
    if data.checked~=nil then
      data.checked=checked
     elseif data.key then
      local key=data.key
      if data.sharedPreferences then
        local editor = data.sharedPreferences.edit()
        editor.putBoolean(key, checked)
        editor.commit()
       else
        setSharedData(key,checked)
      end
    end
    if onItemClick then
      onItemClick(viewConfig.itemView,viewConfig.ids,key,data)
    end
  end
end

local adapterEvents={
  getItemCount=function(data)
    return #data
  end,
  getItemViewType=function(data,position)
    local itemData=data[position+1]
    itemData.position=position
    return itemData[1]
  end,
  onCreateViewHolder=function(onItemClick,onItemLongClick,parent,viewType)
    local layoutTable=itemsLay[viewType]
    local ids={}

    local view=loadlayout2(layoutTable,ids)
    local holder=LuaCustRecyclerHolder(view)
    view.setTag(ids)
    local viewConfig={enabled=true,
      rightIconViewVisible=true,
      onItemClick=onItemClick,
      onItemLongClick=onItemLongClick,
      itemView=view,
      alphaStateViews={ids.title,ids.summary,ids.rightIcon},
      ids=ids}
    ids._config=viewConfig
    if layoutTable.clickable~=false then
      local switchView=ids.switchView
      view.setFocusable(true)
      view.setBackground(res.drawable.attr.listChoiceBackgroundIndicator)
      --view.setBackground(ThemeUtil.getRippleDrawable(res.color.attr.rippleColor,true))
      view.setOnClickListener(onItemViewClickListener)
      view.setOnLongClickListener(onItemViewLongClickListener)
      if switchView then
        switchView.tag=viewConfig
        switchView.setOnCheckedChangeListener({
          onCheckedChanged=onSwitchCheckedChanged})
      end
    end
    return holder
  end,

  onBindViewHolder=function(data,holder,position)
    local data=data[position+1]
    local layoutView=holder.view
    local ids=layoutView.getTag()
    local viewConfig=ids._config
    ids._data=data
    local title=data.title
    local icon=data.icon
    local summary=data.summary
    local enabled=data.enabled
    local switchEnabled=data.switchEnabled
    local key=data.key
    local action=data.action
    local chooseItems=data.items
    viewConfig.key=key
    viewConfig.data=data
    viewConfig.allowedChange=false

    --Views
    local dividerView=ids.divider--分割线
    local titleView=ids.title--标题
    local summaryView=ids.summary--简介
    local switchView=ids.switchView--开关
    local rightIconView=ids.rightIcon--右侧提示图标
    local iconView=ids.icon

    --分割线
    if dividerView then
      if data.dividerVisible==true then
        dividerView.setVisibility(View.VISIBLE)
       elseif data.dividerVisible==false then
        dividerView.setVisibility(View.GONE)
       else--默认状态，自动设置
        if position==0 then
          dividerView.setVisibility(View.GONE)
         else
          dividerView.setVisibility(View.VISIBLE)
        end
      end
    end

    --标题
    if titleView and title then
      titleView.text=title
    end

    --简介
    if summaryView then
      if summary then
        summaryView.text=summary
       elseif action=="singleChoose" then
        summaryView.text=chooseItems[(getSharedData(key) or 0)+1]
      end
    end

    --左侧图标
    if iconView then
      if icon then
        local iconType=type(icon)
        if iconType=="number" then
          iconView.setImageResource(icon)
         else
          Glide.with(activity)
          .load(icon)
          .transition(DrawableTransitionOptions.withCrossFade())
          .into(iconView)
        end
       else
        iconView.setImageDrawable(nil)
      end
    end
    --设置启用状态透明
    local enabledNotFalse=not(enabled==false)
    local switchEnabledNotFalse=not(switchEnabled==false)
    if viewConfig.enabled~=enabledNotFalse then
      viewConfig.enabled=enabledNotFalse
      layoutView.setEnabled(enabledNotFalse)
      if enabledNotFalse then
        setAlpha(viewConfig.alphaStateViews,1)
        iconView.setAlpha(iconAlpha)
       else
        setAlpha(viewConfig.alphaStateViews,0.5)
        iconView.setAlpha(iconAlpha*0.5)
      end
      if switchView then
        switchView.setEnabled(enabledNotFalse)
      end
    end

    if switchView then
      if data.checked~=nil then
        switchView.setChecked(data.checked)
       elseif key then
        local checked
        if data.sharedPreferences then
          checked=data.sharedPreferences.getBoolean(key,false)
         else
          checked=getSharedData(key)
        end
        switchView.setChecked(toboolean(checked))
       else
        switchView.setChecked(false)
      end
    end
    --右侧提示图标
    if rightIconView then
      local newPage=data.newPage
      local visible=viewConfig.rightIconViewVisible
      if newPage then
        if newPage=="newApp" then
          rightIconView.setImageResource(R.drawable.ic_launch)
         else
          rightIconView.setImageResource(R.drawable.ic_chevron_right)
        end
        if visible~=true then
          rightIconView.setVisibility(View.VISIBLE)
          viewConfig.rightIconViewVisible=true
        end
       else
        if visible~=false then
          rightIconView.setVisibility(View.GONE)
          viewConfig.rightIconViewVisible=false
        end
      end
    end
    viewConfig.allowedChange=true
  end,
}
SettingsLayUtil.adapterEvents=adapterEvents


--v3.0+
---生成摄制组字典<br>
---{<br>
--- key = [TitleSetting]<br>
---}<br>
---@param settingsData table[] 设置项数据
---@param settingsMap table<string,table> 要添加到的表
---@return table<string,table> settingsMap 已添加到的列表。如果存在 settingsMap，则返回 settingsMap
function SettingsLayUtil.generateSettingsGroupMap(settingsData,settingsMap)
  settingsMap=settingsMap or {}
  for index,content in ipairs(settingsData) do
    if type(content)=="table" then
      if content[1]==SettingsLayUtil.TITLE then
        if content.key then
          settingsMap[content.key]=content
        end
      end
    end
  end
  return settingsMap
end

--v3.0+
---加载设置项
---@param settingsData table[] 设置项数据
---@param newData table[] 要添加到的列表
---@return table[] newData 已添加到的列表
function SettingsLayUtil.loadSettingItems(settingsData,newData)
  newData=newData or {}
  for index,content in ipairs(settingsData) do
    if type(content)=="table" then
      table.insert(newData,content)
      SettingsLayUtil.loadSettingItems(content,newData)
    end
  end
  return newData
end

--新建一个简单的适配器
---@param data table<SettingItem>
---@param onItemClick function(view,ids,key,data)
function SettingsLayUtil.newAdapter(data,onItemClick,onItemLongClick)
  assert(data,"The first parameter must be table, now is "..type(data)..".")

  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      return adapterEvents.getItemCount(data)
    end,
    getItemViewType=function(position)
      return adapterEvents.getItemViewType(data,position)
    end,
    onCreateViewHolder=function(parent,viewType)
      return adapterEvents.onCreateViewHolder(onItemClick,onItemLongClick,parent,viewType)
    end,
    onBindViewHolder=function(holder,position)
      adapterEvents.onBindViewHolder(data,holder,position)
    end,
  }))
end


return SettingsLayUtil