package com.jesse205.aidelua2.activity;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import com.androlua.LuaApplication;
import com.jesse205.superlua.LuaActivity;

public class InstallPluginActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LuaApplication application=(LuaApplication) getApplication();
		String luaPath=application.getLocalDir() + "/sub/PluginsManager/main.lua";
		Intent intent = new Intent(this, LuaActivity.class);
		intent.putExtra("name", "PluginsManager");
		intent.putExtra("luaPath", luaPath);
		intent.putExtra("checkUpdate", true);
		intent.putExtra("fileUri", getIntent().getData());
		intent.setData(Uri.parse("file://" + luaPath + "?documentId=0"));
		startActivity(intent);
		finish();
	}
}
