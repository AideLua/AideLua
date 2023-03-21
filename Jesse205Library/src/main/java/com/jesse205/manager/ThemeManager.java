package com.jesse205.manager;

/** 主题管理器
 *
 * @Author Jesse205
 * @Date 2023/02/21 01:11
 */
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.preference.PreferenceManager;
import android.view.View;
import com.jesse205.R;
import static android.os.Build.VERSION.SDK_INT;
import java.lang.reflect.Field;
import android.util.Log;
import com.jesse205.util.ThemeUtil;
import android.view.Window;

public class ThemeManager {
    private static final String TAG="ThemeManager";
    public static final String THEME_TYPE="theme_type";
    public static final String THEME_MATERIAL3="theme_material3";
    public static final String THEME_DARK_ACTION_BAR="theme_dark_action_bar";
    //public static final String THEME_NO_ACTION_BAR="theme_no_action_bar";

    private static ThemeType defaultAppTheme = ThemeType.BLUE;

    private ThemeType mThemeType;
    private boolean isDarkActionBar;
    private boolean isMaterial3;
    private Activity mContext;

    public ThemeManager(Activity context) {
        mContext = context;
    }

    public static void setDefaultTheme(Context context, ThemeType themeType) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        if (sharedPreferences.getString(THEME_TYPE, null) == null) {
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putString(THEME_TYPE, themeType.name());
            editor.commit();
        }
        defaultAppTheme = themeType;
    }

    public static void setAppTheme(Context context, ThemeType themeType) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(THEME_TYPE, themeType.name());
        editor.commit();
        //nowAppTheme = themeType;
    }

    public static ThemeType getAppTheme(Context context) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        String themeTypeName=sharedPreferences.getString(THEME_TYPE, null);
        //return ThemeType.valueOf(themeTypeName);

        if (themeTypeName == null) {
            return defaultAppTheme;
        } else {
            try {
                return ThemeType.valueOf(themeTypeName);
            } catch (IllegalArgumentException e) {
                Log.e(TAG, "IllegalArgumentException: " + e.toString());
                return defaultAppTheme;
            }
        }
    }

    public static int getThemeId(Context context, ThemeType themeType, boolean isDarkActionBar, boolean isNoActionBar, boolean isMaterial3) {
        if (isMaterial3)
            return R.style.Theme_Jesse205_Material3;//MD3只有这一个主题
        int themeId = R.style.Theme_Jesse205_Blue;
        String styleKey="Theme_Jesse205";

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
        if (isDarkActionBar)
            styleKey += "_DarkActionBar";
        if (isNoActionBar)
            styleKey += "_NoActionBar";
        try {
            Field field=R.style.class.getField(styleKey);
            themeId = (int) field.get(R.style.class);
        } catch (NoSuchFieldException e) {
            Log.e(TAG, "NoSuchFieldException: " + e.toString());
        } catch (IllegalAccessException e) {
            Log.e(TAG, "IllegalAccessException: " + e.toString());
        } catch (IllegalArgumentException e) {
            Log.e(TAG, "IllegalArgumentException: " + e.toString());
        }
        return themeId;
    }

    public static String getThemeName(Context context, ThemeType themeType) {
        int index=themeType.ordinal();
        if (index != 0) {
            String[] names=context.getResources().getStringArray(R.array.jesse205_themes);
            return names[index];
        }

        return context.getString(R.string.jesse205_theme_default);
    }


    public ThemeType getThemeType() {
        return mThemeType;
    }

    public static boolean getAppDarkActionBarState(Context context) {
        SharedPreferences sharedPreferences= PreferenceManager.getDefaultSharedPreferences(context);
        return sharedPreferences.getBoolean(THEME_DARK_ACTION_BAR, false);
    }

    public static boolean getAppMaterial3State(Context context) {
        SharedPreferences sharedPreferences= PreferenceManager.getDefaultSharedPreferences(context);
        return sharedPreferences.getBoolean(THEME_MATERIAL3, false);
    }

    public boolean getDarkActionBarState() {
        return isDarkActionBar;
    }

    public boolean getMaterial3State() {
        return isMaterial3;
    }

    public void applyTheme() {
        applyTheme(false);
    }

    public void applyTheme(boolean isNoActionBar) {
        applyTheme(getAppDarkActionBarState(mContext), isNoActionBar);
    }

    public void applyTheme(boolean isDarkActionBar, boolean isNoActionBar) {
        applyTheme(isDarkActionBar, isNoActionBar, false, false);
    }

    public void applyTheme(boolean isDarkActionBar, boolean isNoActionBar, boolean useDarkStatusBar, boolean useDarkNavigationBar) {
        applyTheme(isDarkActionBar, isNoActionBar, useDarkStatusBar, useDarkNavigationBar, getAppMaterial3State(mContext));
    }

    public void applyTheme(boolean isDarkActionBar, boolean isNoActionBar, boolean useDarkStatusBar, boolean useDarkNavigationBar, boolean useMaterial3) {
        this.isDarkActionBar = isDarkActionBar;
        this.isMaterial3 = useMaterial3;
        if (mThemeType == null)
            mThemeType = getAppTheme(mContext);
        int themeId = getThemeId(mContext, mThemeType, isDarkActionBar, isNoActionBar, useMaterial3);
        mContext.setTheme(themeId);

        TypedArray array = mContext.getTheme().obtainStyledAttributes(new int[]{
                                                                          R.attr.windowLightStatusBar,
                                                                          R.attr.windowLightNavigationBar,
                                                                      });
        boolean windowLightStatusBar = array.getBoolean(0, false);
        boolean windowLightNavigationBar = array.getBoolean(1, false);
        array.recycle();

        int systemUiVisibility=0;
        Window window=mContext.getWindow();
        View decorView=window.getDecorView();
        if (!useDarkStatusBar && SDK_INT >= 23 && windowLightStatusBar)
            systemUiVisibility |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;

        if (!useDarkNavigationBar && (SDK_INT >= 26 || ThemeUtil.isGrayNavigationBarSystem()) && windowLightNavigationBar) {
            if (SDK_INT >= 26)
                systemUiVisibility |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            window.setNavigationBarColor(mContext.getResources().getColor(R.color.jesse205_system_window_scrim));
        }
        decorView.setSystemUiVisibility(systemUiVisibility);
    }

    public boolean checkThemeChanged() {
        return isMaterial3 != getAppMaterial3State(mContext) || isDarkActionBar != getAppDarkActionBarState(mContext);
    }

    public enum ThemeType {
        BLUE,
        TEAL,
        ORANGE,
        PINK,
        RED;
    }
}
