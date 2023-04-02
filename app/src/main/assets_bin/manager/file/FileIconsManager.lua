--v5.2.0+
local isHiddenFilesMap=require "config.isHiddenFilesMap"
local fileIconColors=require "config.fileIconColors"
local fileSpecialColors=require "config.fileSpecialColors"

---文件图标管理器
local FileIconsManager={}
--判断是否隐藏文件的字典
FileIconsManager.isHiddenFilesMap=isHiddenFilesMap
--
FileIconsManager.fileIconColors=fileIconColors
--一些特殊文件图标的颜色
FileIconsManager.fileSpecialColors=fileSpecialColors


--[[
--图标相关
local extensionName2DrawableMap,selectableColorStateListsMap
local specialColorsMap, typeColorsMap, fileColorsMap, folderIconIds, folderIconColorState,
fileIconDrawables, specialIconDrawables
]]
--[[
---一些特殊的颜色，被fileSpecialColors取代
---@type table<string, number>
specialColorsMap = {
  normal = 0xff757575, -- 普通文件颜色
  active = res.color.attr.colorPrimary, -- 已打开文件颜色
  folder = 0xFFF9A825, -- 文件夹颜色
}
FileIconsManager.specialColorsMap = specialColorsMap
]]

--[[
---一类型的图标颜色
---@type table<string, number>
typeColorsMap = {
  android = 0xFF00E676,
  picture = 0xff448aff,
  music = 0xff9c27b0,
  video = 0xff4caf50,
  word = 0xff5c6bc0,
  ppt = 0xffff5722,
  xls = 0xff4caf50,
}

FileIconsManager.typeColorsMap = typeColorsMap
]]
--[[
--图标颜色
---@enum
fileColorsMap = {
  -- 按文件类型
  apk = typeColorsMap.android, -- 安卓应用程序
  apks = typeColorsMap.android,
  aab = typeColorsMap.android,
  hap = 0xff304ffe,
  exe = 0xff2979ff,
  lua = 0xff448aff,
  aly = 0xff29b6f6,
  png = typeColorsMap.picture, -- 图片文件
  jpg = typeColorsMap.picture,
  webp = typeColorsMap.picture,
  bmp = typeColorsMap.picture,
  tif = typeColorsMap.picture,
  mp4 = typeColorsMap.video, -- 音视频
  avi = typeColorsMap.video,
  mov = typeColorsMap.video,
  mpg = typeColorsMap.video,
  wav = typeColorsMap.music,
  mp3 = typeColorsMap.music,
  mid = typeColorsMap.music,
  xml = 0xffff6f00, -- xml文件
  svg = 0xffff6f00,
  dex = 0xff00bcd4,
  java = 0xff2962ff,
  kt = 0xff7c4dff,
  jar = 0xffe64a19,
  gradle = 0xff0097a7,
  md = res.color.attr.colorOnBackground,
  markdown = res.color.attr.colorOnBackground,
  html = 0xffff5722, --网页
  htm = 0xffff5722,
  css = 0xff1565c0,
  js = 0xfffbc02d,
  ts = 0xff1565c0,
  json = 0xffffa000,
  zip = 0xff795548, -- 压缩文件
  ["7z"] = 0xff795548,
  tar = 0xff795548,
  rar = 0xff795548,
  doc = typeColorsMap.word, --office
  docx = typeColorsMap.word,
  ppt = typeColorsMap.ppt,
  pptx = typeColorsMap.ppt,
  xls = typeColorsMap.xls,
  xlsx = typeColorsMap.xls,
  pdf = 0xfff44336,
  bat = res.color.attr.colorOnBackground,
  sh = res.color.attr.colorOnBackground,
}
FileIconsManager.fileColorsMap = fileColorsMap
]]
--[[
setmetatable(fileColorsMap, {
  __index = function(self, key)
    return specialColorsMap.normal
  end
})]]

--TODO: 这些迁移到单独的ColorStateMap
---@type table<number,ColorStateList>
selectableColorStateListsMap={}
FileIconsManager.selectableColorStateListsMap=selectableColorStateListsMap
setmetatable(selectableColorStateListsMap,{
  __index=function(self,defaultColor)
    local colorStateList = ColorStateList({
      { android.R.attr.state_selected },
      {}
    },
    {
      specialColors.active,
      defaultColor
    })
    rawset(self,defaultColor,colorStateList)
    return colorStateList
  end
})


function FileIconsManager.createFolderIconWitchBadge(badgeId, badgeWidth, badgeColor)
  local iconDrawable = specialIconDrawables.folder
  local badgeDrawable = activity.getDrawable(badgeId)
  if badgeColor then
    badgeDrawable.setTintList(ColorStateList.valueOf(badgeColor))
  end
  local background = LayerDrawable({ iconDrawable, badgeDrawable })
  background.setLayerGravity(0, Gravity.CENTER)
  background.setLayerGravity(1, Gravity.CENTER)
  local iconWidth = math.dp2int(24)
  local badgeWidth = badgeWidth or math.dp2int(14)

  background.setLayerSize(0, iconWidth, iconWidth)
  background.setLayerSize(1, badgeWidth, badgeWidth)
  background.setLayerInset(1, math.dp2int(2), math.dp2int(4), math.dp2int(2), math.dp2int(2))
  return background
end

--[[
--v5.1.2+
---创建图标的ColorStateList
function FileIconsManager.createIconColorStateList(defaultColor)
  local colorStateList = ColorStateList({
    { android.R.attr.state_selected },
    {}
  },
  { specialColors.active,
    defaultColor,
  })
  return colorStateList
end
]]

--[[
--v5.2.0+
---@type ColorStateList
folderIconColorState = ColorStateList({
  { android.R.attr.state_selected },
  {}
},
{ specialColors.active,
  specialColors.folder,
})]]

--[[
---@enum resId
---@type table<string,number>
folderIconIds = {
  res = rDrawable.ic_folder_table_outline,
}

--待添加到folderIconIds的表
local folderIconsIdsToBeAdded = {
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
for iconId, content in pairs(folderIconsIdsToBeAdded) do
  for index, name in pairs(content) do
    folderIconIds[name] = iconId
  end
end
folderIconsIdsToBeAdded=nil
]]
--v5.2.0+
--FilesBrowserManager.folderIconIds = folderIconIds

--一些需要单独拿出来的图标
---@enum
---@type table<string,Drawable>
specialIconDrawables = {
  folder = activity.getDrawable(rDrawable.ic_folder_outline).setTint(specialColorsMap.folder),
  unknowFile = activity.getDrawable(rDrawable.ic_file_outline),
}
specialIconDrawables.moduleFolder =
FileIconsManager.createFolderIconWitchBadge(R.drawable.ic_android, nil,typeColorsMap.android)

FileIconsManager.specialIconDrawables = specialIconDrawables


--v5.2.0+
local folderIconDrawables = {
  --空空如也
}

FileIconsManager.folderIconDrawables = folderIconDrawables

--自动根据folderIconIds获取drawable
setmetatable(folderIconDrawables, {
  __index = function(self, key)
    local iconId = folderIconIds[key]
    local drawable
    if iconId then
      drawable = activity.getDrawable(iconId).mutate()
      drawable.setTintList(folderIconColorState)
     else
      drawable = specialIconDrawables.folder.mutate()
    end
    rawset(self, key, drawable)
    return drawable
  end
})

local fileIconIds = {
  --各种文件的图标
  --Lua
  lua = R.drawable.ic_language_lua,
  luac = R.drawable.ic_language_lua,
  aly = R.drawable.ic_language_lua,
  --Java
  java = R.drawable.ic_language_java,
  kt = R.drawable.ic_language_kotlin,
  --Python
  py = R.drawable.ic_language_python,
  pyw = R.drawable.ic_language_python,
  pyc = R.drawable.ic_language_python,
  xml = R.drawable.ic_xml,
  json = R.drawable.ic_code_json,
  --网页
  html = R.drawable.ic_language_html5,
  htm = R.drawable.ic_language_html5,
  css = R.drawable.ic_language_css3,
  js = R.drawable.ic_language_javascript,
  ts = R.drawable.ic_language_typescript,
  --压缩类
  zip = R.drawable.ic_zip_box_outline,
  rar = R.drawable.ic_zip_box_outline,
  ["7z"] = R.drawable.ic_zip_box_outline,
  jar = R.drawable.ic_zip_box_outline,
  alp = R.drawable.ic_zip_box_outline,
  gradle = R.drawable.ic_language_gradle,
  --word类
  pdf = R.drawable.ic_file_pdf_outline,
  ppt = R.drawable.ic_file_powerpoint_outline,
  pptx = R.drawable.ic_file_powerpoint_outline,
  doc = R.drawable.ic_file_word_outline,
  docx = R.drawable.ic_file_word_outline,
  xls = R.drawable.ic_file_excel_outline,
  xlsx = R.drawable.ic_file_excel_outline,
  txt = R.drawable.ic_file_document_outline,
  md = R.drawable.ic_language_markdown_outline,
  markdown = R.drawable.ic_language_markdown_outline,
  --图片类
  png = R.drawable.ic_file_image_outline,
  jpg = R.drawable.ic_file_image_outline,
  gif = R.drawable.ic_file_image_outline,
  jpeg = R.drawable.ic_file_image_outline,
  webp = R.drawable.ic_file_image_outline,
  svg = R.drawable.ic_file_image_outline,
  bmp = R.drawable.ic_file_image_outline,
  tif = R.drawable.ic_file_image_outline,
  --音视频
  wav = R.drawable.ic_file_music_outline,
  mp3 = R.drawable.ic_file_music_outline,
  mid = R.drawable.ic_file_music_outline,
  mp4 = R.drawable.ic_file_video_outline,
  avi = R.drawable.ic_file_video_outline,
  mov = R.drawable.ic_file_video_outline,
  mpg = R.drawable.ic_file_video_outline,
  --安装包类
  apk = R.drawable.ic_android,
  apks = R.drawable.ic_android,
  aab = R.drawable.ic_android,
  hap = R.drawable.ic_all_application,
  exe = R.drawable.ic_windows,
  --终端脚本类(不包含py，lua)
  sh = R.drawable.ic_terminal,
  bat = R.drawable.ic_terminal,
}

--[[
setmetatable(fileIconIds,{__index=function(self,key)
    return R.drawable.ic_file_outline--默认是未知文件图标
end})]]
--v5.2.0+
FileIconsManager.fileIconIds = fileIconIds


---扩展名到Drawable，带色的，没有就自动通过id获取
---@type table<string,Drawable>
extensionName2DrawableMap={}
FileIconsManager.extensionName2DrawableMap=extensionName2DrawableMap


setmetatable(extensionName2DrawableMap, {
  __index = function(self, key)
    local iconId, drawable
    if key then
      iconId = fileIconIds[key]
    end
    if iconId then
      drawable = activity.getDrawable(iconId).mutate()
      drawable.setTintList(ColorStateList.valueOf(fileColorsMap[key]))
     else
      drawable = specialIconDrawables.unknowFile.mutate()
    end
    rawset(self, key, drawable)
    return drawable
  end
})


function FileIconsManager.init()
  --TODO: 初始化一些配置信息

end

return createVirtualClass(FileIconsManager)
