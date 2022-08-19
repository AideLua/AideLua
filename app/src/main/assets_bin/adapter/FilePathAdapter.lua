local pathSplitList=FilesBrowserManager.pathSplitList
local function onClick(view)
  FilesBrowserManager.refresh(File(view.tag))
end

local length=0
return function(item)
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      length=#pathSplitList
      return length
    end,
    getItemViewType=function(position)
      if position==length-1 then
        return 1
       else
        return 0
      end
    end,
    onCreateViewHolder=function(parent,viewType)
      local ids={}
      local view=loadlayout2(item,ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      local titleView=ids.title

      titleView.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary))
      titleView.onClick=onClick
      --view.onLongClick=onLongClick
      titleView.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL))

      if viewType==1 then
        titleView.setTextColor(theme.color.colorAccent)
        ids.icon.setVisibility(View.GONE)
        titleView.getPaint().setFakeBoldText(true)
        --titleView.getPaint().setTypeface(Typeface.DEFAULT_BOLD)
       else
        --titleView.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD))
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data=pathSplitList[position+1]
      local view=holder.view
      local tag=view.getTag()
     
      local titleView=tag.title
      local iconView=tag.icon
      titleView.setText(data[1])
      titleView.setTag(data[2])
    end,
  }))

end