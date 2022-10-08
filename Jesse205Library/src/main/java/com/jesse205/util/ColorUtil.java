package com.jesse205.util;

import android.graphics.Color;
/**
 * 有关颜色工具
 * @author Jesse205
 * @Time 2022-10-8 2:22
 *
 */

public class ColorUtil {

    /**
	 * 判断是否为亮色
	 * @param int 颜色值
	 * @return 是否亮色
	 * @author Jesse205
	 * @Time 2022-10-8 2:22
	 */
    public static boolean isLightColor(int color) {
        double darkness = 1 - (0.299 * Color.red(color) + 0.587 * Color.green(color) + 0.114 * Color.blue(color)) / 255;
        if (darkness < 0.5) {
            return true; // It's a light color
        } else {
            return false; // It's a dark color
        }
    }
}
