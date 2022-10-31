package com.jesse205.activity;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import com.androlua.LuaApplication;

public class SettingsActivity extends com.jesse205.superlua.LuaActivity {
    String luaDir;
    LuaApplication app;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        app = (LuaApplication) getApplication();
        luaDir=app.getLocalDir() + "/sub/Settings/main.lua";
        Intent intent = getIntent();
        intent.setData(Uri.parse("file://" + luaDir));
        setCheckUpdate(true);
        super.onCreate(savedInstanceState);
    }
}
