package com.jesse205.util;

/**
 * @Author Jesse205
 * @Date 2023/02/27 22:40
 */

import static android.os.Build.VERSION.SDK_INT;

import android.content.Context;
import android.content.res.Configuration;

public class ThemeUtil {
    /**
     * 判罚系统是否开启了夜间模式
     * @param context 上下文
     * @return 是否开启了夜间模式
     */
    public static boolean isSystemNightMode(Context context) {
        //TODO: 在低于安卓10的RR等系统进行单独的判断
        return (context.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
    }

    /**
     * 判断当前系统导航栏是不是灰色的<br>
     * 部分系统导航栏是灰色的，说明可以显示白色背景。特别做此优化。<br>
     * 已知灰色导航栏的系统 EMUI5 及以上
     *
     * @return 是不是灰色导航栏的系统
     */
    public static boolean isGrayNavigationBarSystem() {
        if (SDK_INT >= 24) {
            try {
                Class.forName("androidhwext.R");
                return true;
            } catch (ClassNotFoundException ignored) {
            }
            return false;
        } else {
            return false;
        }
    }
}
