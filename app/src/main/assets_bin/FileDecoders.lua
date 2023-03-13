---@class FileDecoder
---@field editor string 编辑器名称



---@type table<string, FileDecoder> 文件解析器
return {
  txt={
    editor="CodeEditor",
    ---@param path string 文件路径
    ---@return string 文件的内容
    read=function(path)
      local content=isBinaryFile(path)
      if content==true then
        return nil,getString(R.string.file_cannot_open_compiled_file)
      end
      return content
    end,
    save=function(path,content)
      if getSharedData("editor_autoBackupOriginalFiles") then
        FilesTabManager.backupDir.mkdirs()
        local backupFilePath=FilesTabManager.backupPath.."/"..System.currentTimeMillis().."_"..File(path).getName()
        os.rename(path, backupFilePath)
      end
      local file=io.open(path,"w")
      if file then
        return pcall(function()
          file:write(content):close()
        end)
       else
        return true,getString(R.string.file_not_find)
      end
    end,
    language=EmptyLanguage(),
  },

  lua={
    super="txt",
    editor="LuaEditor",
    language=false,
  },
  aly={
    super="lua",
    preview={
      editor="FrameView",
      apply=function(filePath,fileType,view)
        if _warnedAlyPreview then
          view.removeAllViews()
          xpcall(function()
            view.addView(safeLoadLayout(filePath,view.getClass()))
            end,function(err)
            local textView=loadlayout2({
              TextView;
              padding="8dp";
              paddingTop="44dp";
              layout_width="fill";
              layout_height="fill";
              textColor=android.res.color.attr.textColorPrimary;
            })
            view.addView(textView.setText(err))
          end)
         else
          EditorsManager.switchPreview(false)
          MaterialAlertDialogBuilder(this)
          .setTitle(getLocalLangObj("ALY 布局预览警告","ALY Layout Preview Warning"))
          .setMessage(getLocalLangObj("ALY布局预览仅可以预览特定的布局。您的布局无法预览属于正常现象。（该提示将在下次启动APP时重新显示）","ALY layout preview can only preview specific layouts. If your layout cannot be previewed, please do not panic. (This dialog will be displayed again the next time you start the APP.)"))
          .setPositiveButton(R.string.preview,function()
            _warnedAlyPreview=true
            EditorsManager.switchPreview(true)
          end)
          .setNegativeButton(android.R.string.cancel,nil)
          .show()
        end
      end,
    },
  },

  xml={
    super="txt",
    language=JavaLanguage(),
  },
  java={
    super="txt",
    language=JavaLanguage(),
  },
  html={
    super="txt",
    language=HTMLLanguage(),
  },
  json={
    super="txt",
    language=JavaLanguage(),
  },
  js={super="txt"},
  ts={super="txt"},
  kt={super="txt"},
  gradle={super="txt"},
  bat={super="txt"},
  properties={super="txt"},
  md={
    super="txt",
    preview={
      editor="WebEditor",
      apply=function(filePath,fileType,view,editorConfig)
        EditorsManager.actionsWithEditor.applyMarkdownFile(editorConfig,filePath)
        task(500,function()
          view.clearHistory()
        end)
      end,
    },
  },
  markdown={super="md"},

  png={
    editor="PhotoView",
    apply=function(filePath,fileType,view)
      local options=RequestOptions()
      options.skipMemoryCache(true)--跳过内存缓存
      options.diskCacheStrategy(DiskCacheStrategy.NONE)--不缓冲disk硬盘中
      Glide.with(activity).load(filePath).apply(options).into(view)
    end,
    read=false,
    save=false,
  },
  jpg={super="png"},
  gif={super="png"},
  webp={super="png"},
  --[[
  svg={
    editor="PhotoView",
    apply=function(filePath,fileType,view)
      Sharp.loadFile(File(filePath)).into(view)
    end,
 },]]
  svg={
    super="xml",
    preview={
      editor="WebEditor",
      apply=function(filePath,fileType,view)
        view.loadUrl("file://"..filePath)
        task(500,function()
          view.clearHistory()
        end)
      end
    },
  },
}