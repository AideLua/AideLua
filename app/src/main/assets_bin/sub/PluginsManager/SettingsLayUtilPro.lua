local itemsLay=SettingsLayUtil.itemsLay
local oldLastIndex=SettingsLayUtil.itemsNumber
SettingsLayUtil.ITEM_AVATAR_SWITCH=oldLastIndex+1
SettingsLayUtil.ITEM_AVATAR_ICON_SWITCH=oldLastIndex+2
SettingsLayUtil.itemsNumber=oldLastIndex+2

local infoLay={
  AppCompatImageView;
  padding="8dp";
  id="infoBtnView";
  layout_width="40dp";
  layout_height="48dp";
  imageResource=R.drawable.ic_information_outline;
}

table.insert(itemsLay,{--设置项(头像,标题,简介)
  LinearLayoutCompat;
  layout_width="fill";
  gravity="center";
  focusable=true;
  SettingsLayUtil.leftCoverLay;
  SettingsLayUtil.twoLineLay;
  infoLay;
  SettingsLayUtil.rightSwitchLay;
})
table.insert(itemsLay,{--设置项(头像,标题,简介)
  LinearLayoutCompat;
  layout_width="fill";
  gravity="center";
  focusable=true;
  SettingsLayUtil.leftCoverIconLay;
  SettingsLayUtil.twoLineLay;
  infoLay;
  SettingsLayUtil.rightSwitchLay;
})