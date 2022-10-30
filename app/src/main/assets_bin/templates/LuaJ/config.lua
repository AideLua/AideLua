versions={
  luaj={
    {"1970-01-01(2022-10-30)",20221030},
  }--所有luaj版本号
}
formatList={
  "luaj/build.gradle",
}
keys={
  appLuaActivity="com.androlua.LuaActivity",
  appLuaActivityX="com.androlua.LuaActivityX",
  appMainActivity="com.androlua.Main",
  appWelcomeActivity="com.androlua.Welcome",
}

tableConfigFormatter={
  am_application=function(content)
    return "\n"..table.concat(content,"\n\n").."\n"
  end,
  am_activity_info=function(content)
    return "\n            "..table.concat(content,"\n            ")
  end,
}
tableConfigFormatter.am_application_bottom=tableConfigFormatter.am_application
tableConfigFormatter.am_welcome_info=tableConfigFormatter.am_activity_info
tableConfigFormatter.am_main_info=tableConfigFormatter.am_activity_info
