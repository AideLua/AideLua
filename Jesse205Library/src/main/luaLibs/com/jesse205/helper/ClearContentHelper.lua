local ClearContentHelper={}

local function onTextChangedListener(text,clearButton)
  if text and text~="" then
    clearButton.setVisibility(View.VISIBLE)
   else
    clearButton.setVisibility(View.GONE)
  end
end

function ClearContentHelper.setupEditor(editText,clearButton,color)
  editText.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      onTextChangedListener(tostring(text),clearButton)
    end
  })
  onTextChangedListener(editText.text,clearButton)
  clearButton.onClick=function()
    editText.setText("")
  end
  if color then
    local drawable=ThemeUtil.getRippleDrawable(color)
    if Build.VERSION.SDK_INT>=23 then
      drawable.setRadius(math.dp2int(20))
    end
    clearButton.setBackground(drawable)
  end
end

return ClearContentHelper
