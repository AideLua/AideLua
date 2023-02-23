local pathSplitList=FilesBrowserManager.pathSplitList

local mediumTypeface=Typeface.create("sans-serif-medium", Typeface.NORMAL)
local function onClick(view)
  FilesBrowserManager.refresh(File(view.tag))
end

local actionBarRes=res(res.id.attr.actionBarTheme)

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
      titleView.setTypeface(mediumTypeface)

      if viewType==1 then
        iconView.setVisibility(View.GONE)
        titleView.getPaint().setFakeBoldText(true)
        if oldDarkActionBar then
          --theme.color.ActionBar.colorControlNormal
          titleView.setTextColor(actionBarRes.color.attr.colorOnPrimary)
         else
          titleView.setTextColor(actionBarRes.color.attr.colorPrimary)
        end
       else
        titleView.setTextColor(android.res(res.id.attr.actionBarTheme).color.attr.textColorSecondary)
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data=pathSplitList[position+1]
      local view=holder.view
      local tag=view.getTag()
      --[[
      local titleView=tag.title
      local iconView=tag.icon
      local text,path=data[1],data[2]
      titleView.setText(text)
      titleView.setTag(path)]]
      local titleView=tag.title
      titleView.setText(data[1])
      titleView.setTag(data[2])
    end,
  }))

end