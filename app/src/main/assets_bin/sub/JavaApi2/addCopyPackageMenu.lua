import "helper.CodeHelper"
local function addCopyPackageMenu(menu,class)
  CopyMenuUtil.addSubMenus(menu,{
    class:match(".*[%.$](.*)"),
    class,
    "L"..class:gsub("%.","/")..";",
    CodeHelper.getImportCode(class)})
end
return addCopyPackageMenu
