import "com.google.android.material.switchmaterial.SwitchMaterial"
import "com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions"

local SettingsLayUtil={}
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
local textColorPrimary=android.res.color.attr.textColorPrimary
local textColorSecondary=android.res.color.attr.textColorSecondary

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
  colorFilter=android.res.color.attr.textColorPrimary;
  alpha=Color.alpha(android.res.color.attr.colorControlNormal)/255;
}

local leftCoverLay={
  MaterialCardView;
  layout_height="40dp";
  layout_width="40dp";
  layout_margin="16dp";
  layout_marginRight=0;
  radius="20dp";
  --[[
  {
    CardView;
    layout_height="fill";
    layout_width="fill";
    radius="18dp";]]
  {
    AppCompatImageView;
    layout_height="fill";
    layout_width="fill";
    id="icon";
  };
  --};
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
  textSize="16sp";
  textColor=textColorPrimary;
  layout_weight=1;
  layout_margin="16dp";
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
    layout_width="fill";
    --textColor=textColorPrimary;
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
    focusable=true;
    dividerLay;
  };

  {--标题
    LinearLayoutCompat;
    layout_width="fill";
    orientation="vertical";
    focusable=true;
    dividerLay;
    {
      AppCompatTextView;
      id="title";
      textSize="14sp";
      textColor=colorPrimary;
      padding="16dp";
      paddingLeft="72dp";
      paddingBottom="8dp";
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
    local ids={}
    local view=loadlayout2(itemsLay[viewType],ids)
    local holder=LuaCustRecyclerHolder(view)
    view.setTag(ids)
    local viewConfig={enabled=true,
      switchEnabled=true,
      onItemClick=onItemClick,
      onItemLongClick=onItemLongClick,
      itemView=view,
      ids=ids}
    ids._config=viewConfig
    if viewType~=1 then
      local switchView=ids.switchView
      view.setFocusable(true)
      view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
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
    local dividerView=ids.divider
    local titleView=ids.title
    local summaryView=ids.summary
    local switchView=ids.switchView
    local rightIconView=ids.rightIcon
    local iconView=ids.icon

    if dividerView then
      if data.dividerVisible==true then
        dividerView.setVisibility(View.VISIBLE)
       elseif data.dividerVisible==false then
        dividerView.setVisibility(View.GONE)
       else
        if position==0 then
          dividerView.setVisibility(View.GONE)
         else
          dividerView.setVisibility(View.VISIBLE)
        end
      end
    end

    if title and titleView then
      titleView.text=title
    end
    if summaryView then
      if summary then
        summaryView.text=summary
       elseif action=="singleChoose" then
        summaryView.text=chooseItems[(getSharedData(key) or 0)+1]
      end
    end
    if icon and iconView then
      if type(icon)=="number" then
        iconView.setImageResource(icon)
       else
        Glide.with(activity)
        .load(icon)
        .transition(DrawableTransitionOptions.withCrossFade())
        .into(iconView)
      end
    end

    --设置启用状态透明
    local enabledNotFalse=not(enabled==false)
    local switchEnabledNotFalse=not(switchEnabled==false)
    if viewConfig.enabled~=enabledNotFalse then
      viewConfig.enabled=enabledNotFalse
      layoutView.setEnabled(enabledNotFalse)
      local viewsList={titleView,summaryView,iconView,rightIconView}
      if enabledNotFalse then
        setAlpha(viewsList,1)
       else
        setAlpha(viewsList,0.5)
      end
    end
    if viewConfig.switchEnabled~=switchEnabledNotFalse then
      viewConfig.switchEnabled=switchEnabledNotFalse
      if switchView then
        switchView.setEnabled(switchEnabledNotFalse)
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

    if rightIconView then
      local newPage=data.newPage
      local visibility=rightIconView.getVisibility()
      if newPage then
        if newPage=="newApp" then
          rightIconView.setImageResource(R.drawable.ic_launch)
         else
          rightIconView.setImageResource(R.drawable.ic_chevron_right)
        end
        if visibility~=View.VISIBLE then
          rightIconView.setVisibility(View.VISIBLE)
        end
       else
        if visibility~=View.GONE then
          rightIconView.setVisibility(View.GONE)
        end
      end
    end
    viewConfig.allowedChange=true
  end,
}
SettingsLayUtil.adapterEvents=adapterEvents

function SettingsLayUtil.newAdapter(data,onItemClick,onItemLongClick)
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