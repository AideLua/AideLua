return {
    editor = {
        LuaEditor = {
            keywordsList = {
                androluaKeywords = {
                    --一些事件
                    "onCreate", "onStart", "onResume", "onPause", "onStop", "onDestroy",
                    "onActivityResult", "onResult", "onCreateOptionsMenu", "onOptionsItemSelected",
                    "onTouchEvent", "onKeyLongPress", "onConfigurationChanged", "onHook",
                    "onAccessibilityEvent", "onKeyUp", "onKeyDown", "onError", "onVersionChanged",

                    "onClick", "onTouch", "onLongClick", "onItemClick", "onItemLongClick",
                    "onContextClick", "onScroll", "onScrollChange", "onNewIntent",
                    "onSaveInstanceState", "onBackPressed",

                    --一些自带的类或者包
                    "android", "R",
                },
            },
        }
    },
    fileTemplates = {
        {
            name = "Lua 活动 (Activity)", --有enName时就是中文名，没enName时就是英文名
            enName = "Lua Activity",    --英文名
            id = "lua_activity",        --标识，用来排序
            extensionName = "lua",      --扩展名
            --在 v5.1.0(51099) 改名为 content
            content = [[require "import"
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
            name = "Lua 布局 (Layout)",
            enName = "Lua Layout",
            id = "lua_layout",
            extensionName = "aly",
            content = [[{
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

    }

}
