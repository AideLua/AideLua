local function showPackageMenu(name,view,mainLay)
  local pop=PopupMenu(activity,view)
  local menu=pop.Menu
  pop.inflate(R.menu.menu_javaapi_item_package)
  local copyNameMenu=menu.findItem(R.id.menu_copy_className)
  local copyClassPathMenu=menu.findItem(R.id.menu_copy_classPath)
  local copyClassPath2Menu=menu.findItem(R.id.menu_copy_classPath2)
  local copyImportMenu=menu.findItem(R.id.menu_copy_import)
  copyNameMenu.title=name:match(".+[%.$](.+)")
  copyClassPathMenu.title=name
  copyClassPath2Menu.title="L"..name:gsub("%.","/")..";"
  copyImportMenu.title=getImportCode(name)
  pop.show()
  pop.onMenuItemClick=function(item)
    local id=item.getItemId()
    if id==R.id.menu_copy_className
      or id==R.id.menu_copy_classPath
      or id==R.id.menu_copy_classPath2
      or id==R.id.menu_copy_import
      then
      MyToast.copyText(item.title,mainLay)
    end
  end
end
return showPackageMenu