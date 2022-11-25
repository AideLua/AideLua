local MyCardTitleEditLayout={}
local insertTable=require "com.jesse205.layout.insertTable"

MyCardTitleEditLayout.layout={
  CardView;
  layout_width="fill";
  layout_height="40dp";
  cardBackgroundColor=theme.color.ActionBar.cardBackgroundColor;
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
    textSize="16sp";
    textColor=theme.color.ActionBar.colorControlNormal;
    hintTextColor=theme.color.ActionBar.textColorSecondary;
    gravity="center|left";
  }
}

function MyCardTitleEditLayout.Builder(config)--返回布局表
  local layout=table.clone(MyCardTitleEditLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyCardTitleEditLayout.load(config,...)--返回视图
  return loadlayout2(MyCardTitleEditLayout.Builder(config),...)
end
return MyCardTitleEditLayout