local MyTipLayout={}
local insertTable=require "com.jesse205.layout.insertTable"

MyTipLayout.layout={
  CardView;
  layout_width="fill";
  cardBackgroundColor=res.color.attr.rippleColorAccent;
  cardElevation=0;
  radius="4dp";
  {
    LinearLayoutCompat;
    layout_width="fill";
    layout_height="fill";
    gravity="left|center";
    padding="12dp";
    paddingTop="8dp";
    paddingBottom="8dp";
    {
      AppCompatImageView;
      layout_width="24dp";
      layout_height="24dp";
      layout_marginRight="12dp";
      colorFilter=res.color.attr.colorPrimary;
    };
    {
      AppCompatTextView;
      textColor=res.color.attr.colorPrimary;
    };
  };
}

function MyTipLayout.Builder(config)--返回布局表
  local layout=table.clone(MyTipLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyTipLayout.load(config,...)--返回视图
  return loadlayout2(MyTextInputLayout.Builder(config),...)
end
return MyTipLayout