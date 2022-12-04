_G["import"] "com.jesse205.layout.MyTipLayout"
templateType="default"
versions={
  app={
    {"aide(7.2.1)",721,true},
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
  dependencies={},--所有模块的build.prop依赖
  dependenciesEnd={}, --所有模块的build.prop依赖底部
  appDependencies={}, --app模块的build.prop的依赖
  appDependenciesEnd={}, --app模块的build.prop依赖的底部
  include={}, --settings.gradle的包含的模块
}

tableConfigFormatter={
  include=function(content) -- settings.gradle中include的
    return ",'"..table.concat(content,"','").."'"
  end,
  dependencies=function(content)--build.gradle/dependencies
    content="\n    "..table.concat(content,"\n    ")
  end,
}

tableConfigFormatter.appDependencies=tableConfigFormatter.dependencies
tableConfigFormatter.appDependenciesEnd=tableConfigFormatter.dependencies
tableConfigFormatter.dependenciesEnd=tableConfigFormatter.dependencies
