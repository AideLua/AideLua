package com.jesse205.superlua;
import com.androlua.LuaBroadcastReceiver;
import androidx.fragment.app.Fragment;
import com.androlua.LuaContext;
import com.androlua.LuaApplication;
import android.os.Bundle;
import android.content.Intent;
import android.content.Context;
import java.util.Map;
import java.util.ArrayList;
import com.luajava.LuaState;
import com.androlua.LuaGcable;
import com.androlua.LuaDexLoader;

public class LuaFragment2 extends Fragment  implements LuaBroadcastReceiver.OnReceiveListener, LuaContext {
    private LuaDexLoader mLuaDexLoader;
    
    public LuaApplication getApplication(){
        return (LuaApplication) getContext().getApplicationContext();
    }

    public LuaFragment2(String luaPath) {


    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mLuaDexLoader = new LuaDexLoader(this);
        mLuaDexLoader.loadLibs();
    }
    
    
    @Override
    public void call(String p1, Object[] p2) {
    }

    @Override
    public Object doFile(String p1, Object[] p2) {
        return null;
    }

    @Override
    public ArrayList<ClassLoader> getClassLoaders() {
        return mLuaDexLoader.getClassLoaders();
  }

    @Override
    public Map getGlobalData() {
        return null;
    }

    @Override
    public int getHeight() {
        return 0;
    }

    @Override
    public String getLuaCpath() {
        return null;
    }

    @Override
    public String getLuaDir() {
        return null;
    }

    @Override
    public String getLuaDir(String p1) {
        return null;
    }

    @Override
    public String getLuaExtDir() {
        return null;
    }

    @Override
    public String getLuaExtDir(String p1) {
        return null;
    }

    @Override
    public String getLuaExtPath(String p1) {
        return null;
    }

    @Override
    public String getLuaExtPath(String p1, String p2) {
        return null;
    }

    @Override
    public String getLuaLpath() {
        return null;
    }

    @Override
    public String getLuaPath() {
        return null;
    }

    @Override
    public String getLuaPath(String p1) {
        return null;
    }

    @Override
    public String getLuaPath(String p1, String p2) {
        return null;
    }

    @Override
    public LuaState getLuaState() {
        return null;
    }

    @Override
    public Object getSharedData() {
        return null;
    }

    @Override
    public Object getSharedData(String p1) {
        return null;
    }

    @Override
    public Object getSharedData(String p1, Object p2) {
        return null;
    }

    @Override
    public int getWidth() {
        return 0;
    }

    @Override
    public void regGc(LuaGcable p1) {
    }

    @Override
    public void sendError(String p1, Exception p2) {
    }

    @Override
    public void sendMsg(String p1) {
    }

    @Override
    public void set(String p1, Object p2) {
    }

    @Override
    public void setLuaExtDir(String p1) {
    }

    @Override
    public boolean setSharedData(String p1, Object p2) {
        return false;
    }

    @Override
    public void onReceive(Context p1, Intent p2) {
    }
    
    public long test(String src, int n) {
        return ((LuaActivity) getActivity()).test(src,n);
    }
}
