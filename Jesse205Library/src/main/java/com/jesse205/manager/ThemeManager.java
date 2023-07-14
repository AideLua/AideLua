package com.jesse205.manager;

import static android.os.Build.VERSION.SDK_INT;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.os.Build;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.jesse205.R;
import com.jesse205.util.ThemeUtil;

import java.lang.reflect.Field;

/**
 * 主题管理器
 *
 * @author Jesse205
 * @since 2023/02/21 01:11
 */
public class ThemeManager {
    public static final String THEME_TYPE = "theme_type";
    public static final String THEME_STYLE = "theme_style";
    private static final String TAG = "ThemeManager";
    @NonNull
    private static ThemeType defaultAppTheme = ThemeType.BLUE;
    @NonNull
    private static ThemeStyle defaultThemeStyle = ThemeStyle.Material2;
    private static ThemeType appThemeType;
    private static ThemeStyle appThemeStyle;

    private final ThemeType themeType;
    private final ThemeStyle themeStyle;
    private final ContextThemeWrapper context;

    public ThemeManager(ContextThemeWrapper context) {
        this.context = context;
        if (appThemeType == null)
            appThemeType = getAppTheme(context);
        if (appThemeStyle == null)
            appThemeStyle = getAppThemeStyle(context);
        themeType = appThemeType;
        themeStyle = appThemeStyle;
    }

    /**
     * 设置软件默认主题配色
     *
     * @param context   上下文
     * @param themeType 默认的主题配色
     */
    public static void setDefaultTheme(Context context, ThemeType themeType) {
        defaultAppTheme = themeType;
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        if (sharedPreferences.getString(THEME_TYPE, null) == null) {
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putString(THEME_TYPE, themeType.name());
            editor.apply();
        }
    }

    /**
     * 设置软件默认主题配色
     *
     * @param context    上下文
     * @param themeStyle 默认的主题配色
     */
    public static void setDefaultThemeStyle(Context context, ThemeStyle themeStyle) {
        defaultThemeStyle = themeStyle;
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        if (sharedPreferences.getString(THEME_STYLE, null) == null) {
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putString(THEME_STYLE, themeStyle.name());
            editor.apply();
        }
    }

    /**
     * 设置软件全局主题配色
     *
     * @param context   上下文
     * @param themeType 主题配色
     */
    public static void setAppTheme(Context context, ThemeType themeType) {
        appThemeType = themeType;
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(THEME_TYPE, themeType.name());
        editor.apply();
    }

    /**
     * 获取软件全局主题配色
     *
     * @param context 上下文
     * @return 主题配色
     */
    public static ThemeType getAppTheme(Context context) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        String themeTypeName = sharedPreferences.getString(THEME_TYPE, null);
        if (themeTypeName == null) {
            return defaultAppTheme;
        } else {
            try {
                return ThemeType.valueOf(themeTypeName);
            } catch (IllegalArgumentException e) {
                Log.e(TAG, "IllegalArgumentException: " + e);
                return defaultAppTheme;
            }
        }
    }

    /**
     * 设置软件全局主题风格
     *
     * @param context    上下文
     * @param themeStyle 主题配色
     */
    public static void setAppThemeStyle(Context context, ThemeStyle themeStyle) {
        appThemeStyle = themeStyle;
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(THEME_STYLE, themeStyle.name());
        editor.apply();
    }

    /**
     * 获取软件全局主题风格
     *
     * @param context 上下文
     * @return 主题风格
     */
    public static ThemeStyle getAppThemeStyle(Context context) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        String themeStyleName = sharedPreferences.getString(THEME_STYLE, null);

        if (themeStyleName == null) {
            return defaultThemeStyle;
        } else {
            try {
                return ThemeStyle.valueOf(themeStyleName);
            } catch (IllegalArgumentException e) {
                Log.e(TAG, "IllegalArgumentException: " + e);
                return defaultThemeStyle;
            }
        }
    }

    /**
     * 获取主题ID
     *
     * @param context       上下文
     * @param themeType     主题配色
     * @param themeStyle    主题风格
     * @param isNoActionBar 是否不使用操作栏
     * @return 主题资源ID
     */
    public static int getThemeId(Context context, ThemeType themeType, ThemeStyle themeStyle, boolean isNoActionBar) {
        // TODO: 实现Material1，并用switch判断
        if (themeStyle == ThemeStyle.Material3)
            return R.style.Theme_Jesse205_Material3;// MD3只有这一个主题

        int themeId = R.style.Theme_Jesse205_Blue;
        String styleKey = "Theme_Jesse205";

        switch (themeType) {
            case BLUE:
                styleKey += "_Blue";
                break;
            case TEAL:
                styleKey += "_Teal";
                break;
            case ORANGE:
                styleKey += "_Orange";
                break;
            case PINK:
                styleKey += "_Pink";
                break;
            case RED:
                styleKey += "_Red";
                break;
        }
        //        if (isDarkActionBar) styleKey += "_DarkActionBar";
        if (isNoActionBar) styleKey += "_NoActionBar";
        try {
            Field field = R.style.class.getField(styleKey);
            themeId = (int) field.get(R.style.class);
        } catch (NoSuchFieldException e) {
            Log.e(TAG, "NoSuchFieldException: " + e);
        } catch (IllegalAccessException e) {
            Log.e(TAG, "IllegalAccessException: " + e);
        } catch (IllegalArgumentException e) {
            Log.e(TAG, "IllegalArgumentException: " + e);
        }
        return themeId;
    }


    /**
     * 获取给用户显示的主题名称
     *
     * @param context   上下文
     * @param themeType 主题配色
     * @return 主题名称
     */
    public static String getThemeName(Context context, ThemeType themeType) {
        int index = themeType.ordinal();
        if (index != 0) {
            String[] names = context.getResources().getStringArray(R.array.jesse205_themes);
            return names[index];
        }

        return context.getString(R.string.jesse205_theme_default);
    }

    public boolean isMaterial3() {
        return themeStyle == ThemeStyle.Material3;
    }

    public boolean isMaterial2() {
        return themeStyle == ThemeStyle.Material2;
    }

    public void applyTheme() {
        applyTheme(false);
    }


    public void applyTheme(boolean isNoActionBar) {
        applyTheme(isNoActionBar, false, false);
    }

    public void applyTheme(boolean isNoActionBar, boolean useDarkStatusBar, boolean useDarkNavigationBar) {
        int themeId = getThemeId(context, themeType, themeStyle, isNoActionBar);
        context.setTheme(themeId);

        if (context instanceof Activity) {
            TypedArray array = context.getTheme().obtainStyledAttributes(new int[]{
                    R.attr.windowLightStatusBar,
                    R.attr.windowLightNavigationBar
            });

            boolean windowLightStatusBar = array.getBoolean(0, false);
            boolean windowLightNavigationBar = array.getBoolean(1, false);
            array.recycle();

            Window window = ((Activity) context).getWindow();
            WindowInsetsControllerCompat windowInsetsController =
                    WindowCompat.getInsetsController(window, window.getDecorView());
            if (!useDarkStatusBar && SDK_INT >= Build.VERSION_CODES.O && windowLightStatusBar) {
                windowInsetsController.setAppearanceLightStatusBars(true);
            }

            if (!useDarkNavigationBar && (SDK_INT >= Build.VERSION_CODES.M || ThemeUtil.isGrayNavigationBarSystem()) && windowLightNavigationBar) {
                windowInsetsController.setAppearanceLightNavigationBars(true);
                //  沉浸导航栏
                window.setNavigationBarColor(context.getResources().getColor(R.color.jesse205_system_window_scrim, context.getTheme()));
            }
        }
    }

    public boolean checkThemeChanged() {
        return appThemeType != themeType || appThemeStyle != themeStyle;
    }

    public enum ThemeType {
        BLUE, TEAL, ORANGE, PINK, RED
    }

    public enum ThemeStyle {
        Material1, Material2, Material3
    }
}
