package com.Jesse205.superlua;

import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import java.io.File;
public class LuaActivity extends com.androlua.LuaActivity {
    private long oldLastTime=0;
    private long lastTime=0;
    private boolean checkUpdate=false;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        if (checkUpdate){
            try {
                PackageInfo packageInfo = getPackageManager().getPackageInfo(this.getPackageName(), 0);
                lastTime = packageInfo.lastUpdateTime;//更新时间
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
            SharedPreferences info = getSharedPreferences("appInfo", 0);
            oldLastTime = info.getLong("lastUpdateTime", 0);
            if (oldLastTime != lastTime)
                setDebug(false);
        }

        super.onCreate(savedInstanceState);

        if (checkUpdate && (oldLastTime != lastTime)) {
            Intent intent = new Intent(this, Welcome.class);
            intent.putExtra("newIntent", getIntent());
            startActivity(intent);
            finish();
        }

    }
    
    public void setCheckUpdate(boolean state) {
        checkUpdate=state;
    }
    

    @Override
    public void onSaveInstanceState(Bundle outState) {
        // TODO: Implement this method
        super.onSaveInstanceState(outState);
        runFunc("onSaveInstanceState", outState);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        // TODO: Implement this method
        super.onRestoreInstanceState(savedInstanceState);
        runFunc("onRestoreInstanceState", savedInstanceState);
    }
    
    public void newActivity(String path, boolean newDocument) {
        newActivity(1, path, null, newDocument);
    }

    public void newActivity(String path, Object[] arg, boolean newDocument) {
        newActivity(1, path, arg, newDocument);
    }

    public void newActivity(int req, String path, boolean newDocument) {
        newActivity(req, path, null, newDocument);
    }

    public void newActivity(String path) {
        newActivity(1, path, null);
    }

    public void newActivity(String path, Object[] arg) {
        newActivity(1, path, arg);
    }

    public void newActivity(int req, String path) {
        newActivity(req, path, null);
    }

    public void newActivity(int req, String path, Object[] arg) {
        newActivity(req, path, arg, false);
    }

    public void newActivity(int req, String path, Object[] arg, boolean newDocument) {
        Intent intent = new Intent(this, LuaActivity.class);
        if (newDocument)
            intent = new Intent(this, LuaActivityX.class);

        intent.putExtra("name", path);
        if (path.charAt(0) != '/')
            path = this.getLuaDir() + "/" + path;
        File f = new File(path);
        if (f.isDirectory() && new File(path + "/main.lua").exists())
            path += "/main.lua";
        else if ((f.isDirectory() || !f.exists()) && !path.endsWith(".lua"))
            path += ".lua";

        if (newDocument) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_DOCUMENT);
                intent.addFlags(Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
            }
        }

        intent.setData(Uri.parse("file://" + path));

        if (arg != null)
            intent.putExtra("arg", arg);
        if (newDocument)
            startActivity(intent);
        else
            startActivityForResult(intent, req);
        //overridePendingTransition(android.R.anim.slide_in_left, android.R.anim.slide_out_right);
    }

    public void newActivity(String path, int in, int out, boolean newDocument) {
        newActivity(1, path, in, out, null, newDocument);
    }

    public void newActivity(String path, int in, int out, Object[] arg, boolean newDocument) {
        newActivity(1, path, in, out, arg, newDocument);
    }

    public void newActivity(int req, String path, int in, int out, boolean newDocument) {
        newActivity(req, path, in, out, null, newDocument);
    }

    public void newActivity(String path, int in, int out) {
        newActivity(1, path, in, out, null);
    }

    public void newActivity(String path, int in, int out, Object[] arg) {
        newActivity(1, path, in, out, arg);
    }

    public void newActivity(int req, String path, int in, int out) {
        newActivity(req, path, in, out, null);
    }

    public void newActivity(int req, String path, int in, int out, Object[] arg) {
        newActivity(req, path, in, out, arg, false);
    }

    public void newActivity(int req, String path, int in, int out, Object[] arg, boolean newDocument) {
        Intent intent = new Intent(this, LuaActivity.class);
        if (newDocument)
            intent = new Intent(this, LuaActivityX.class);
        intent.putExtra("name", path);
        if (path.charAt(0) != '/')
            path = this.getLuaDir() + "/" + path;
        File f = new File(path);
        if (f.isDirectory() && new File(path + "/main.lua").exists())
            path += "/main.lua";
        else if ((f.isDirectory() || !f.exists()) && !path.endsWith(".lua"))
            path += ".lua";
        intent.setData(Uri.parse("file://" + path));

        if (newDocument) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_DOCUMENT);
                intent.addFlags(Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
            }
        }


        if (arg != null)
            intent.putExtra("arg", arg);
        if (newDocument)
            startActivity(intent);
        else
            startActivityForResult(intent, req);
        overridePendingTransition(in, out);

    }

}
