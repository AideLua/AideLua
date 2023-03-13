package com.jesse205.util;
import java.io.FileInputStream;
import java.nio.channels.FileChannel;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.FileNotFoundException;

/**
 * @Author Jesse205
 * @Date 2023/03/06 06:01
 * @Describe 文件工具类
 */
public class FileUtil {

    public static final String TAG = "FileUtil";

    public static void copyFile(FileChannel sourceChannel, FileChannel destChannel) throws IOException {
        long size = sourceChannel.size();
        for (long left = size; left > 0;) {
            // log.info("position:{},left:{}", size - left, left);
            left -= sourceChannel.transferTo((size - left), left, destChannel);
        }
    }

    public static void copyFile(FileInputStream sourceStream, FileOutputStream destStream) throws IOException {
        FileChannel sourceChannel = sourceStream.getChannel();
        FileChannel destChannel = destStream.getChannel();
        try {

            copyFile(sourceChannel, destChannel);
        } catch (IOException e) {
            throw e;
        } finally {
            sourceChannel.close();
            destChannel.close();
        }
    }

    public static void copyFile(File sourceFile, File destFile) throws FileNotFoundException, IOException {
        FileInputStream sourceInputStream = new FileInputStream(sourceFile);
        FileOutputStream destOutputStream = new FileOutputStream(destFile);
        try {
            copyFile(sourceInputStream, destOutputStream);
        } catch (IOException e) {
            throw e;
        } finally {
            sourceInputStream.close();
            destOutputStream.close();
        }
    }


}
