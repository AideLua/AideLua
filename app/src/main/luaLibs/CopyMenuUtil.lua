local CopyMenuUtil={}
function itemOnClick(item)
  MyToast.copyText(item.title)
end

local function addSubMenu(menuBuilder,text)
  menuBuilder.add(text).onMenuItemClick=itemOnClick
end
local function addSubMenus(menuBuilder,textList)
  for index=1,#textList do
    addSubMenu(menuBuilder,textList[index])
  end
end
CopyMenuUtil.addSubMenu=addSubMenu
CopyMenuUtil.addSubMenus=addSubMenus
return CopyMenuUtil
