local MyEditDialogLayout={}
import "com.Jesse205.layout.insertTable"
local insertTable=insertTable

MyEditDialogLayout.layout=MyTextInputLayout.Builder{
  layout_margin="8dp";
  layout_width="fill";
  layout_marginLeft="24dp";
  layout_marginRight="24dp";
  id="editLay";
  {
    inputType="text";
    lines=1;
    id="edit";
    focusable=true;
  };
}



MyEditDialogLayout.insertTable=insertTable

function MyEditDialogLayout.Builder(config)
  local layout=table.clone(MyEditDialogLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyEditDialogLayout.load(config,...)
  return loadlayout({
    LinearLayout;
    layout_width="fill";
    layout_height="fill";
    MyEditDialogLayout.Builder(config);
  },...)
end
return MyEditDialogLayout