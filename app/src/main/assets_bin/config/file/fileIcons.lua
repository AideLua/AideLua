--R.drawable简写
local rDrawable = R.drawable

local fileIcons = {}



---通过文件夹名获取图标<br>
---getter回退 通过文件夹名获取资源后动态添加drawable<br>
---getter回退 默认文件夹图标
---@type table<string,Drawable>
local folderIconDrawableMapByName = {}

---通过文件夹名获取图标id<br>
---getter回退 默认文件夹图标id
---@enum resId
---@type table<string,number>
local folderIconIdsMapByName = {
    res = rDrawable.ic_folder_table_outline,
}

--region 批量添加图标到folderIconIdsMapByName
--待添加到folderIconIds的表，之后要应该被回收
---@type table<number,string[]>
local _folderIconIdsMapByNameToBeAdded = {
    [rDrawable.ic_folder_cog_outline] = {
        ".git", ".github", ".gradle", ".idea", ".vscode", ".obsidian", ".androidide",
        "build", "wrapper", "gradle", "node_modules",
        ".aidelua" },
    [rDrawable.ic_folder_key_outline] = {
        "key", "keys" },
    [rDrawable.ic_folder_home_outline] = {
        "assets_bin", "assets" },
    [rDrawable.ic_folder_text_outline] = {
        "docs", "doc" }
}

--将folderIconsToBeAdded添加到folderIconIds
for iconId, content in pairs(_folderIconIdsMapByNameToBeAdded) do
    for index, name in pairs(content) do
        folderIconIdsMapByName[name] = iconId
    end
end
_folderIconIdsMapByNameToBeAdded = nil
--endregion


fileIcons.folderIconDrawableMapByName = folderIconDrawableMapByName
fileIcons.folderIconIdsMapByName = folderIconIdsMapByName

---通过文件名获取图标<br>
---getter回退 通过文件名获取资源后动态添加drawable<br>
---getter回退 通过扩展名获取图标<br>
---getter回退 文件默认图标
---@type table<string,Drawable>
local fileIconDrawableMapByName = {}

---通过文件名获取图标id<br>
---getter回退 通过扩展名获取图标id<br>
---getter回退 默认文件图标id
---@type table<string,number>
local fileIconIdsMapByName = {}

---通过扩展名获取图标id<br>
---getter回退 默认文件图标id
---@type table<string,number>
local fileIconIdsMapByExtensionName = {
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

fileIcons.fileIconDrawableMapByName = fileIconDrawableMapByName
fileIcons.fileIconIdsMapByName = fileIconIdsMapByName
fileIcons.fileIconIdsMapByExtensionName = fileIconIdsMapByExtensionName

return fileIcons
