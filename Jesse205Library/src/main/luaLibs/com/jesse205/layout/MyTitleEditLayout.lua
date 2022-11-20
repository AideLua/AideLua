local MyTitleEditLayout={}
local insertTable=require "com.jesse205.layout.insertTable"

MyTitleEditLayout.layout={
  CardView;
  layout_width="fill";
  layout_height="40dp";
  cardBackgroundColor=theme.color.strokeColor;
  radius="8dp";
  {
    AppCompatEditText;
    layout_width="fill";
    layout_height="fill";
    padding=0;
    paddingLeft="8dp";
    paddingRight="8dp";
    id="searchEdit";
    imeOptions="actionSearch";
    backgroundColor=0;
    lines=1;
    inputType="text";
    --textIsSelectable=true;
    textSize="16sp";
    textColor=theme.color.ActionBar.colorControlNormal;
    hintTextColor=theme.color.ActionBar.textColorSecondary;
    gravity="center|left";
  }
}

function MyTitleEditLayout.Builder(config)--返回布局表
  local layout=table.clone(MyTitleEditLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyTitleEditLayout.load(config,...)--返回视图
  return loadlayout2(MyTitleEditLayout.Builder(config),...)
end
return MyTitleEditLayout