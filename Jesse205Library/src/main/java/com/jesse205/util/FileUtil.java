package com.jesse205.util;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.channels.FileChannel;

/**
 * 文件工具类
 *
 * @author Jesse205
 */
public class FileUtil {

    public static final String TAG = "FileUtil";

    public static void copyFile(@NonNull FileChannel sourceChannel, @NonNull FileChannel destChannel) throws IOException {
        long size = sourceChannel.size();
        for (long left = size; left > 0; ) {
            left -= sourceChannel.transferTo((size - left), left, destChannel);
        }
    }

    public static void copyFile(@NonNull FileInputStream sourceStream, @NonNull FileOutputStream destStream) throws IOException {
        try (FileChannel sourceChannel = sourceStream.getChannel(); FileChannel destChannel = destStream.getChannel()) {
            copyFile(sourceChannel, destChannel);
        }
    }

    public static void copyFile(@NonNull InputStream sourceStream, @NonNull OutputStream destStream) throws IOException {
        byte[] b = new byte[1024 * 5];
        int len;
        while ((len = sourceStream.read(b)) != -1) {
            destStream.write(b, 0, len);
        }
        destStream.flush();
    }

    public static void copyFile(@NonNull File sourceFile, @NonNull File destFile) throws IOException {
        try (FileInputStream sourceInputStream = new FileInputStream(sourceFile); FileOutputStream destOutputStream = new FileOutputStream(destFile)) {
            copyFile(sourceInputStream, destOutputStream);
        }
    }


}
