local function addCopyPackageMenu(menu,class)
      CopyMenuUtil.addSubMenus(menu,{
      class:match(".*[%.$](.*)"),
      class,
      "L"..class:gsub("%.","/")..";",
      getImportCode(class)})

end
return addCopyPackageMenu
