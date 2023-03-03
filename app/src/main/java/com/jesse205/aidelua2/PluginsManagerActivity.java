package com.jesse205.aidelua2;

import android.app.Activity;
import android.os.Bundle;

/**
 * @Author Jesse205
 * @Date 2023/03/03 02:53
 * @Describe 插件活动
 */
public class PluginsManagerActivity extends com.jesse205.superlua.LuaActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        setCheckUpdate(true);
        super.onCreate(savedInstanceState);
    }

    @Override
    public String getLuaPath() {
        String path;
        if (updating) {
            path = "/";
        } else {
            path = getLocalDir() + "/sub/PluginsManager/main.lua";
        }
        applyLuaDir(path);
        return path;
    }
}
