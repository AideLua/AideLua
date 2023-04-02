--R.drawable简写
local rDrawable=R.drawable

---一些文件和文件夹图标
local fileIcons={}

---通过文件名获取图标<br>
---getter回退 通过文件名获取资源后动态添加drawable<br>
---getter回退 通过扩展名获取图标<br>
---getter回退 文件默认图标
---@type table<string,Drawable>
local fileIconDrawableMapByName={}

---通过文件夹名获取图标<br>
---getter回退 通过文件夹名获取资源后动态添加drawable<br>
---getter回退 默认文件夹图标
---@type table<string,Drawable>
local folderIconDrawableMapByName={}

---通过文件名获取图标id
---getter回退 默认文件图标id
---@enum resId
---@type table<string,number>
local folderIconIdsMapByName = {
  res = rDrawable.ic_folder_table_outline,
}

--待添加到folderIconIds的表，之后要应该被回收
---@type table<number,string[]>
local folderIconIdsMapByNameToBeAdded = {
  [rDrawable.ic_folder_cog_outline] = {
    ".git", ".github", ".gradle", ".idea", ".vscode", ".obsidian", ".androidide",
    "build", "wrapper", "gradle", "node_modules",
    ".aidelua" },
  [rDrawable.ic_folder_key_outline]={
    "key","keys" },
  [rDrawable.ic_folder_home_outline]={
    "assets_bin","assets" },
  [rDrawable.ic_folder_text_outline]={
    "docs","doc" }
}

--将folderIconsToBeAdded添加到folderIconIds
for iconId, content in pairs(folderIconIdsMapByNameToBeAdded) do
  for index, name in pairs(content) do
    folderIconIdsMapByName[name] = iconId
  end
end
folderIconIdsMapByNameToBeAdded=nil



fileIcons.fileIconDrawableMapByName=fileIconDrawableMapByName
fileIcons.folderIconDrawableMapByName=folderIconDrawableMapByName

fileIcons.folderIconIdsMapByName=folderIconIdsMapByName

return fileIcons