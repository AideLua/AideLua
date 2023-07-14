package com.jesse205.util;

import androidx.annotation.NonNull;

import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 有关字符串的一些工具
 * @author Jesse205
 *
 */
public class StringUtil {

	/**
	 * 获取字符串的MD5
	 * @param str 需要获取MD5值的字符串
	 * @return 获取到的MD5字符串
	 * @author Jesse205
	 */
    public static String getMd5(@NonNull String str) {
        byte[] digest = null;
        try {
            MessageDigest md5 = MessageDigest.getInstance("md5");
            digest  = md5.digest(str.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        //16是表示转换为16进制数
        return new BigInteger(1, digest).toString(16);
    }
}
