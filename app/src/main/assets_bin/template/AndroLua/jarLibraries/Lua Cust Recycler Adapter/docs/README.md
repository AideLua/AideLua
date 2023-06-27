# Lua 自定义回收视图适配器

```
local item={
  TextView;
  layout_width="full";
}
local data={"apple","banana"}--数据
LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount=function()
    return #data
  end,
  getItemViewType=function(position)
    return 0--视图类型。如果不关心这个，随便给一个整数就行
  end,
  onCreateViewHolder=function(parent,viewType)
    local ids={}
    local view=loadlayout(item,ids)
    local holder=LuaCustRecyclerHolder(view)
    view.setTag(ids)
    return holder
  end,
  onBindViewHolder=function(holder,position)
    local data=pathSplitList[position+1]
    local view=holder.view
    local tag=view.getTag()
    view.setText(data)
  end,
}))
```