import "com.google.android.material.textfield.TextInputEditText"
import "com.google.android.material.textfield.TextInputLayout"
local insertTable=require "com.jesse205.layout.insertTable"

local MyTextInputLayout={}

MyTextInputLayout.layout={
  TextInputLayout;
  theme=R.style.Widget_MaterialComponents_TextInputLayout_OutlinedBox_Dense;
  {
    TextInputEditText;
    layout_width="fill";
    layout_height="fill";
    theme=R.style.Widget_MaterialComponents_TextInputLayout_OutlinedBox_Dense;
  };
}

function MyTextInputLayout.Builder(config)
  local layout=table.clone(MyTextInputLayout.layout)
  if config then
    insertTable(layout,config)
  end
  return layout
end

function MyTextInputLayout.load(config,...)
  return loadlayout2(MyTextInputLayout.Builder(config),...)
end
return MyTextInputLayout