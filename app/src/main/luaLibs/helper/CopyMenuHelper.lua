---@class CopyMenuHelper
local CopyMenuHelper = {}

---点击事件，点击时复制菜单上的文字
local function itemOnClick(item)
    MyToast.copyText(item.title)
end

local function addSubMenu(menuBuilder, text)
    menuBuilder.add(text).onMenuItemClick = itemOnClick
end
local function addSubMenus(menuBuilder, textList)
    for index = 1, #textList do
        addSubMenu(menuBuilder, textList[index])
    end
end
CopyMenuHelper.addSubMenu = addSubMenu
CopyMenuHelper.addSubMenus = addSubMenus
return CopyMenuHelper
