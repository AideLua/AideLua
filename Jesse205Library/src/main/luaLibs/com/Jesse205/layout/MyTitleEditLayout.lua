local MyTitleEditLayout={}
import "com.Jesse205.layout.insertTable"
local insertTable=insertTable

MyTitleEditLayout.layout={
  AppCompatEditText;
  layout_width="fill";
  padding=0;
  id="searchEdit";
  imeOptions="actionSearch";
  backgroundColor=0;
  lines=1;
  inputType="text";
  textIsSelectable=true;
  layout_height="48dp";
  textSize="18sp";
  textColor=theme.color.ActionBar.colorControlNormal;
  hintTextColor=theme.color.ActionBar.textColorSecondary;
  gravity="center|left";
}

MyTitleEditLayout.insertTable=insertTable

function MyTitleEditLayout.Builder(config)
  local layout=table.clone(MyTitleEditLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyTitleEditLayout.load(config,...)
  return loadlayout(MyTitleEditLayout.Builder(config),...)
end
return MyTitleEditLayout