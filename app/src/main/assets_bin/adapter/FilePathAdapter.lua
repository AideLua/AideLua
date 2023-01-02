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
      if position+1==length then
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
      local iconView=ids.icon
      titleView.setBackground(ThemeUtil.getRippleDrawable(theme.color.ActionBar.rippleColorPrimary,true))
      titleView.onClick=onClick
      titleView.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL))

      if viewType==1 then
        iconView.setVisibility(View.GONE)
        titleView.getPaint().setFakeBoldText(true)
        if oldDarkActionBar then
          titleView.setTextColor(theme.color.ActionBar.colorControlNormal)
         else
          titleView.setTextColor(theme.color.colorAccent)
        end
       else
        titleView.setTextColor(theme.color.ActionBar.textColorSecondary)
        iconView.setAlpha(Color.alpha(theme.color.ActionBar.textColorSecondary)/255)
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data=pathSplitList[position+1]
      local view=holder.view
      local tag=view.getTag()
      local titleView=tag.title
      local iconView=tag.icon
      local text,path=data[1],data[2]
      titleView.setText(text)
      titleView.setTag(path)
    end,
  }))

end