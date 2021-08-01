local MyStyleUtil={}

function MyStyleUtil.appliedToSwipeRefreshLayout(view)
  view.setProgressBackgroundColorSchemeColor(theme.color.colorBackgroundFloating)
  view.setColorSchemeColors(int{theme.color.colorAccent})
  return view
end
return MyStyleUtil
