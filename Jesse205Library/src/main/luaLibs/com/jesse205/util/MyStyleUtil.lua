local MyStyleUtil={}

function MyStyleUtil.applyToSwipeRefreshLayout(view)
  view.setProgressBackgroundColorSchemeColor(res.color.attr.colorBackgroundFloating)
  view.setColorSchemeColors(int{res.color.attr.colorPrimary})
  return view
end

return MyStyleUtil
