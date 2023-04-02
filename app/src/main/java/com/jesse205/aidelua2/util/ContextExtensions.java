package com.jesse205.aidelua2.util;
import android.content.Context;
import android.content.res.TypedArray;
import com.jesse205.aidelua2.R;
import android.content.res.ColorStateList;

/**
 * @Author Jesse205
 * @Date 2023/03/28 04:53
 */
public class ContextExtensions {

    public static final String TAG = "ContextExtensions";

    public static boolean isMaterial3Theme(Context Context) {
        return getBooleanByAttr(Context, R.attr.isMaterial3Theme);
    }

    public static boolean getBooleanByAttr(Context context, int attr) {
        TypedArray typedArray= context.obtainStyledAttributes(new int[]{attr});
        boolean result=typedArray.getBoolean(0, false);
        typedArray.recycle();
        return result;
    }

    public static int getColorByAttr(Context context, int attr) {
        return getColorStateListByAttr(context, attr).getDefaultColor();
    }

    public static ColorStateList getColorStateListByAttr(Context context, int attr) {
        TypedArray typedArray= context.obtainStyledAttributes(new int[]{attr});
        ColorStateList result=typedArray.getColorStateList(0);
        typedArray.recycle();
        return result;

    }
}
