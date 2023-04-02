package com.jesse205.aidelua2.manager;

/**
 * @Author Jesse205
 * @Date 2023/03/20 03:00
 * @Describe Lua 插件管理器
 */
import android.content.Context;

public class LuaPluginsManager {

    private static final String TAG = "LuaPluginsManager";

    private static String[] mEnabledPluginPaths;

    private static String mAppTag;//相当于apptype
    private Context mContext;

    public LuaPluginsManager(Context context){
        mContext=context;
    }
    
    public static void setAppTag(String appTag) {
        mAppTag = appTag;
    }

    public static String getAppTag() {
        return mAppTag;
    }

    public static void setEnabledPluginPaths(String[] enabledPluginPaths) {
        mEnabledPluginPaths = enabledPluginPaths;
    }

    public static String[] getEnabledPluginPaths() {
        return mEnabledPluginPaths;
    }
    
    

}
