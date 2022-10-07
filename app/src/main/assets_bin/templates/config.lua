templateType="default"
versions={
  app={
    {"aide(2.1)",2199},
  },--所有app版本号
}
subTemplates={"AndroLua"}
subTemplateConfigsMap={}

format={
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

defaultKeys={
  appTheme="@style/AppTheme",
  appName="MyApplication",
  appPackageName="com.aidelua.myapplication",
  --appLuaActivity="com.androlua.LuaActivity"
  --appLuaActivityX="com.androlua.LuaActivityX"
  --appMainActivity="com.androlua.Main"
  --appWelcomeActivity="com.androlua.Welcome"
  am_application={},
  am_application_bottom={},
  appDependencies={},
  appDependenciesEnd={},
  appIncludeLua={},
  appInclude={},
  androidX=true,
  compileLua=true,
  appIcon="@drawable/ic_launcher",
  defaultImport={},
  am_welcome_info={},
  am_main_info={},
  dependenciesEnd={},
}

tableConfigFormatter={
  include=function(content)--settings.gradle中的
    return ",'"..table.concat(content,"','").."'"
  end,
  dependencies=function(content)
    return "\n    "..table.concat(content,"\n    ")
  end,
}
tableConfigFormatter.appDependencies=tableConfigFormatter.dependencies
tableConfigFormatter.appDependenciesEnd=tableConfigFormatter.dependencies
tableConfigFormatter.dependenciesEnd=tableConfigFormatter.dependencies
