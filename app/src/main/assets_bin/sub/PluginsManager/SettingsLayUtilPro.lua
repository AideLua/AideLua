local itemsLay=SettingsLayUtil.itemsLay
local oldLastIndex=SettingsLayUtil.itemsNumber
SettingsLayUtil.ITEM_AVATAR_SWITCH=oldLastIndex+1
SettingsLayUtil.itemsNumber=oldLastIndex+1


table.insert(itemsLay,{--设置项(头像,标题,简介)
  LinearLayoutCompat;
  layout_width="fill";
  gravity="center";
  focusable=true;
  SettingsLayUtil.leftCoverLay;
  SettingsLayUtil.twoLineLay;
  SettingsLayUtil.rightSwitchLay;
})