package com.jesse205.util;

import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 有关字符串的一些工具
 * @author Jesse205
 * @Time 2022-10-7 2:25
 *
 */
public class StringUtil {

	/**
	 * 获取字符串的MD5
	 * @param str 需要获取MD5值的字符串
	 * @return 获取到的MD5字符串
	 * @author Jesse205
	 * @Time 2022-10-7 2:25
	 */
    public static String getMd5(String str) {
        byte[] digest = null;
        try {
            MessageDigest md5 = MessageDigest.getInstance("md5");
            digest  = md5.digest(str.getBytes("utf-8"));
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        //16是表示转换为16进制数
        String md5Str = new BigInteger(1, digest).toString(16);
        return md5Str;
    }
}
