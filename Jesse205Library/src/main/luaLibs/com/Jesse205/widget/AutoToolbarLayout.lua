import "com.google.android.material.appbar.AppBarLayout"

local AutoToolbarLayout={
  _baseClass=AppBarLayout,
  __call=function(self,context)
    local iInflater=LayoutInflater.from(context)
    local view=iInflater.inflate(R.layout.layout_jesse205_autotoolbarlayout,nil)
    return view
  end,
}
setmetatable(AutoToolbarLayout,AutoToolbarLayout)
return AutoToolbarLayout