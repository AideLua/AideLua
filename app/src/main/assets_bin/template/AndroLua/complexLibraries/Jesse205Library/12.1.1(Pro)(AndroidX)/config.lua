name="Jesse205库"
keys={
  appTheme="@style/Theme.Jesse205.Default",
  includeLua={"project:Jesse205Library"},
  include={":Jesse205Library"},
  appDependencies={"api project(':Jesse205Library')"},
  appIcon="@mipmap/ic_launcher",
  appLuaActivity="com.jesse205.superlua.LuaActivity",
  appLuaActivityX="com.jesse205.superlua.LuaActivityX",
  appDebugActivity="com.jesse205.app.activity.RunActivity",
  appMainActivity="com.jesse205.superlua.Main",
  appWelcomeActivity="com.jesse205.superlua.Welcome",
  am_welcome_info={"android:theme=\"@style/Theme.Jesse205.Welcome\""},
  am_main_info={"android:theme=\"@style/Theme.Jesse205.Welcome\""},
  am_application={[[        <meta-data
            android:name="AideLua_KEY_MD5"
            android:value="2f2db2934f8eb0cddf80ba54abd741b1"/>]]}
}

delete={
  "app/src/main/res",
}

format={
  "app/src/main/res/values-zh-rCN/strings.xml",
}

support="androidx"