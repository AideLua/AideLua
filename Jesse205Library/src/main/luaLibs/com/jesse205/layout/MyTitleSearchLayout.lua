import "com.google.android.material.textfield.TextInputEditText"
import "com.google.android.material.textfield.TextInputLayout"
local insertTable=require "com.jesse205.layout.insertTable"

local MyTitleSearchLayout={}

MyTitleSearchLayout.layout={
  LinearLayout;
  layout_width="fill";
  layout_height="fill";
  {
    TextInputEditText;
    layout_width="fill";
    layout_height="fill";
    layout_weight=1;
    padding=0;
    id="searchEdit";
    imeOptions="actionSearch";
    backgroundColor=0;
    lines=1;
    inputType="text";
    textSize="18sp";
    theme=res.id.attr.actionSearchEditStyle;
    --textColor=theme.color.ActionBar.colorControlNormal;
    --hintTextColor=theme.color.ActionBar.textColorSecondary;
    gravity="center|left";
  };
  {
    ImageView;
    layout_width="48dp";
    layout_height="48dp";
    padding="12dp";
    imageResource=R.drawable.ic_close_circle_outline;
    id="clearSearchBtn";
    layout_gravity="center|right";
    colorFilter=theme.color.ActionBar.colorControlNormal;
    tooltip=getString(R.string.jesse205_clear);
  };
}

function MyTitleSearchLayout.Builder(config)--返回布局表
  local layout=table.clone(MyTitleSearchLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyTitleSearchLayout.load(config,...)--返回视图
  return loadlayout2(MyTitleSearchLayout.Builder(config),...)
end
return MyTitleSearchLayout