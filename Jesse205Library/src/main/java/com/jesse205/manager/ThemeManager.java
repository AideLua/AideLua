package com.jesse205.manager;

/** 主题管理器
 *
 * @Author Jesse205
 * @Date 2023/02/21 01:11
 */
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.preference.PreferenceManager;
import com.jesse205.R;

public class ThemeManager {
    public static final String THEME_TYPE="theme_type";
    public static final String THEME_DARK_ACTION_BAR="theme_dark_action_bar";
    public static final String THEME_NO_ACTION_BAR="theme_no_action_bar";

    //一些可以定制的主题，用于替换默认蓝色的主题
    public static int defaultThemeNameId = R.string.jesse205_theme_default;
    public static int defaultThemeId = R.style.Theme_Jesse205_Default;
    public static int defaultNoActionBarThemeId = R.style.Theme_Jesse205_Default_NoActionBar;
    public static int defaultDarkActionBarThemeId = R.style.Theme_Jesse205_Default_DarkActionBar;
    public static int defaultDarkActionBarNoActionBarThemeId = R.style.Theme_Jesse205_Default_DarkActionBar_NoActionBar;
    private static ThemeType defaultAppTheme = ThemeType.DEFAULT;

    private ThemeType mThemeType;
    private boolean mIsDarkActionBar;
    private boolean mIsNoActionBar;
    private Context mContext;

    public ThemeManager(Context context) {
        mContext = context;
    }

    public static boolean isSystemNightMode(Context context) {
        return (context.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
	}

    public static void setDefaultTheme(Context context, ThemeType themeType) {
        SharedPreferences sharedPreferences= PreferenceManager.getDefaultSharedPreferences(context);
        if (sharedPreferences.getString(THEME_TYPE, null) == null) {
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putString(THEME_TYPE, themeType.name());
            editor.commit();
        }
        defaultAppTheme = themeType;
    }

    public static void setAppTheme(Context context, ThemeType themeType) {
        SharedPreferences sharedPreferences= PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(THEME_TYPE, themeType.name());
        editor.commit();
        //nowAppTheme = themeType;
    }

    public static ThemeType getAppTheme(Context context) {
        SharedPreferences sharedPreferences= PreferenceManager.getDefaultSharedPreferences(context);
        String themeTypeName=sharedPreferences.getString(THEME_TYPE, null);
        //return ThemeType.valueOf(themeTypeName);
        if (themeTypeName == null) {
            return defaultAppTheme;
        } else {
            return ThemeType.valueOf(themeTypeName);
        }
    }

    public static int getThemeId(Context context, ThemeType themeType, boolean isDarkActionBar, boolean isNoActionBar) {
        int themeId;
        if (isDarkActionBar) {
            if (isNoActionBar) {
                themeId = defaultDarkActionBarNoActionBarThemeId;
                switch (themeType) {
                    case TEAL:
                        themeId = R.style.Theme_Jesse205_Teal_DarkActionBar_NoActionBar;
                        break;
                    case ORANGE:
                        themeId = R.style.Theme_Jesse205_Orange_DarkActionBar_NoActionBar;
                        break;
                    case PINK:
                        themeId = R.style.Theme_Jesse205_Pink_DarkActionBar_NoActionBar;
                        break;
                    case RED:
                        themeId = R.style.Theme_Jesse205_Red_DarkActionBar_NoActionBar;
                        break;
                }
            } else {
                themeId = defaultDarkActionBarThemeId;
                switch (themeType) {
                    case TEAL:
                        themeId = R.style.Theme_Jesse205_Teal_DarkActionBar;
                        break;
                    case ORANGE:
                        themeId = R.style.Theme_Jesse205_Orange_DarkActionBar;
                        break;
                    case PINK:
                        themeId = R.style.Theme_Jesse205_Pink_DarkActionBar;
                        break;
                    case RED:
                        themeId = R.style.Theme_Jesse205_Red_DarkActionBar;
                        break;
                }
            }
        } else {
            if (isNoActionBar) {
                themeId = defaultNoActionBarThemeId;
                switch (themeType) {
                    case TEAL:
                        themeId = R.style.Theme_Jesse205_Teal_NoActionBar;
                        break;
                    case ORANGE:
                        themeId = R.style.Theme_Jesse205_Orange_NoActionBar;
                        break;
                    case PINK:
                        themeId = R.style.Theme_Jesse205_Pink_NoActionBar;
                        break;
                    case RED:
                        themeId = R.style.Theme_Jesse205_Red_NoActionBar;
                        break;
                }
            } else {
                themeId = defaultThemeId;
                switch (themeType) {
                    case TEAL:
                        themeId = R.style.Theme_Jesse205_Teal;
                        break;
                    case ORANGE:
                        themeId = R.style.Theme_Jesse205_Orange;
                        break;
                    case PINK:
                        themeId = R.style.Theme_Jesse205_Pink;
                        break;
                    case RED:
                        themeId = R.style.Theme_Jesse205_Red;
                        break;
                }
            }
        }
        return themeId;
    }

    public static String getThemeName(Context context, ThemeType themeType) {
        int strId=defaultThemeNameId;
        switch (themeType) {
            case TEAL:
                strId = R.string.jesse205_theme_teal;
                break;
            case ORANGE:
                strId = R.string.jesse205_theme_orange;
                break;
            case PINK:
                strId = R.string.jesse205_theme_pink;
                break;
            case RED:
                strId = R.string.jesse205_theme_red;
                break;
        }
        return context.getString(strId);
    }


    public ThemeType getThemeType() {
        return mThemeType;
    }

    public boolean getDarkActionBarState() {
        return mIsDarkActionBar;
    }

    public boolean getNoActionBarState() {
        return mIsNoActionBar;
    }

    public void applyTheme() {
        SharedPreferences sharedPreferences= PreferenceManager.getDefaultSharedPreferences(mContext);
        boolean isDarkActionBar=sharedPreferences.getBoolean(THEME_DARK_ACTION_BAR, false);
        boolean isNoActionBar=sharedPreferences.getBoolean(THEME_NO_ACTION_BAR, false);
        applyTheme(isDarkActionBar, isNoActionBar);
    }

    public void applyTheme(boolean isDarkActionBar, boolean isNoActionBar) {
        if (mThemeType == null)
            mThemeType = getAppTheme(mContext);
        int themeId = defaultThemeId;
        if (mThemeType == null) {

        } else {
            themeId = getThemeId(mContext, mThemeType, isDarkActionBar, isNoActionBar);
            mContext.setTheme(themeId);
        }
    }

    public enum ThemeType {
        DEFAULT,
        TEAL,
        ORANGE,
        PINK,
        RED
        }
}
