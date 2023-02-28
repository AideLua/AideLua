package com.jesse205.util;

/**
 * @Author Jesse205
 * @Date 2023/02/27 22:40
 */
import android.content.Context;
import android.content.res.Configuration;
import static android.os.Build.VERSION.SDK_INT;

public class ThemeUtil {
    public static boolean isSystemNightMode(Context context) {
        return (context.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
    }
    
    public static boolean isGrayNavigationBarSystem() {
        if (SDK_INT >= 24) {
            try {
                Class.forName("androidhwext.R");
            } catch (ClassNotFoundException e) {
                return false;
            }
            return true;
        } else {
            return false;
        }
	}
}
