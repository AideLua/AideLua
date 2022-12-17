versions={
  androlua={
    {"5.0.10(1.6)(armeabi-v7a)",1699},
    {"5.0.16(1.2)(arm64-v8a)",1299},
    {"5.0.18(1.1)(armeabi-v7a,arm64-v8a)",1199,true}
  }--所有androlua版本号
}
formatList={
  "androlua/build.gradle",
}
keys={
  appLuaActivity="com.androlua.LuaActivity",
  appLuaActivityX="com.androlua.LuaActivityX",
  appMainActivity="com.androlua.Main",
  appWelcomeActivity="com.androlua.Welcome",
  appDependencies={"api project(':androlua')"}
}

tableConfigFormatter={
  am_application=function(content)--AndroidManifest.xml/manifest/application
    return "\n"..table.concat(content,"\n\n").."\n"
  end,
  am_activity_info=function(content)--AndroidManifest.xml/manifest/application/activity android:name
    return "\n            "..table.concat(content,"\n            ")
  end,
}
tableConfigFormatter.am_application_bottom=tableConfigFormatter.am_application
tableConfigFormatter.am_welcome_info=tableConfigFormatter.am_activity_info
tableConfigFormatter.am_main_info=tableConfigFormatter.am_activity_info

