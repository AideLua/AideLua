---@deprecated
return {
    --格式：https://aidelua.github.io/AideLua/plugin/pages/main.html#editorlayouts
    NoneView = {
        layout = {
            LinearLayout,
            id = "editorParent",
            layout_height = "fill",
            layout_width = "fill",
            gravity = "center",
            {
                LinearLayout,
                gravity = "center",
                orientation = "vertical",
                layout_margin = "16dp",
                {
                    AppCompatImageView,
                    imageResource = R.drawable.ic_undraw_opened_tabs,
                    layout_height = "240dp",
                    layout_width = "240dp",
                    scaleType = "fitCenter",
                    layout_weight = 1,
                },
                {
                    TextView,
                    text = R.string.file_noOpen,
                    textSize = "16dp",
                },
            },
        },

    },

    LuaEditor = {
              --Lua编辑器
        layout = {
            FrameLayout,
            layout_height = "fill",
            layout_width = "fill",
            id = "editorParent",
            layoutTransition = newLayoutTransition(),
            {
                ProgressBar, --进度条
                id = "progressBar",
                layout_gravity = "center",
            },
            {
                EditText, --手写编辑框
                layout_width = "fill",
                layout_height = "fill",
                id = "pencilEdit",
                gravity = "top|left",
                text = " ",
                textSize = 0,
            },
            {
                MyLuaEditor, --Lua编辑器
                layout_height = "fill",
                id = "editor",
                layout_width = "fill",
                focusable = true,
                textHighlightColor = 0x99616161,
                keywordColor = 0xff3f51b5,
                stringColor = 0xffc2185b,
                commentColor = 0xff9e9e9e,
                basewordColor = 0xff3f51b5,
                userwordColor = 0xff5c6bc0,
                textSize = math.dp2int(14),
                --nonPrintingCharVisibility=true;
                --highlightCurrentRow=false;
                --longPressCaps=true;
                --autoComplete=false;
                --wordWrap=true;
                --focusableInTouchMode=false;
            },
        },
        init = function(ids, config)
            local editor, pencilEdit, progressBar, editorParent = ids.editor, ids.pencilEdit, ids.progressBar,
            ids.editorParent
            editor.onScrollChange = function(view, l, t, oldl, oldt)
                AnimationHelper.onScrollListenerForActionBarElevation(appBarLayout, t > 0)
            end
            LuaEditorHelper.initKeys(editor, editorParent, pencilEdit, progressBar)
            LuaEditorHelper.applyStyleToolBar(editor)
            LuaEditorHelper.applyTouchListener(editor)
            LuaEditorHelper.applyPencilInput(editor, pencilEdit)
        end,
        onTypefaceChangeListener = function(ids, config, editor, typeface, boldTypeface, italicTypeface)
            editor.setTypeface(typeface)
            editor.setBoldTypeface(boldTypeface)
            editor.setItalicTypeface(italicTypeface)
        end,
        onSharedDataChangeListeners = {
            editor_showBlankChars = function(ids, config, editor, newValue)
                editor.setNonPrintingCharVisibility(toboolean(newValue))
            end,
            editor_wordwrap = function(ids, config, editor, newValue)
                editor.setWordWrap(toboolean(newValue))
            end,
        },
        action = {
            undo = "default",
            redo = "default",
            format = "default",
            search = "default",
            getText = "default",
            setText = "default",
            paste = "default",
            format = "default",
            setTextSize = "default",
            getTextSize = "default",
            getScrollX = "default",
            getScrollY = "default",
            scrollTo = "default",
            selectText = "default",
            setSelection = "default",
            getSelectedText = "default", --在 v5.1.0(51099) 添加
            getSelectionEnd = "default",
            check = function(ids, config, show)
                local editor = ids.editor
                local state, message = loadstring(editor.text)
                if show then
                    if message then
                        local line, data = message:match("%[string \".-%\"]:(%d+): (.+)")
                        editor.gotoLine(tonumber(line))
                        showSnackBar(line .. ": " .. data)
                    else
                        showSnackBar(R.string.checkCode_noGrammaticalErrors)
                    end
                end
                return toboolean(state), message
            end,
            comment = function(ids, config)
                local editor = ids.editor
                local selectedText = editor.getSelectedText()
                if #selectedText ~= 0 then
                    if selectedText:find("\n") then --有换行，多行注释
                        local equals = ""
                        local selectedTextJ = String(selectedText)
                        while (selectedTextJ.indexOf("]" .. equals .. "]") ~= -1 or selectedTextJ.indexOf("[" .. equals .. "[") ~= -1) do
                            equals = equals .. "="
                        end
                        editor.paste("--[" .. equals .. "[" .. selectedText .. "]" .. equals .. "]")
                    else --进行单行注释
                        editor.paste("--" .. selectedText .. "")
                    end
                end
            end,

        },
        supportScroll = true,
        defaultText = [[require "import"
import "jesse205"

]],
        ---将要添加到LuaEditor的关键词列表
        ---更改后需要执行 application.set("luaeditor_initialized", false) ，以便在下次进入页面时更新
        ---使用 activity.recreate() 重启页面
        ---index 为方便更改内容，请使用 string 类型，当然 number 类型也能用
        ---@type table<string, String[]>
        keywordsList = {
            --一些常用但不自带的类
            annotationsWords = String { "class", "type", "alias", "param", "return", "field", "generic", "vararg",
                "language", "example" },
            otherWords = String { "PhotoView", "Glide" },
        },

        ---@type table<string, String[]>
        ---@see keywordsList
        packagesList = {
            --otherPackages=Map{hello=String{"world"},jesse205=String{"nb"}},
        },
        --[[
    normalKeywords=String{
      --一些事件
      "onCreate","onStart","onResume","onPause","onStop","onDestroy",
      "onActivityResult","onResult","onCreateOptionsMenu","onOptionsItemSelected",
      "onTouchEvent","onKeyLongPress","onConfigurationChanged","onHook",
      "onAccessibilityEvent","onKeyUp","onKeyDown","onError","onVersionChanged",

      "onClick","onTouch","onLongClick","onItemClick","onItemLongClick",
      "onContextClick","onScroll","onScrollChange","onNewIntent",
      "onSaveInstanceState","onBackPressed",

      --一些自带的类或者包
      "android","R",
    },
    jesse205Keywords=String{
      "newActivity","getSupportActionBar","getSharedData","setSharedData",
      "getString","getPackageName","getColorStateList","getNetErrorStr",

      --一些标识
      "initApp","notLoadTheme","useCustomAppToolbar",
      "resources","application","inputMethodService","actionBar",
      "notLoadTheme","darkStatusBar","darkNavigationBar",
      "window","safeModeEnable","notSafeModeEnable","decorView",

      --一些函数
      "theme","formatResStr","autoSetToolTip",
      "showLoadingDia","closeLoadingDia","getNowLoadingDia",
      "showErrorDialog","toboolean","rel2AbsPath","copyText",
      "newSubActivity","isDarkColor","openInBrowser","openUrl",
      "loadlayout2","showSimpleDialog","getLocalLangObj",
      "newLayoutTransition",

      --一些模块/类
      "AppPath","ThemeUtil","EditDialogBuilder","ImageDialogBuilder",
      "MyToast","AutoToolbarLayout","PermissionUtil","MyStyleUtil",
      "AutoCollapsingToolbarLayout","SettingsLayUtil","jesse205",
      "StyleWidget","ScreenUtil","FileUriUtil","ClearContentHelper",
      "MyAnimationUtil","FileUtil","AnimationHelper",

      --自定义View
      "MyTextInputLayout","MyCardTitleEditLayout","MyTitleEditLayout",
      "MyEditDialogLayout","MyTipLayout","MySearchBar",
      "MyRecyclerView",

      --适配器
      "MyLuaMultiAdapter","MyLuaAdapter","LuaCustRecyclerAdapter",
      "LuaCustRecyclerHolder","AdapterCreator",

      table.unpack(StyleWidget.types),
    },]]

    },
    CodeEditor = {
        layout = {
            LinearLayoutCompat,
            layout_height = "fill",
            layout_width = "fill",
            id = "editorParent",
            {
                MyCodeEditor,
                layout_height = "fill",
                id = "editor",
                layout_width = "fill",
                focusable = true,
                nonPrintablePaintingFlags = CodeEditor.FLAG_DRAW_WHITESPACE_LEADING,
                textSize = 14,
                overScrollEnabled = false,
                --cursorWidth=100;
                --displayLnPanel=false;
                --highlightCurrentLine=true;
                --highlightCurrentBlock=true;
                --highlightSelectedText=true;
                --lineNumberEnabled=true;
                --symbolCompletionEnabled=true;
                --wordwrap=true;
                dividerWidth = "1dp",
            },
        },
        init = function(ids, config)
            local editor, editorParent = ids.editor, ids.editorParent
            import "io.github.rosemoe.editor.widget.schemes.SchemeDarcula"
            import "io.github.rosemoe.editor.widget.schemes.SchemeGitHub"

            if ThemeUtil.isNightMode() then
                editor.setColorScheme(SchemeDarcula())
            else
                editor.setColorScheme(SchemeGitHub())
            end
        end,
        onTypefaceChangeListener = function(ids, config, editor, typeface, boldTypeface, italicTypeface)
            editor.setTypefaceText(typeface)
            editor.setTypefaceLineNumber(typeface)
            --editor.setBoldTypeface(boldTypeface)
            --editor.setItalicTypeface(italicTypeface)
        end,
        onSharedDataChangeListeners = {
            editor_wordwrap = function(ids, config, editor, newValue)
                editor.setWordwrap(toboolean(newValue))
            end,
        },
        action = {
            undo = "default",
            redo = "default",
            format = false,
            check = false,
            paste = function(ids, config, text)
                local editor = ids.editor
                editor.cursor.onCommitText(text)
                return true
            end,
            setTextSize = function(ids, config, size)
                local editor = ids.editor
                editor.setTextSizePx(size)
                return true
            end,
            getTextSize = function(ids, config)
                local editor = ids.editor
                return true, editor.getTextSizePx()
            end,
            scrollTo = function(ids, config, x, y)
                local editor = ids.editor
                local scroller = editor.getScroller()
                --scroller.setFinalX(x)
                --scroller.setFinalY(y)
                scroller.startScroll(scroller.getCurrX(),
                    scroller.getCurrY(),
                    x - scroller.getCurrX(),
                    y - scroller.getCurrY(), 0)
                scroller.abortAnimation()
                return true
            end,
            getScrollX = function(ids, config)
                local editor = ids.editor
                return true, editor.getScroller().getCurrX()
            end,
            getScrollY = function(ids, config)
                local editor = ids.editor
                return true, editor.getScroller().getCurrY()
            end,
            search = {
                start = function(ids)
                    ids.editor.mStartedActionMode = 1
                end,
                search = function(ids, config, text, gotoNext)
                    local editor = ids.editor
                    editor.getSearcher().search(tostring(text))
                    if gotoNext then
                        editor.getSearcher().gotoNext()
                    end
                end,
                finish = function(ids, config)
                    local editor = ids.editor
                    editor.mStartedActionMode = 0
                    editor.getSearcher().stopSearch()
                end
            },
            getText = "default",
            setText = function(ids, config, text)
                ids.editor.setText(text)
                return true
            end,
        },
        supportScroll = true,
    },
    PhotoView = {
        layout = {
            LinearLayoutCompat,
            layout_height = "fill",
            layout_width = "fill",
            --layoutTransition=newLayoutTransition();
            id = "editorParent",
            --visibility=View.GONE;
            {
                PhotoView,
                layout_height = "fill",
                id = "editor",
                layout_width = "fill",
                padding = "32dp",
            },
        },
        --[[
    action={
      undo=nil,
      redo=nil,
      format=nil,
      search=nil,
    },]]
    },
    FrameView = {
        layout = {
            LinearLayoutCompat,
            layout_height = "fill",
            layout_width = "fill",
            id = "editorParent",
            {
                FrameLayout,
                layout_height = "fill",
                layout_width = "fill",
                id = "editor",
            },
        },
    },
    --v5.1.1+
    WebEditor = {
        layout = {
            LinearLayoutCompat,
            layout_height = "fill",
            layout_width = "fill",
            id = "editorParent",
            {
                LuaWebView,
                layout_height = "fill",
                layout_width = "fill",
                id = "editor",
                --backgroundColor=theme.color.windowBackground;
                backgroundColor = 0,
            },
        },
        init = function(ids, config)
            local editor = ids.editor
            local webViewSettings = editor.getSettings()
            webViewSettings
                .setDisplayZoomControls(false)                               --隐藏自带的右下角缩放控件
                .setSupportZoom(true)                                        --支持网页缩放
                .setDomStorageEnabled(true)                                  --dom储存数据
                .setDatabaseEnabled(true)                                    --数据库
                .setAppCacheEnabled(true)                                    --启用缓存
                .setUseWideViewPort(true)
                .setAllowFileAccess(true)                                    --允许访问文件
                .setBuiltInZoomControls(false)                               --缩放
                .setLoadWithOverviewMode(true)
                .setLoadsImagesAutomatically(true)                           --图片自动加载
                .setSaveFormData(true)                                       --保存表单数据，就是输入框的内容，但并不是全部输入框都会储存
                .setAllowContentAccess(true)                                 --允许访问内容
                .setJavaScriptEnabled(true)                                  --支持js脚本
                .setUseWideViewPort(true)                                    --图片自适应
                .setAcceptThirdPartyCookies(true)                            --接受第三方cookie
                .setCacheMode(webViewSettings.LOAD_DEFAULT)                  --设置缓存加载方式
                .setLayoutAlgorithm(webViewSettings.LayoutAlgorithm.SINGLE_COLUMN) --支持重新布局
                .setPluginsEnabled(true)                                     --支持插件
                .setMixedContentMode(webViewSettings.MIXED_CONTENT_COMPATIBILITY_MODE) --允许https中加载http资源
            editor.onScrollChange = function(view, l, t, oldl, oldt)
                AnimationHelper.onScrollListenerForActionBarElevation(appBarLayout, t > 0)

                --MyAnimationUtil.ScrollView.onScrollChange(view,l,t,oldl,oldt,appBarLayout)
            end

            editor.setWebViewClient(luajava.override(WebViewClient, {
                shouldOverrideUrlLoading = function(super, view, request)
                    local url
                    --有两个shouldOverrideUrlLoading方法
                    if type(request) == "string" then
                        url = Uri.parse(request)
                    else
                        url = request.getUrl()
                    end

                    if url.getScheme() == "file" then
                        local path = url.getPath()
                        FilesTabManager.openFile(File(path), getFileTypeByName(path), false)
                    else
                        openUrl(tostring(url))
                    end
                    return true
                end,
                onPageStarted = function(super, view, url, favicon)
                    MarkdownHelper.webViewClient.onPageStarted(view, url, favicon)
                end,
                onPageFinished = function(super, view, url)
                    --加载Eruda
                    --view.evaluateJavascript([[(function () { var script = document.createElement('script'); script.src="https://cdn.jsdelivr.net/npm/eruda"; document.body.appendChild(script); script.onload = function () { eruda.init() } })();]],nil)
                end
            }))
        end,
        action = {
            getScrollX = "default",
            getScrollY = "default",
            evaluateJavascript = "default",
            destroy = "default",
            applyMarkdownFile = function(ids, config, path)
                MarkdownHelper.loadFile(ids.editor, path)
            end
        },
        supportScroll = true,
    },

}
