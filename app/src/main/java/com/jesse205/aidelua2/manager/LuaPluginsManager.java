package com.jesse205.aidelua2.manager;

/**
 * @Author Jesse205
 * @Date 2023/03/20 03:00
 * @Describe Lua 插件管理器
 */
public class LuaPluginsManager {

    private static final String TAG = "LuaPluginsManager";

    private static String[] enabledPluginPaths;

    private static String appTag; // 相当于apptype

    public static void setEnabledPluginPaths(String[] enabledPluginPaths) {
        LuaPluginsManager.enabledPluginPaths = enabledPluginPaths;
    }

    public static String[] getEnabledPluginPaths() {
        return enabledPluginPaths;
    }

}
