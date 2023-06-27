import "android.webkit.WebViewClient"
import "com.google.android.material.dialog.MaterialAlertDialogBuilder"

import "helper.MarkdownHelper"

local _M = {}
local ids = {}
_M.ids = ids

local dialogLayout = {
    LinearLayout,
    orientation = "vertical",
    {
        CardView,
        id = "appBarLayout",
        layout_width = "fill",
        elevation = 0,
        radius = 0,
        cardBackgroundColor = res(res.id.attr.actionBarStyle).color.attr.background,
        {
            Toolbar,
            id = "toolbar",
            layout_width = "fill",
            theme = res.id.attr.actionBarTheme,
            popupTheme = res.id.attr.actionBarPopupTheme,
            navigationIcon = R.drawable.ic_close,
            navigationContentDescription = R.string.close,
        }
    },
    {
        LuaWebView,
        id = "webView",
        backgroundColor = 0,
    }
}
local dialog



function _M.init()
    if dialog then
        return
    end
    LastMarkdownDlgActionBarElevation = 0
    dialog = MaterialAlertDialogBuilder(activity)
        .setView(loadlayout2(dialogLayout, ids))
        .create()
    local webViewSettings = ids.webView.getSettings()
    webViewSettings
        .setDisplayZoomControls(false)                                         --隐藏自带的右下角缩放控件
        .setSupportZoom(true)                                                  --支持网页缩放
        .setDomStorageEnabled(true)                                            --dom储存数据
        .setDatabaseEnabled(true)                                              --数据库
        .setAppCacheEnabled(true)                                              --启用缓存
        .setAllowFileAccess(true)                                              --允许访问文件
        .setBuiltInZoomControls(false)                                         --缩放
        .setLoadWithOverviewMode(true)
        .setLoadsImagesAutomatically(true)                                     --图片自动加载
        .setSaveFormData(true)                                                 --保存表单数据，就是输入框的内容，但并不是全部输入框都会储存
        .setAllowContentAccess(true)                                           --允许访问内容
        .setJavaScriptEnabled(true)                                            --支持js脚本
        .setUseWideViewPort(true)                                              --图片自适应
        .setAcceptThirdPartyCookies(true)                                      --接受第三方cookie
        .setCacheMode(webViewSettings.LOAD_DEFAULT)                            --设置缓存加载方式
        .setLayoutAlgorithm(webViewSettings.LayoutAlgorithm.SINGLE_COLUMN)     --支持重新布局
        .setPluginsEnabled(true)                                               --支持插件
        .setMixedContentMode(webViewSettings.MIXED_CONTENT_COMPATIBILITY_MODE) --允许https中加载http资源
    ids.webView.setWebViewClient(luajava.override(WebViewClient, {
        shouldOverrideUrlLoading = function(super, view, request)
            local url
            --有两个shouldOverrideUrlLoading方法
            if type(request) == "string" then
                url = Uri.parse(request)
            else
                url = request.getUrl()
            end
            if url.getScheme() == "file" then
                --view.loadUrl(tostring(url))
                newSubActivity("WebView", { tostring(url), ids.toolbar.getTitle() })
            else
                openUrl(tostring(url))
            end
            return true
        end,
        onPageStarted = function(super, view, url, favIcon)
            view.evaluateJavascript([[
                    //js
                    var head = document.head || document.getElementsByTagName('head')[0];
                    var viewportMeta = document.createElement('meta');
                    viewportMeta.setAttribute('name', 'viewport')
                    viewportMeta.setAttribute('content', 'width=device-width, initial-scale=1.0')
                    head.appendChild(viewportMeta);
                    var charsetMeta = document.createElement('meta');
                    charsetMeta.setAttribute('charset', 'utf-8')
                    head.appendChild(charsetMeta);
                    //!js
                ]], nil)
            MarkdownHelper.webViewClient.onPageStarted(view, url, favIcon)
        end
    }))

    ids.toolbar.setNavigationOnClickListener(function()
        dialog.dismiss()
    end)

    ids.webView.onScrollChange = function(view, l, t, oldl, oldt)
        AnimationHelper.onScrollListenerForActionBarElevation(ids.appBarLayout, t > 0)
    end
end

function _M.show()
    dialog.show()
end

function _M.setTitle(title)
    ids.toolbar.setTitle(title)
end

function _M.setSubtitle(title)
    ids.toolbar.setSubtitle(title)
end

function _M.load(path)
    ids.webView.loadUrl(path)
    task(500, function()
        ids.webView.clearHistory()
    end)
end

return _M
