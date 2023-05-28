return {
    {
        name = "Lua 活动 (Activity)", --有enName时就是中文名，没enName时就是英文名
        enName = "Lua Activity",    --英文名
        id = "lua_activity",         --标识，用来排序
        fileExtension = "lua",      --扩展名
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
        fileExtension = "aly",
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

    {
        name = "Lua 布局 (Layout)（AndroidX）",
        enName = "Lua Layout (AndroidX)",
        d = "lua_layout_androidx",
        fileExtension = "aly",
        enabledVar = "oldAndroidXSupport",
        content = [[{
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

    {
        name = "Lua 表 (Table)",
        enName = "Lua Table",
        id = "lua_table",
        fileExtension = "aly",
        content = [[{

}]],
    },

    {
        name = "Lua 模块 (Module)",
        enName = "Lua Module",
        id = "lua_module",
        fileExtension = "lua",
        content = [[local {{ShoredModuleName}}={}
setmetatable({{ShoredModuleName}},{{ShoredModuleName}})
local metatable={__index={{ShoredModuleName}}}

function {{ShoredModuleName}}.__call(self)
  local self={}
  setmetatable(self,metatable)
  return self
end
return {{ShoredModuleName}}
]],
    },

    {
        name = "空 Lua 文件",
        enName = "Empty Lua File",
        id = "lua_empty",
        fileExtension = "lua",
        content = "",
    },

    {
        name = "空文件",
        enName = "Empty File",
        id = "emptyfile",
        fileExtension = "txt",
        content = "",
    },

}
