templateType="default"
versions={
  app={
    {"aide(2.1)",2199},
  },--所有app版本号
}
--字模块列表，用于自动加载子模块
subTemplates={"AndroLua"}

--待格式化文件列表
formatList={
  "settings.gradle",
  "gradle.properties",
  ".aidelua/config.lua",
  "app/.aidelua/config.lua",
  "app/build.gradle",
  "app/src/main/AndroidManifest.xml",
  "app/src/main/res/values/strings.xml",
  "app/src/main/assets_bin/init.lua",
  "app/src/main/assets_bin/main.lua",
}

--格式化的键值
keys={
  appTheme="@style/AppTheme",--app模块下的application主题
  am_application={},--app模块下AndroidManifest.xml的application顶部
  am_application_bottom={},--同理是底部
  appIcon="@drawable/ic_launcher",--app模块下应用图标
  am_welcome_info={},--欢迎活动
  am_main_info={},--主活动
}

