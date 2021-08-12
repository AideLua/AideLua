local AppBarLayout=luajava.bindClass "com.google.android.material.appbar.AppBarLayout"
local MaterialButton=luajava.bindClass "com.google.android.material.button.MaterialButton"
local widgets={
  MaterialButton={"TextButton","OutlinedButton","TextButton_Icon"},
}

local types={}
for mainWidget,content in pairs(widgets) do
  for index,content in ipairs(content) do
    local widgetName=mainWidget.."_"..content
    table.insert(types,widgetName)
    local myWidget={
      _baseClass=_ENV[mainWidget],
      __call=function(self,context)
        local iInflater=LayoutInflater.from(context)
        return iInflater.inflate(R.layout["layout_jesse205_"..string.lower(widgetName)],nil)
      end,
    }
    setmetatable(myWidget,myWidget)
    _G[widgetName]=myWidget
  end
end

return {types=types,widgets=widgets}