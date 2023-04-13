local colorOnBackground = res.color.attr.colorOnBackground
local colorPrimary = res.color.attr.colorPrimary

--一些文件图标颜色的table的组
--结构：
--[[
fileIconColors={
  --一些特殊的颜色
  colorsMapByType={
    --一类型的图标颜色
  },
  colorsMapByExtension={
    --通过扩展名获取图标颜色（主要）
  }
}]]
local fileIconColors = {
    normal = 0xff757575, -- 普通文件颜色，灰色
    active = colorPrimary, -- 已打开文件颜色
    folder = 0xFFF9A825, -- 文件夹颜色，橙色
}

---一类型的图标颜色
---@type table<string, number>
local colorsMapByType = {
    android = 0xFF00E676,
    picture = 0xff448aff,
    music = 0xff9c27b0,
    video = 0xff4caf50,
    word = 0xff5c6bc0,
    ppt = 0xffff5722,
    xls = 0xff4caf50,
}
fileIconColors.colorsMapByType = colorsMapByType


--通过扩展名获取图标颜色（主要）
---@enum
---@type table<string, number>
local colorsMapByExtension = {
    -- 按文件类型
    apk = colorsMapByType.android, -- 安卓应用程序
    apks = colorsMapByType.android,
    aab = colorsMapByType.android,
    hap = 0xff304ffe,
    exe = 0xff2979ff,
    lua = 0xff448aff,
    aly = 0xff29b6f6,
    png = colorsMapByType.picture, -- 图片文件
    jpg = colorsMapByType.picture,
    webp = colorsMapByType.picture,
    bmp = colorsMapByType.picture,
    tif = colorsMapByType.picture,
    mp4 = colorsMapByType.video, -- 音视频
    avi = colorsMapByType.video,
    mov = colorsMapByType.video,
    mpg = colorsMapByType.video,
    wav = colorsMapByType.music,
    mp3 = colorsMapByType.music,
    mid = colorsMapByType.music,
    xml = 0xffff6f00, -- xml文件
    svg = 0xffff6f00,
    dex = 0xff00bcd4,
    java = 0xff2962ff,
    kt = 0xff7c4dff,
    jar = 0xffe64a19,
    gradle = 0xff0097a7,
    md = colorOnBackground,
    markdown = colorOnBackground,
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
    doc = colorsMapByType.word, --office
    docx = colorsMapByType.word,
    ppt = colorsMapByType.ppt,
    pptx = colorsMapByType.ppt,
    xls = colorsMapByType.xls,
    xlsx = colorsMapByType.xls,
    pdf = 0xfff44336,
    bat = colorOnBackground,
    sh = colorOnBackground,
}
fileIconColors.colorsMapByExtension = colorsMapByExtension

return fileIconColors
