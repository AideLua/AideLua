return {--在 v5.1.0(51099) 添加
  {
    name="普通 Activity",--有enName时就是中文名，没enName时就是英文名
    enName="Normal Activity",--英文名
    id="activity",--标识
    files={
      {
        name="main.lua",
        content=[[require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

--activity.setTitle("{{ModuleName}}")
activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getActionBar()
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

]],
      },
      {
        name="init.lua",
        content=[[appname="{{ModuleName}}"
]],
      },
      {
        name="layout.aly",
        content=[[{
  LinearLayout;
  layout_height="fill";
  layout_width="fill";
  orientation="vertical";
  {
    TextView;
    gravity="center";
    text="Hello World";
    layout_height="fill";
    layout_width="fill";
  };
}]],
      },
    },
  },
  {
    name="普通 Activity (AndroidX)",
    enName="Normal Activity (AndroidX)",
    id="activity_androidx",
    enabledVar="oldAndroidXSupport",
    files={
      {
        name="main.lua",
        content=[[require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

--activity.setTitle("{{ModuleName}}")
activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getActionBar()
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

]],
      },
      {
        name="init.lua",
        content=[[appname="{{ModuleName}}"
]],
      },
      {
        name="layout.aly",
        content=[[{
  CoordinatorLayout;
  layout_height="fill";
  layout_width="fill";
  id="mainLay";
  {
    TextView;
    gravity="center";
    text="Hello World";
    layout_height="fill";
    layout_width="fill";
  };
}]],
      },
    },
  },
  {
    name="普通 Activity (Jesse205)",
    enName="Normal Activity (Jesse205)",
    id="activity_jesse205",
    enabledVar="oldJesse205Support",
    files={
      {
        name="main.lua",
        content=[[require "import"
import "jesse205"

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  
})

onConfigurationChanged(activity.getResources().getConfiguration())

]],
      },
      {
        name="init.lua",
        content=[[appname="{{ModuleName}}"
]],
      },
      {
        name="layout.aly",
        content=[[{
  CoordinatorLayout;
  layout_height="fill";
  layout_width="fill";
  id="mainLay";
  {
    TextView;
    gravity="center";
    text="Hello World";
    layout_height="fill";
    layout_width="fill";
  };
}]],
      },
    },
  },
  {
    name="设置 Activity",
    enName="Settings Activity",
    id="settings",
    files={
      {
        name="main.lua",
        content=[[require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.preference.*"
import "settings"

--activity.setTitle("{{ModuleName}}")
activity.setTheme(R.style.AppTheme)
actionBar=activity.getActionBar()
actionBar.setDisplayHomeAsUpEnabled(true) 

fragment=LuaPreferenceFragment(settings)
activity.setFragment(fragment)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

fragment.onPreferenceClick=function(preference)
  local key=preference.getKey()
  print("onPreferenceClick",key)
end

fragment.onPreferenceChange=function(preference)
  local key=preference.getKey()
  print("onPreferenceChange",key)
end

]],
      },
      {
        name="init.lua",
        content=[[appname="{{ModuleName}}"
]],
      },
      {
        name="settings.aly",
        content=[[{
  {
    PreferenceCategory;
    title="Title1";
  };
  {
    Preference;
    title="Item1";
    summary="Summary1";
    key="item1";
  };
  {
    SwitchPreference;
    title="Item2";
    summary="Summary2";
    key="item2";
  };
  {
    PreferenceCategory;
    title="Title2";
  };
  {
    EditTextPreference;
    title="Item3";
    summary="Summary3";
    dialogTitle="Item3";
    key="item3";
  };
}]],
      },
    },
  },
  {
    name="设置 Activity (Jesse205)",
    enName="Settings Activity (Jesse205)",
    id="settings_jesse205",
    enabledVar="oldJesse205Support",
    files={
      {
        name="main.lua",
        content=[[ require "import"
initApp=true
import "jesse205"
local normalkeys=jesse205.normalkeys
normalkeys.configType=true
normalkeys.config=true

import "com.jesse205.layout.util.SettingsLayUtil"
import "com.jesse205.layout.innocentlayout.RecyclerViewLayout"
import "com.jesse205.app.dialog.EditDialogBuilder"

import "settings"

activity.setTitle(R.string.settings)
activity.setContentView(loadlayout2(RecyclerViewLayout))

actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onItemClick(view,views,key,data)
  local action=data.action
  if key=="about" then
    newSubActivity("About")
   else
    if action=="editString" then
      EditDialogBuilder.settingDialog(adapter,views,key,data)
     elseif action=="singleChoose" then
      AlertDialog.Builder(activity)
      .setTitle(data.title)
      .setSingleChoiceItems(data.items,getSharedData(key) or 0,function(dialog,which)
        setSharedData(key,which)
        dialog.dismiss()
        adapter.notifyDataSetChanged()
      end)
      .show()
    end
  end
end

adapter=SettingsLayUtil.newAdapter(settings,onItemClick)
recyclerView.setAdapter(adapter)
layoutManager=LinearLayoutManager()
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled=function(view,dx,dy)
    MyAnimationUtil.RecyclerView.onScroll(view,dx,dy)
  end
})
recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
  onGlobalLayout=function()
    if activity.isFinishing() then
      return
    end
    MyAnimationUtil.RecyclerView.onScroll(recyclerView,0,0)
  end
})
mainLay.onTouch=function(view,...)
  recyclerView.onTouchEvent(...)
end

mainLay.ViewTreeObserver
.addOnGlobalLayoutListener(ScreenFixUtil.LayoutListenersBuilder.listViews(mainLay,{recyclerView}))
]],
      },
      {
        name="init.lua",
        content=[[appname="{{ModuleName}}"
]],
      },
      {
        name="settings.aly",
        content=[[{
  {--软件
    SettingsLayUtil.TITLE;
    title=R.string.jesse205_app;
  };
  {
    SettingsLayUtil.ITEM_NOSUMMARY;
    icon=R.drawable.ic_information_outline;
    title=R.string.jesse205_about;
    key="about";
    newPage=true;
  };
}]],
      },
    },
  },
}